----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/01/2024 10:59:45 AM
-- Design Name: 
-- Module Name: QSPI_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity QSPI_top is
    Port ( --internal signals
           WR_REG : in STD_LOGIC_VECTOR (31 downto 0);
           RD_REG : out STD_LOGIC_VECTOR (31 downto 0);
           CTL_REG : in STD_LOGIC_VECTOR (31 downto 0);
           STS_REG : out STD_LOGIC_VECTOR (31 downto 0);
           P_CLK : in STD_LOGIC;
           -- external output/input signals
           QCLK : out STD_LOGIC;
           QD : inout STD_LOGIC_VECTOR (3 downto 0);
           CS : out STD_LOGIC_VECTOR (3 downto 0);
           QCLKfb : in STD_LOGIC
         );
end QSPI_top;

architecture Behavioral of QSPI_top is

type t_State is (WriteStrobe, ShiftOutA, ShiftOutB, ShiftInCmpl, Idle);
signal State : t_State := Idle;

signal DataShiftOut : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal DataShiftIn : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal ShiftCounter : integer range 0 to 7 := 7;
signal QDdataOut : STD_LOGIC_VECTOR(3 downto 0);
signal QDdataIn : STD_LOGIC_VECTOR(3 downto 0);
signal Direction : STD_LOGIC := '1';    -- '1' is input, '0' is output

begin

IOBUF_QD0 : IOBUF
generic map (
   DRIVE => 12,
   IOSTANDARD => "DEFAULT",
   SLEW => "SLOW")
port map (
   O => QDdataIn(0),     -- Buffer output
   IO => QD(0),           -- Buffer inout port (connect directly to top-level port)
   I => QDdataOut(0),      -- Buffer input
   T => Direction         -- 3-state enable input, high=input, low=output
);

IOBUF_QD1 : IOBUF
generic map (
   DRIVE => 12,
   IOSTANDARD => "DEFAULT",
   SLEW => "SLOW")
port map (
   O => QDdataIn(1),     -- Buffer output
   IO => QD(1),           -- Buffer inout port (connect directly to top-level port)
   I => QDdataOut(1),      -- Buffer input
   T => Direction         -- 3-state enable input, high=input, low=output
);

IOBUF_QD2 : IOBUF
generic map (
   DRIVE => 12,
   IOSTANDARD => "DEFAULT",
   SLEW => "SLOW")
port map (
   O => QDdataIn(2),     -- Buffer output
   IO => QD(2),           -- Buffer inout port (connect directly to top-level port)
   I => QDdataOut(2),      -- Buffer input
   T => Direction         -- 3-state enable input, high=input, low=output
);

IOBUF_QD3 : IOBUF
generic map (
   DRIVE => 12,
   IOSTANDARD => "DEFAULT",
   SLEW => "SLOW")
port map (
   O => QDdataIn(3),     -- Buffer output
   IO => QD(3),           -- Buffer inout port (connect directly to top-level port)
   I => QDdataOut(3),      -- Buffer input
   T => Direction         -- 3-state enable input, high=input, low=output
);

    process(P_CLK)
    begin
        if (rising_edge(P_CLK)) then
            CS <= CTL_REG(3 downto 0);                  --drive nCS
            if CTL_REG(31) = '1' then
                QCLK <= '0';
                State <= WriteStrobe;
                STS_REG <= x"80000000";                 --set busy flag
            end if;
            
            case State is
                when WriteStrobe =>
                    if CTL_REG(31) = '0' then
                        DataShiftOut <= WR_REG;
                        ShiftCounter <= 7;              --default
                        Direction <= '0';
                        if CTL_REG(4) = '1' then
                            ShiftCounter <= 5;          --24bit value (ALT)
                        end if;
                        if CTL_REG(5) = '1' then
                            ShiftCounter <= 1;          --two turnaround bits
                            --Direction <= '0';
                            Direction <= '1';
                        end if;
                        if CTL_REG(6) = '1' then
                            ShiftCounter <= 7;          --32bit word read
                            Direction <= '1';
                        end if;
                        --we could use (7) for little endian write and read
                        State <= ShiftOutA;
                        STS_REG(31) <= '0';             --clear busy flag
                    end if;
                
                when ShiftOutA =>
                    QDdataOut <= DataShiftOut(31 downto 28);
                    DataShiftOut <= DataShiftOut(27 downto 0) & "0000";
                    QCLK <= '1';
                    State <= ShiftOutB;
                    
                when ShiftOutB =>
                    QCLK <= '0';
                    State <= ShiftOutA;
                    
                    if ShiftCounter = 0 then
                        State <= ShiftInCmpl;
                    else
                        ShiftCounter <= ShiftCounter - 1;
                    end if;
                
                when ShiftInCmpl =>
                    STS_REG <= x"00000001";               --shift ready, clear busy flag
                    State <= Idle;
                
                when Idle =>
                    RD_REG <= DataShiftIn;
                    
            end case;
        end if;
    end process;
    
   process(QCLKfb, State, DataShiftIn)
   begin
        if (falling_edge(QCLKfb)) then
            DataShiftIn(31 downto 4) <= DataShiftIn(27 downto 0);
            DataShiftIn(3 downto 0) <= QDdataIn;
        end if;
        --if (State = Idle) then
        --    RD_REG <= DataShiftIn;                #it would create a latch!
        --end if;
        if (State = WriteStrobe) then
            DataShiftIn <= (others => '0');
        end if;
   end process;
    
    --QD <= QDdataOut when Direction = '0' else "ZZZZ";
    --QDdataIn <= QDdataOut when Direction = '0' else QD;

end Behavioral;
