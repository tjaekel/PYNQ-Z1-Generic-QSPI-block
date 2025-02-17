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
        --P_CLK : in STD_LOGIC;
        S_CLK : in STD_LOGIC;
        --external signals
        QCLK : out STD_LOGIC;
        QD : inout STD_LOGIC_VECTOR (3 downto 0);
        CS : out STD_LOGIC_VECTOR (3 downto 0);
        --QCLKfb : in STD_LOGIC
        INTn : in STD_LOGIC_VECTOR(5 downto 0);
        GPIO : out STD_LOGIC_VECTOR(6 downto 0)
        --RESn : in STD_LOGIC
      );
end component;

--Inputs
signal WR_REG : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal CTL_REG : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
--signal P_CLK : STD_LOGIC := '0';
signal S_CLK : STD_LOGIC := '0';

--Outputs
signal RD_REG : STD_LOGIC_VECTOR (31 downto 0);
signal STS_REG : STD_LOGIC_VECTOR (31 downto 0);
signal QCLK : STD_LOGIC;
signal QD : STD_LOGIC_VECTOR (3 downto 0);
signal CS : STD_LOGIC_VECTOR (3 downto 0);
--signal QCLKfb : STD_LOGIC;
signal INTn : STD_LOGIC_VECTOR (5 downto 0);
signal GPIO : STD_LOGIC_VECTOR (6 downto 0);
--signal RESn : STD_LOGIC;

signal inCntPattern : STD_LOGIC_VECTOR (3 downto 0) := x"0";
signal RESdone : STD_LOGIC := '0';

constant S_CLK_HALF_PERIOD : TIME := 20 ns;
constant CLK_DIV : integer := 7;
constant CLK_DIV_OFFSET : integer := 1;
constant P_CLK_HALF_PERIOD_H : TIME := S_CLK_HALF_PERIOD * 2 * (CLK_DIV + CLK_DIV_OFFSET);
                                     --our P_CLK half period: S_CLK divded by 2, CLK_DIV = 7 plus 3!
constant P_CLK_HALF_PERIOD_L : TIME := S_CLK_HALF_PERIOD * 2 * (CLK_DIV + CLK_DIV_OFFSET);
constant DLY_FACTOR : INTEGER := 3;  --delay QD response for read to simulate late response

begin

UUT: QSPI_top PORT MAP (
    WR_REG => WR_REG,
    CTL_REG => CTL_REG,
    --P_CLK => P_CLK,
    S_CLK => S_CLK,
    RD_REG => RD_REG,
    STS_REG => STS_REG,
    QCLK => QCLK,
    QD => QD,
    CS => CS,
    --QCLKfb => QCLKfb
    INTn => INTn,
    GPIO => GPIO
    --RESn => RESn
);
 
clock_proc: process
begin
 S_CLK <= '1';
 wait for S_CLK_HALF_PERIOD;        --make it a not-synchronized clock
 S_CLK <= '0';
 wait for S_CLK_HALF_PERIOD;
end process;

--Stimulus process
stim_proc: process
begin

 INTn <= "111111";
 
 if RESdone = '0' then
    -- hold reset state for 100 ns.
    --wait for 100 ns;
    --RESn <= '0';
    wait for P_CLK_HALF_PERIOD_H*4;
    RESdone <= '1';
    wait for S_CLK_HALF_PERIOD * 2;
 --THIS DOES NOT WORK! WHY?
 --else
 --   RESn <= '1';
 --   RESdone <= '1';
 end if;
 
 if RESdone = '1' then
 --RESn <= '1';
  
 wait for P_CLK_HALF_PERIOD_H*4;
 CTL_REG <= x"087F070F";            --all nCS high = "reset"
 wait for P_CLK_HALF_PERIOD_H*4;
 
 -- early nCS low:
 --CTL_REG <= x"087F070E";            --nCS low: same trigger cnt!
 --wait for P_CLK_HALF_PERIOD_H*10;
 
 WR_REG <= x"10010110";             --write CMD: encode properly: 0x96 = b'10010110 (just lane 0)
 CTL_REG <= x"887F770E";            --nCS low, with 7+2 S_CLK cycles before active
 wait for P_CLK_HALF_PERIOD_H*20;
 
 WR_REG <= x"9ABCDEF0";             --32bit address
 CTL_REG <= x"0875070E";            --Test: bit 7 = 1 should flip the bytes
 
 INTn <= "111011";
 wait for P_CLK_HALF_PERIOD_H*20;
 
 --24bit ALT plus 2bit TA
 WR_REG <= x"87654321";             --24bit taken from MSB (lowest 8 bit ignored)
 CTL_REG <= x"4854073E";            --24bit ALT plus 2bit TA
 INTn <= "111101";
 wait for P_CLK_HALF_PERIOD_H*20;
 
 --a 32bit read
 --WR_REG <= x"00000000";             --any value is OK, no need to set
 CTL_REG <= x"084E07CE";              --Test: bit 7 = 1 should flip the bytes
 
 wait for S_CLK_HALF_PERIOD * 1;
 wait for S_CLK_HALF_PERIOD*DLY_FACTOR;      --on TB: consider delay when it becomes active
 QD <= x"A";                        --drive QD signals from outside
 wait for P_CLK_HALF_PERIOD_H;        --wait a full clock cycle on P_CLK!
 QD <= "ZZZZ";
 wait for P_CLK_HALF_PERIOD_L;
 QD <= x"B";
 wait for P_CLK_HALF_PERIOD_H + P_CLK_HALF_PERIOD_L;
 QD <= x"C";
 wait for P_CLK_HALF_PERIOD_H + P_CLK_HALF_PERIOD_L;
 QD <= x"D";
 wait for P_CLK_HALF_PERIOD_H + P_CLK_HALF_PERIOD_L;
 QD <= x"E";
 wait for P_CLK_HALF_PERIOD_H + P_CLK_HALF_PERIOD_L;
 QD <= x"F";
 wait for P_CLK_HALF_PERIOD_H + P_CLK_HALF_PERIOD_L;
 QD <= x"1";
 wait for P_CLK_HALF_PERIOD_H + P_CLK_HALF_PERIOD_L;
 QD <= inCntPattern;
 inCntPattern <= inCntPattern + '1';
 INTn <= "111110";
 wait for P_CLK_HALF_PERIOD_H;
 QD <= "ZZZZ";
 
 wait for P_CLK_HALF_PERIOD_H;
 QD <= "ZZZZ";                      --release external QSPI bus

 --WR_REG  <= x"00000000";          --any value is OK, no need to set
 --CTL_REG <= x"0800070F";            --nCS high - do not increment counter b31:30
 --wait for P_CLK_HALF_PERIOD_H*4;
 end if;
end process;

--QCLKfb <= QCLK after S_CLK_HALF_PERIOD*DLY_FACTOR;

end Behavioral;
