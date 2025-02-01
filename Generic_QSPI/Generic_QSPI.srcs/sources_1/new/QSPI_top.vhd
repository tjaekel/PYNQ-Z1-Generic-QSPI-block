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
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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
           DIR : out STD_LOGIC_VECTOR (1 downto 0)  --generate DIR for level shifter
         );
end QSPI_top;

--CTL_REG:
-- bit [31:30] : counter, change it on every transaction
--
-- bit [12:8] : clock divider
-- bit 7 : - flip the byte endian on WR and RD data part
-- bit 6 : - generate a 32bit RD
-- bit 5 : - generate a 2bit TurnAround
-- bit 4 : - generate a 24bit ALT
--         - you can set bit 4 and 5 together - creates 8 cycles with both
--       : - if not bit 6..4 set: generate a 32bit WR
-- bit [3:0] - nCS signals - if all are "1111" - reset (TriggerCnt = 0)

--STS_REG:
-- bit 31 : busy
-- bit 0  : ready (shift out or shift in done), 0x80000000 or 0x00000001, 0x00000000 (Idle) not used

architecture Behavioral of QSPI_top is

type t_State is (WriteStrobe, ShiftOutD, ShiftOutD2, Idle);
signal State : t_State := Idle;

type t_StateRx is (ReadIdle, Idle);
signal RxState : t_StateRx := Idle;

signal DataShiftOut : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal DataShiftIn  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal ShiftCounter : integer range 0 to 8 := 8;
signal QDdataOut    : STD_LOGIC_VECTOR(3 downto 0);
signal QDdataIn     : STD_LOGIC_VECTOR(3 downto 0);
signal Direction    : STD_LOGIC := '1';                 -- '1' is input, '0' is output
signal ClockDiv     : integer range 0 to 31 := 7;       --7 results in 7+1 half clock cycles on QCLK
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

   --this is SPI mode 1 (not 0), changed for SPI mode 3
   process (S_CLK)
   begin
        if (rising_edge(S_CLK)) then
            case State is
                when Idle =>
                    CS <= CTL_REG(3 downto 0);                  --drive nCS
                    if CTL_REG(3 downto 0) = "1111" then
                        TriggerCnt <= (others => '0');          --reset
                        State <= Idle;
                    else
                        TriggerCnt <= CTL_REG(31 downto 30);
                        if CTL_REG(31 downto 30) /= TriggerCnt then
                            --QCLK <= '0';
                            QCLK <= '1';
                            ClockDiv <= to_integer(unsigned(CTL_REG(12 downto 8)));
                            
                            if CTL_REG(7) = '1' then
                                DataShiftOut <= WR_REG(7 downto 0) & WR_REG(15 downto 8) & WR_REG(23 downto 16) & WR_REG(31 downto 24);
                            else
                                DataShiftOut <= WR_REG(31 downto 0);
                            end if;
                            State <= WriteStrobe;
                        end if;
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
                    end if;
                    if CTL_REG(5 downto 4) = "11" then  --24bit ALT plus 2bit TA
                        ShiftCounter <= 7;
                        Direction <= '0';          --first 24bit out
                    end if;
                    ClockDiv <= to_integer(unsigned(CTL_REG(12 downto 8)));
                    QDdataOut <= DataShiftOut(31 downto 28);
                    DataShiftOut <= DataShiftOut(27 downto 0) & "0000";
                    --QCLK <= '1';
                    QCLK <= '0';
                    State <= ShiftOutD;

                when ShiftOutD =>
                    if ClockDiv = 0 then
                        --QCLK <= '0';
                        QCLK <= '1';
                        ClockDiv <= to_integer(unsigned(CTL_REG(12 downto 8)));
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
                            ClockDiv <= to_integer(unsigned(CTL_REG(12 downto 8)));
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
   end process;

   process (S_CLK, State, ShiftCounter)
   begin
        if (rising_edge(S_CLK)) then
            case RxState is
                when Idle =>
                    if State = ShiftOutD2 then
                        if ShiftCounter = 0 then    
                            if CTL_REG(7) = '1' then
                                RD_REG <= DataShiftIn(3 downto 0) & QDdataIn & DataShiftIn(11 downto 4) & DataShiftIn(19 downto 12) & DataShiftIn(27 downto 20);
                            else
                                RD_REG <= DataShiftIn(27 downto 0) & QDdataIn;
                            end if;
                            STS_REG <= x"00000001";          --shift ready, clear busy flag           
                        else
                            DataShiftIn <= DataShiftIn(27 downto 0) & QDdataIn;
                        end if;
                        RxState <= ReadIdle;
                    end if;
                    if State = WriteStrobe then
                        STS_REG <= x"80000000";
                        DataShiftIn <= (others => '0');       --just to make sure to be clean for next shift in
                    end if;
                    
                when ReadIdle =>
                    if State = ShiftOutD or State = Idle then
                        RxState <= Idle;
                    end if;
            end case;
        end if;
   end process;
   
    --QD <= QDdataOut when Direction = '0' else "ZZZZ";
    --QDdataIn <= QDdataOut when Direction = '0' else QD;
    
    DIR(1) <= not Direction;
    DIR(0) <= not Direction;

end Behavioral;
