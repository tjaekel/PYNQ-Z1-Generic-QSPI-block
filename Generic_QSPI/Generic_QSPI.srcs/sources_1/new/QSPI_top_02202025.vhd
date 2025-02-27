----------------------------------------------------------------------------------
-- Company: private
-- Engineer: Torsten Jaekel
-- 
-- Create Date: 12/03/2024 12:15:00 PM
-- Design Name: QSPI_top
-- Module Name: QSPI_top - Behavioral
-- Project Name: QSPI for PYNQ
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- implement a generic QSPI interface for PYNQ:
--  - as 1:4:4, with
--  - 8bit CMD (single lane, encoded as 32bit word), 32bit ADDR, 24bit ALT
--  - on Read: two turnaround cycles
--  - read 32bit words (from 4 lanes)
--  - compensate delays: Read samples one S_CLK later (10ns)
--
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

--top interface
entity QSPI_top is
    Port ( --internal signals
           WR_REG : in STD_LOGIC_VECTOR (31 downto 0);
           RD_REG : out STD_LOGIC_VECTOR (31 downto 0);
           CTL_REG : in STD_LOGIC_VECTOR (31 downto 0);
           STS_REG : out STD_LOGIC_VECTOR (31 downto 0);
           S_CLK : in STD_LOGIC;
           -- external output/input signals
           QCLK : out STD_LOGIC;
           QD : inout STD_LOGIC_VECTOR (3 downto 0);
           CS : out STD_LOGIC_VECTOR (3 downto 0);
           DIR : out STD_LOGIC_VECTOR (1 downto 0);  --generate DIR for level shifter
           -- external GPIO signals: 6x in INTx, 7x out GPIO, RESET
           INTn : in STD_LOGIC_VECTOR(5 downto 0);
           GPIO : out STD_LOGIC_VECTOR(6 downto 0)
           --RESn : in STD_LOGIC
           --QCLKfb : in STD_LOGIC
         );
end QSPI_top;

--CTL_REG:
-- bit [31:30] : counter, change it on every transaction
-- bit [29..28] : unused
-- bit 27 : if 0 (default) - block hold in reset!, set to 1
-- bit [26..24] : RDdly: 0..7, as 2x S_CLK always, plus RDdly + 1 if not 0, max.=10 S_CLK
-- bit 23 : unused
-- bit [22..16] : GPIO out
-- bit [15..12] : nCS idle time - 0..15, CS_DIV, as S_CLK * (CS_DIV+2)
-- bit [11:8] : clock divider - 0..15, CLK_DIV
-- bit 7 : - flip the byte endian on WR and RD data part
-- bit 6 : - generate a 32bit RD
-- bit 5 : - generate a 2bit TurnAround
-- bit 4 : - generate a 24bit ALT
--         - you can set bit 4 and 5 together - creates 8 cycles with both
--       : - if not bit 6..4 set: generate a 32bit WR
-- bit [3:0] - nCS signals - if all are "1111" - reset (TriggerCnt = 0)

--STS_REG:
-- bit 31 : busy
-- bit [9..4] : INT0..INT5
-- bit 0  : ready (shift out or shift in done), 0x80000000 or 0x00000001, 0x00000000 (Idle) not used

architecture Behavioral of QSPI_top is

type t_State is (CSidle, WriteStrobe, ShiftOutD, ShiftOutD2, Idle);
signal State : t_State := Idle;

type t_StateRx is (ReadIdle, Idle, RDdelay, RDdelay0);
signal RxState : t_StateRx := Idle;

signal DataShiftOut : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal DataShiftIn  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal ShiftCounter : integer range 0 to 8 := 7;
signal QDdataOut    : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal QDdataIn     : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal Direction    : STD_LOGIC := '1';                 -- '1' is input, '0' is output
signal ClockDiv     : integer range 0 to 15 := 7;       -- 7 results in 7+1 half clock cycles on QCLK
signal CSDiv        : integer range 0 to 15 := 0;       -- delay after nCS going low
signal RDdly        : integer range 0 to  7 := 4;       -- delay after rising QCLK edge
signal RDdlyCnt     : integer range 0 to  7 := 4;
signal TriggerCnt   : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');

begin

IOBUF_QD0 : IOBUF
generic map (
   DRIVE => 12,
   IOSTANDARD => "DEFAULT",
   SLEW => "SLOW")
port map (
   O => QDdataIn(0),     -- Buffer output
   IO => QD(0),          -- Buffer inout port (connect directly to top-level port)
   I => QDdataOut(0),    -- Buffer input
   T => Direction        -- 3-state enable input, high=input, low=output
);

IOBUF_QD1 : IOBUF
generic map (
   DRIVE => 12,
   IOSTANDARD => "DEFAULT",
   SLEW => "SLOW")
port map (
   O => QDdataIn(1),      -- Buffer output
   IO => QD(1),           -- Buffer inout port (connect directly to top-level port)
   I => QDdataOut(1),     -- Buffer input
   T => Direction         -- 3-state enable input, high=input, low=output
);

IOBUF_QD2 : IOBUF
generic map (
   DRIVE => 12,
   IOSTANDARD => "DEFAULT",
   SLEW => "SLOW")
port map (
   O => QDdataIn(2),      -- Buffer output
   IO => QD(2),           -- Buffer inout port (connect directly to top-level port)
   I => QDdataOut(2),     -- Buffer input
   T => Direction         -- 3-state enable input, high=input, low=output
);

IOBUF_QD3 : IOBUF
generic map (
   DRIVE => 12,
   IOSTANDARD => "DEFAULT",
   SLEW => "SLOW")
port map (
   O => QDdataIn(3),      -- Buffer output
   IO => QD(3),           -- Buffer inout port (connect directly to top-level port)
   I => QDdataOut(3),     -- Buffer input
   T => Direction         -- 3-state enable input, high=input, low=output
);

   --this was SPI mode 1 (not 0), changed for SPI mode 3
   --process (S_CLK, RESn)
   process (S_CLK)
   begin
        if (rising_edge(S_CLK)) then
            --if RESn = '0' or CTL_REG(27) = '0' then
            if CTL_REG(27) = '0' then
                QCLK <= '1';
                TriggerCnt <= (others => '0');
                CS <= (others => '1');
                GPIO <= (others =>'1');
                Direction <= '0';
                QDdataOut <= (others => '0');
                ShiftCounter <= 7;
                DataShiftOut <= (others => '0');
                state <= Idle;
            else
            GPIO <= CTL_REG(22 downto 16);
            case State is
                when Idle =>
                    CS <= CTL_REG(3 downto 0);                  --drive nCS
                    if CTL_REG(3 downto 0) = "1111" then
                        TriggerCnt <= (others => '0');          --reset
                        --QCLK <= '0';
                        QCLK <= '1';                            --default QSPI mode SCLK
                        Direction <= '0';
                        State <= Idle;
                    else
                        TriggerCnt <= CTL_REG(31 downto 30);
                        if CTL_REG(31 downto 30) /= TriggerCnt then
                            --QCLK <= '0';
                            QCLK <= '1';
                            ClockDiv <= to_integer(unsigned(CTL_REG(11 downto 8)));
                            CSDiv    <= to_integer(unsigned(CTL_REG(15 downto 12)));
                            
                            if CTL_REG(7) = '1' then
                                DataShiftOut <= WR_REG(7 downto 0) & WR_REG(15 downto 8) & WR_REG(23 downto 16) & WR_REG(31 downto 24);
                            else
                                DataShiftOut <= WR_REG(31 downto 0);
                            end if;
                            if CTL_REG(15 downto 12) = "0000" then
                                State <= WriteStrobe;
                            else
                                State <= CSIdle;
                            end if;
                        end if;
                    end if;
                    
                when CSidle =>
                    if CSdiv = 0 then
                        State <= WriteStrobe;
                    else
                        CSDiv <= CSDiv - 1;
                        State <= CSidle;
                    end if;
                
                when WriteStrobe =>
                    Direction <= '0';
                    ShiftCounter <= 7;              --default
                    Direction <= '0';               --default
                    if CTL_REG(4) = '1' then        --24bit ALT
                        ShiftCounter <= 5;
                    end if;
                    if CTL_REG(5) = '1' then        --2bit TA
                        ShiftCounter <= 1;
                        Direction <= '1';
                    end if;
                    if CTL_REG(6) = '1' then        --32bit Read
                        Direction <= '1';
                        ShiftCounter <= 7;
                    end if;
                    if CTL_REG(5 downto 4) = "11" then  --24bit ALT plus 2bit TA
                        ShiftCounter <= 7;
                        Direction <= '0';          --first 24bit out
                    end if;
                    ClockDiv <= to_integer(unsigned(CTL_REG(11 downto 8)));
                    QDdataOut <= DataShiftOut(31 downto 28);
                    DataShiftOut <= DataShiftOut(27 downto 0) & "0000";
                    --QCLK <= '1';
                    QCLK <= '0';
                    State <= ShiftOutD;

                when ShiftOutD =>
                    if ClockDiv = 0 then
                        --QCLK <= '0';
                        QCLK <= '1';
                        ClockDiv <= to_integer(unsigned(CTL_REG(11 downto 8)));
                        State <= ShiftOutD2;
                    else
                        ClockDiv <= ClockDiv - 1;
                    end if;
                    
                when ShiftOutD2 =>
                    if ShiftCounter = 0 then
                        State <= Idle;
                    else
                        if ClockDiv = 0 then
                            ShiftCounter <= ShiftCounter - 1;
                            QDdataOut <= DataShiftOut(31 downto 28);
                            DataShiftOut <= DataShiftOut(27 downto 0) & "0000";
                            ClockDiv <= to_integer(unsigned(CTL_REG(11 downto 8)));
                            --QCLK <= '1';
                            QCLK <= '0';
                        
                            if CTL_REG(5 downto 4) = "11" then
                                --24bit ALT + 2bit TA together
                                if ShiftCounter = 2 then
                                    Direction <= '1';
                                end if;
                            end if;
                        
                            State <= ShiftOutD;
                        else
                            ClockDiv <= ClockDiv - 1;
                        end if;
                    end if;     
            end case;
            end if;
        end if;
   end process;

   process (S_CLK, INTn, State)
   variable rdCnt : integer range 0 to 7 := 7;
   begin
        if (rising_edge(S_CLK)) then
            --if RESn = '0' then
            if CTL_REG(27) = '0' then
                STS_REG(31 downto 0) <= "1000000000000000000000" & INTn & "0000";
                RD_REG <= (others => '0');
                DataShiftIn <= (others => '0');
            else
            STS_REG(30 downto 1) <= "000000000000000000000" & INTn & "000";
            if State = WriteStrobe then
                RDdly <= to_integer(unsigned(CTL_REG(26 downto 24)));
                RDdlyCnt <= to_integer(unsigned(CTL_REG(26 downto 24)));
                rdCnt := 7;
            end if;
            case RxState is
                when Idle =>
                    if State = ShiftOutD2 and CTL_REG(6) = '1' then
                        RxState <= RDdelay0;
                        if RDdly = 0 then
                            RxState <= RDdelay;
                        end if;
                        RDdlyCnt <= RDdly;
                    end if;
                    if State = WriteStrobe then
                        STS_REG(31) <= '1';                   --busy flag
                        STS_REG(0)  <= '0';
                        DataShiftIn <= (others => '0');       --just to make sure to be clean for next shift in
                        rdCnt := 7;
                    end if;
                    if State = Idle and ShiftCounter = 0 then
                        STS_REG(31) <= '0';
                        STS_REG(0)  <= '1';
                    end if;
                when RDdelay0 =>
                    if RDdlyCnt = 0 then
                        RxState <= RDdelay;
                    else
                        RDdlyCnt <= RDdlyCnt - 1;
                    end if;
                when RDdelay =>
                        if rdCnt = 0 then
                            if CTL_REG(7) = '1' then
                                if CTL_REG(5) = '1' and Direction = '1' then
                                    --just to avoid the propagation of X due to Z on input
                                    RD_REG <= DataShiftIn(3 downto 0) & "0000" & DataShiftIn(11 downto 4) & DataShiftIn(19 downto 12) & DataShiftIn(27 downto 20);
                                else
                                    RD_REG <= DataShiftIn(3 downto 0) & QDdataIn & DataShiftIn(11 downto 4) & DataShiftIn(19 downto 12) & DataShiftIn(27 downto 20);
                                end if;
                            else
                                if CTL_REG(5) = '1' and Direction = '1' then
                                    RD_REG <= DataShiftIn(27 downto 0) & "0000";
                                else
                                    RD_REG <= DataShiftIn(27 downto 0) & QDdataIn;
                                end if;
                            end if;
                            STS_REG(31) <= '0';          --shift ready, clear busy flag
                            STS_REG(0)  <= '1';  
                            RxState <= Idle;         
                        else
                            if CTL_REG(5) = '1' and Direction = '1' then
                                --just to avoid the propagation of X due to Z on input
                                DataShiftIn <= DataShiftIn(27 downto 0) & "0000";
                            else
                                DataShiftIn <= DataShiftIn(27 downto 0) & QDdataIn;
                            end if;
                            rdCnt := rdCnt - 1;
                            RxState <= ReadIdle;
                        end if;
                    
                when ReadIdle =>
                    if State = ShiftOutD or State = Idle then
                        RxState <= Idle;
                    end if;
            end case;
            end if;
        end if;
   end process;
   
    --QD <= QDdataOut when Direction = '0' else "ZZZZ";
    --QDdataIn <= QDdataOut when Direction = '0' else QD;
    
    DIR(1) <= not Direction;
    DIR(0) <= not Direction;

end Behavioral;
