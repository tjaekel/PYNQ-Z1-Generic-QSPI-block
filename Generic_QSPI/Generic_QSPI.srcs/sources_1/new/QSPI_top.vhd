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
           CS : out STD_LOGIC_VECTOR (3 downto 0)
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
--       : it not bit 6..4 set: generate a 32bit WR
-- bit [3:0] - nCS signals - if all are "1111" - reset (TriggerCnt = 0)

--STS_REG:
-- bit 31 : busy
-- bit 0  : ready (shift out or shift in done)

architecture Behavioral of QSPI_top is

type t_State is (WriteStrobe, ShiftOutA, ShiftOutD, ShiftOutD2, Idle);
signal State : t_State := Idle;

type t_StateRx is (ReadIdle, Idle);
signal RxState : t_StateRx := Idle;

signal DataShiftOut : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal DataShiftIn  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal ShiftCounter : integer range 0 to 8 := 8;
signal QDdataOut    : STD_LOGIC_VECTOR(3 downto 0);
signal QDdataIn     : STD_LOGIC_VECTOR(3 downto 0);
signal Direction    : STD_LOGIC := '1';                 -- '1' is input, '0' is output
signal xDirection   : STD_LOGIC := '1'; 
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

   process (S_CLK)
   begin
        if (rising_edge(S_CLK)) then
            case State is
                when Idle =>
                    STS_REG <= x"00000001";                     --shift ready, clear busy flag
                    CS <= CTL_REG(3 downto 0);                  --drive nCS
                    if CTL_REG(3 downto 0) = "1111" then
                        TriggerCnt <= (others => '0');          --reset
                        State <= Idle;
                    else
                        TriggerCnt <= CTL_REG(31 downto 30);
                        if CTL_REG(31 downto 30) /= TriggerCnt then
                            QCLK <= '0';
                            STS_REG <= x"80000000";                 --set busy flag
                            ClockDiv <= to_integer(unsigned(CTL_REG(12 downto 8)));
                            State <= WriteStrobe;
                        end if;
                    end if;
                    
                when WriteStrobe =>
                    --we could use bit (7) for little endian write and read, flip bytes
                    if CTL_REG(7) = '1' then
                        DataShiftOut <= WR_REG(7 downto 0) & WR_REG(15 downto 8) & WR_REG(23 downto 16) & WR_REG(31 downto 24);
                    else
                        DataShiftOut <= WR_REG;
                    end if;
                    ShiftCounter <= 8;              --default
                    xDirection <= '0';
                    if CTL_REG(4) = '1' then
                        ShiftCounter <= 6;          --24bit value (ALT)
                    end if;
                    if CTL_REG(5) = '1' then
                        ShiftCounter <= 2;          --two turnaround bits
                        xDirection <= '1';
                    end if;
                    if CTL_REG(6) = '1' then
                        ShiftCounter <= 8;          --32bit word read
                        xDirection <= '1';
                    end if;
                    ClockDiv <= to_integer(unsigned(CTL_REG(12 downto 8)));
                    STS_REG(31) <= '0';             --clear busy flag
                    State <= ShiftOutA;
                
                when ShiftOutA =>                 
                    Direction <= xDirection;
                    ShiftCounter <= ShiftCounter - 1;
                    QDdataOut <= DataShiftOut(31 downto 28);
                    DataShiftOut <= DataShiftOut(27 downto 0) & "0000";
                    QCLK <= '1';
                    State <= ShiftOutD;
                    
                when ShiftOutD =>
                    if ClockDiv = 0 then
                        QCLK <= '0';
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
                            QCLK <= '1';
                            State <= ShiftOutD;
                            else
                                ClockDiv <= ClockDiv - 1;
                            end if;
                        end if;     
            end case;
        end if;
   end process;

   --our Read sampling process: it samples the QDIN one S_CLK cycle later:
   --compensate the delay in FPGA and external level shifters
   process (S_CLK, State)
   begin
        if (rising_edge(S_CLK)) then
            case RxState is
                when Idle =>
                    if State = ShiftOutD2 then
                        if CTL_REG(5) = '1' then
                            DataShiftIn <= (others => '0');   --2bit turnaround - avoid 'X'
                        else
                            DataShiftIn <= DataShiftIn(27 downto 0) & QDdataIn;
                        end if;
                        RxState <= ReadIdle;
                    end if;
                    if State = WriteStrobe then
                        DataShiftIn <= (others => '0');
                    end if;
                    
                when ReadIdle =>
                    if State = ShiftOutD then
                        RxState <= Idle;
                    end if;
                    if State = Idle then
                        if CTL_REG(7) = '1' then
                            RD_REG <= DataShiftIn(7 downto 0) & DataShiftIn(15 downto 8) & DataShiftIn(23 downto 16) & DataShiftIn(31 downto 24);
                        else
                            RD_REG <= DataShiftIn;
                        end if;
                        RxState <= Idle;
                    end if;
            end case;
        end if;
   end process;
   
    --QD <= QDdataOut when Direction = '0' else "ZZZZ";
    --QDdataIn <= QDdataOut when Direction = '0' else QD;

end Behavioral;
