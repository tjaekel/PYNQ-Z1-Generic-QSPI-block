----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2024 10:55:40 AM
-- Design Name: 
-- Module Name: QSPI_top_tb - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity QSPI_top_tb is
end QSPI_top_tb;

architecture Behavioral of QSPI_top_tb is

component QSPI_top
port (
        --internal signals
        WR_REG : in STD_LOGIC_VECTOR (31 downto 0);
        RD_REG : out STD_LOGIC_VECTOR (31 downto 0);
        CTL_REG : in STD_LOGIC_VECTOR (31 downto 0);
        STS_REG : out STD_LOGIC_VECTOR (31 downto 0);
        P_CLK : in STD_LOGIC;
        --external signals
        QCLK : out STD_LOGIC;
        QD : inout STD_LOGIC_VECTOR (3 downto 0);
        CS : out STD_LOGIC_VECTOR (3 downto 0);
        QCLKfb : in STD_LOGIC
      );
end component;

--Inputs
signal WR_REG : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal CTL_REG : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
signal P_CLK : STD_LOGIC := '0';

--Outputs
signal RD_REG : STD_LOGIC_VECTOR (31 downto 0);
signal STS_REG : STD_LOGIC_VECTOR (31 downto 0);
signal QCLK : STD_LOGIC;
signal QD : STD_LOGIC_VECTOR (3 downto 0);
signal CS : STD_LOGIC_VECTOR (3 downto 0);
signal QCLKfb : STD_LOGIC;

signal inCntPattern : STD_LOGIC_VECTOR (3 downto 0) := x"0";

constant P_CLK_HALF_PERIOD : TIME := 13 ns;    --our P_CLK half period

begin

UUT: QSPI_top PORT MAP (
    WR_REG => WR_REG,
    CTL_REG => CTL_REG,
    P_CLK => P_CLK,
    RD_REG => RD_REG,
    STS_REG => STS_REG,
    QCLK => QCLK,
    QD => QD,
    CS => CS,
    QCLKfb => QCLKfb
);

clock_proc: process
begin
 P_CLK <= '1';
 wait for P_CLK_HALF_PERIOD;        --make it a not-synchronized clock
 P_CLK <= '0';
 wait for P_CLK_HALF_PERIOD;
end process;

--Stimulus process
stim_proc: process
begin
 -- hold reset state for 100 ns.
 --wait for 100 ns;

 WR_REG <= x"10010110";             --write CMD: encode properly: 0x96 = b'10010110 (just lane 0)
 CTL_REG <= x"8000000E";            --nCS low
 wait for P_CLK_HALF_PERIOD*3;
 CTL_REG <= x"0000000E";            --nCS low
 wait for 500 ns;
 
 WR_REG <= x"9ABCDEF0";             --32bit address
 CTL_REG <= x"8000000E";
 wait for P_CLK_HALF_PERIOD*3;
 CTL_REG <= x"0000000E";
 wait for 500 ns;
 
 --a 24bit write
 WR_REG <= x"87654321";             --24bit taken from MSB (lowest 8 bit ignored)
 CTL_REG <= x"8000000E";
 wait for P_CLK_HALF_PERIOD*3;
 CTL_REG <= x"0000001E";            --set 24bit word size to write
 wait for 500 ns;
 
 --a 2bit turnaround
 WR_REG <= x"ABCDEF01";             --any value is OK, no need to set
 CTL_REG <= x"8000000E";
 wait for P_CLK_HALF_PERIOD*3;
 CTL_REG <= x"0000002E";            --set turnaround bit and generate two turnaround cycles
 wait for P_CLK_HALF_PERIOD*12;
 
  --a 32bit read
 WR_REG <= x"00000000";             --any value is OK, no need to set
 CTL_REG <= x"8000000E";
 wait for P_CLK_HALF_PERIOD*3;
 CTL_REG <= x"0000004E";            --set 32bit read
 
 wait for P_CLK_HALF_PERIOD*5;      --on TB: consider delay when it becomes active
 QD <= x"A";                        --drive QD signals from outside
 wait for P_CLK_HALF_PERIOD*4;      --wait a full clock cycle on P_CLK!
 QD <= x"B";
 wait for P_CLK_HALF_PERIOD*4;
 QD <= x"C";
 wait for P_CLK_HALF_PERIOD*4;
 QD <= x"D";
 wait for P_CLK_HALF_PERIOD*4;
 QD <= x"E";
 wait for P_CLK_HALF_PERIOD*4;
 QD <= x"F";
 wait for P_CLK_HALF_PERIOD*4;
 QD <= x"1";
 wait for P_CLK_HALF_PERIOD*4;
 --QD <= x"2";
 QD <= inCntPattern;
 inCntPattern <= inCntPattern + '1';
 wait for P_CLK_HALF_PERIOD*4;
 QD <= "ZZZZ";                      --release external QSPI bus
 --wait for P_CLK_HALF_PERIOD;

 WR_REG <= x"00000000";             --any value is OK, no need to set
 CTL_REG <= x"0000000F";            --nCS high
 wait for P_CLK_HALF_PERIOD*6;
end process;

QCLKfb <= QCLK after P_CLK_HALF_PERIOD*2;

end Behavioral;
