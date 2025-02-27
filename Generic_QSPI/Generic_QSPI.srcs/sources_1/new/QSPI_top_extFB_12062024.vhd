----------------------------------------------------------------------------------
-- Company: private
-- Engineer: Torsten Jaekel
-- 
-- Create Date: 11/27/2024 04:22:00 PM
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
           QCLKfb : in STD_LOGIC
         );
end QSPI_top;

architecture Behavioral of QSPI_top is

type t_State is (WriteStrobe, ShiftOutA, ShiftOutA2, ShiftOutD, ShiftOutD2,
                 Idle);
signal State : t_State := Idle;

signal DataShiftOut : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal DataShiftIn : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal ShiftCounter : integer range 0 to 8 := 8;
signal QDdataOut : STD_LOGIC_VECTOR(3 downto 0);
signal QDdataIn : STD_LOGIC_VECTOR(3 downto 0);
signal Direction : STD_LOGIC := '1';    -- '1' is input, '0' is output
signal xDirection : STD_LOGIC := '1'; 
signal ClockDiv : integer range 0 to 31 := 7;       --7 results in 10/2 = 5 per half period

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

   --handle all with S_CLK:
   process(S_CLK)
   begin
        --if (S_CLK'event) then                           --double edge (DDR) clocking: double the speed! - not possible for real FPGFA!
        if (rising_edge(S_CLK)) then
            --due to several states - we add additonal clock cycles (7+1 -> 10)
            CS <= CTL_REG(3 downto 0);                  --drive nCS
            if CTL_REG(31) = '1' then
                QCLK <= '0';
                State <= WriteStrobe;
                STS_REG <= x"80000000";                 --set busy flag
                ClockDiv <= to_integer(unsigned(CTL_REG(12 downto 8)));
            end if;
            
            case State is
                when WriteStrobe =>
                    --DataShiftIn <= (others => '0');
                    if CTL_REG(31) = '0' then
                        DataShiftOut <= WR_REG;
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
                        --we could use (7) for little endian write and read
                        State <= ShiftOutA;
                        ClockDiv <= to_integer(unsigned(CTL_REG(12 downto 8)));
                        STS_REG(31) <= '0';             --clear busy flag
                    end if;
                
                when ShiftOutA =>                 
                    Direction <= xDirection;
                    ShiftCounter <= ShiftCounter - 1;
                    QDdataOut <= DataShiftOut(31 downto 28);
                    DataShiftOut <= DataShiftOut(27 downto 0) & "0000";
                    State <= ShiftOutA2;

                when ShiftOutA2 =>
                    QCLK <= '1';
                    State <= ShiftOutD;
                    
                when ShiftOutD =>
                    if ClockDiv = 0 then
                        QCLK <= '0';
                        ClockDiv <= to_integer(unsigned(CTL_REG(12 downto 8)));
                        --State <= ShiftOutA3;
                        State <= ShiftOutD2;
                    else
                        ClockDiv <= ClockDiv - 1;
                    end if;
                    
                --when ShiftOutA3 =>       --delay Rx sasmpling by one S_CLK cycle
                --    DataShiftIn <= DataShiftIn(27 downto 0) & QDdataIn;
                --    State <= ShiftOutD2;
                    
                when ShiftOutD2 =>
                    if ClockDiv = 0 then
                        if ShiftCounter = 0 then
                            --State <= ShiftInCmpl;
                            State <= Idle;
                        else
                            ShiftCounter <= ShiftCounter - 1;
                            QDdataOut <= DataShiftOut(31 downto 28);
                            DataShiftOut <= DataShiftOut(27 downto 0) & "0000";
                            ClockDiv <= to_integer(unsigned(CTL_REG(12 downto 8)));
                            State <= ShiftOutA2;
                        end if;
                    else
                        ClockDiv <= ClockDiv - 1;
                    end if;
                
                --when ShiftInCmpl =>
                --    State <= Idle;
                
                when Idle =>
                    STS_REG <= x"00000001";      --shift ready, clear busy flag
                    RD_REG <= DataShiftIn;
            end case;
        end if;
   end process;

   process(QCLKfb, QDdataIn)
   begin
        if (falling_edge(QCLKfb)) then
            DataShiftIn <= DataShiftIn(27 downto 0) & QDdataIn;
        end if;
   end process;
   
    --QD <= QDdataOut when Direction = '0' else "ZZZZ";
    --QDdataIn <= QDdataOut when Direction = '0' else QD;

end Behavioral;
