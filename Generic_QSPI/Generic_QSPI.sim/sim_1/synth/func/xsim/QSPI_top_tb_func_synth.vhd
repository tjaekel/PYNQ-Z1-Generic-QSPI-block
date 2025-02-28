-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
-- Date        : Wed Feb 19 19:24:48 2025
-- Host        : LAPTOP-TJAEKEL2 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -mode funcsim -nolib -force -file
--               C:/Users/tj/Documents/Xilinx_Projects/Generic_QSPI/Generic_QSPI.sim/sim_1/synth/func/xsim/QSPI_top_tb_func_synth.vhd
-- Design      : QSPI_top
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity QSPI_top is
  port (
    WR_REG : in STD_LOGIC_VECTOR ( 31 downto 0 );
    RD_REG : out STD_LOGIC_VECTOR ( 31 downto 0 );
    WR_EN : in STD_LOGIC;
    RD_RDY : out STD_LOGIC;
    QCLK : out STD_LOGIC;
    QD : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    P_CLK : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of QSPI_top : entity is true;
end QSPI_top;

architecture STRUCTURE of QSPI_top is
  signal DataShiftIn : STD_LOGIC;
  signal \DataShiftIn_reg_n_0_[28]\ : STD_LOGIC;
  signal \DataShiftIn_reg_n_0_[29]\ : STD_LOGIC;
  signal \DataShiftIn_reg_n_0_[30]\ : STD_LOGIC;
  signal \DataShiftIn_reg_n_0_[31]\ : STD_LOGIC;
  signal \FSM_onehot_State[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_State[2]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_State[4]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_State[4]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_onehot_State_reg_n_0_[0]\ : STD_LOGIC;
  signal \FSM_onehot_State_reg_n_0_[1]\ : STD_LOGIC;
  signal \FSM_onehot_State_reg_n_0_[2]\ : STD_LOGIC;
  signal \FSM_onehot_State_reg_n_0_[4]\ : STD_LOGIC;
  signal P_CLK_IBUF : STD_LOGIC;
  signal P_CLK_IBUF_BUFG : STD_LOGIC;
  signal QCLK_OBUF : STD_LOGIC;
  signal QCLK_i_1_n_0 : STD_LOGIC;
  signal QD_IBUF : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal RD_RDY_OBUF : STD_LOGIC;
  signal RD_RDY_i_1_n_0 : STD_LOGIC;
  signal RD_REG_OBUF : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \ShiftCounter[0]_i_1_n_0\ : STD_LOGIC;
  signal \ShiftCounter[1]_i_1_n_0\ : STD_LOGIC;
  signal \ShiftCounter[2]_i_1_n_0\ : STD_LOGIC;
  signal \ShiftCounter_reg_n_0_[0]\ : STD_LOGIC;
  signal \ShiftCounter_reg_n_0_[1]\ : STD_LOGIC;
  signal \ShiftCounter_reg_n_0_[2]\ : STD_LOGIC;
  signal WR_EN_IBUF : STD_LOGIC;
  signal p_0_in : STD_LOGIC_VECTOR ( 31 downto 4 );
  attribute FSM_ENCODED_STATES : string;
  attribute FSM_ENCODED_STATES of \FSM_onehot_State_reg[0]\ : label is "shiftoutb:01000,idle:00001,writestrobe:00010,shiftouta:00100,shiftincmpl:10000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_State_reg[1]\ : label is "shiftoutb:01000,idle:00001,writestrobe:00010,shiftouta:00100,shiftincmpl:10000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_State_reg[2]\ : label is "shiftoutb:01000,idle:00001,writestrobe:00010,shiftouta:00100,shiftincmpl:10000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_State_reg[3]\ : label is "shiftoutb:01000,idle:00001,writestrobe:00010,shiftouta:00100,shiftincmpl:10000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_State_reg[4]\ : label is "shiftoutb:01000,idle:00001,writestrobe:00010,shiftouta:00100,shiftincmpl:10000";
begin
\DataShiftIn_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => QD_IBUF(0),
      Q => p_0_in(4),
      R => '0'
    );
\DataShiftIn_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(10),
      Q => p_0_in(14),
      R => '0'
    );
\DataShiftIn_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(11),
      Q => p_0_in(15),
      R => '0'
    );
\DataShiftIn_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(12),
      Q => p_0_in(16),
      R => '0'
    );
\DataShiftIn_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(13),
      Q => p_0_in(17),
      R => '0'
    );
\DataShiftIn_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(14),
      Q => p_0_in(18),
      R => '0'
    );
\DataShiftIn_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(15),
      Q => p_0_in(19),
      R => '0'
    );
\DataShiftIn_reg[16]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(16),
      Q => p_0_in(20),
      R => '0'
    );
\DataShiftIn_reg[17]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(17),
      Q => p_0_in(21),
      R => '0'
    );
\DataShiftIn_reg[18]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(18),
      Q => p_0_in(22),
      R => '0'
    );
\DataShiftIn_reg[19]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(19),
      Q => p_0_in(23),
      R => '0'
    );
\DataShiftIn_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => QD_IBUF(1),
      Q => p_0_in(5),
      R => '0'
    );
\DataShiftIn_reg[20]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(20),
      Q => p_0_in(24),
      R => '0'
    );
\DataShiftIn_reg[21]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(21),
      Q => p_0_in(25),
      R => '0'
    );
\DataShiftIn_reg[22]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(22),
      Q => p_0_in(26),
      R => '0'
    );
\DataShiftIn_reg[23]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(23),
      Q => p_0_in(27),
      R => '0'
    );
\DataShiftIn_reg[24]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(24),
      Q => p_0_in(28),
      R => '0'
    );
\DataShiftIn_reg[25]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(25),
      Q => p_0_in(29),
      R => '0'
    );
\DataShiftIn_reg[26]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(26),
      Q => p_0_in(30),
      R => '0'
    );
\DataShiftIn_reg[27]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(27),
      Q => p_0_in(31),
      R => '0'
    );
\DataShiftIn_reg[28]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(28),
      Q => \DataShiftIn_reg_n_0_[28]\,
      R => '0'
    );
\DataShiftIn_reg[29]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(29),
      Q => \DataShiftIn_reg_n_0_[29]\,
      R => '0'
    );
\DataShiftIn_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => QD_IBUF(2),
      Q => p_0_in(6),
      R => '0'
    );
\DataShiftIn_reg[30]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(30),
      Q => \DataShiftIn_reg_n_0_[30]\,
      R => '0'
    );
\DataShiftIn_reg[31]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(31),
      Q => \DataShiftIn_reg_n_0_[31]\,
      R => '0'
    );
\DataShiftIn_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => QD_IBUF(3),
      Q => p_0_in(7),
      R => '0'
    );
\DataShiftIn_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(4),
      Q => p_0_in(8),
      R => '0'
    );
\DataShiftIn_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(5),
      Q => p_0_in(9),
      R => '0'
    );
\DataShiftIn_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(6),
      Q => p_0_in(10),
      R => '0'
    );
\DataShiftIn_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(7),
      Q => p_0_in(11),
      R => '0'
    );
\DataShiftIn_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(8),
      Q => p_0_in(12),
      R => '0'
    );
\DataShiftIn_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => DataShiftIn,
      D => p_0_in(9),
      Q => p_0_in(13),
      R => '0'
    );
\FSM_onehot_State[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"EA"
    )
        port map (
      I0 => \FSM_onehot_State_reg_n_0_[0]\,
      I1 => WR_EN_IBUF,
      I2 => \FSM_onehot_State_reg_n_0_[1]\,
      O => \FSM_onehot_State[1]_i_1_n_0\
    );
\FSM_onehot_State[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFF444444444"
    )
        port map (
      I0 => WR_EN_IBUF,
      I1 => \FSM_onehot_State_reg_n_0_[1]\,
      I2 => \ShiftCounter_reg_n_0_[1]\,
      I3 => \ShiftCounter_reg_n_0_[0]\,
      I4 => \ShiftCounter_reg_n_0_[2]\,
      I5 => DataShiftIn,
      O => \FSM_onehot_State[2]_i_1_n_0\
    );
\FSM_onehot_State[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFEEE"
    )
        port map (
      I0 => \FSM_onehot_State_reg_n_0_[4]\,
      I1 => \FSM_onehot_State_reg_n_0_[1]\,
      I2 => WR_EN_IBUF,
      I3 => \FSM_onehot_State_reg_n_0_[0]\,
      I4 => DataShiftIn,
      I5 => \FSM_onehot_State_reg_n_0_[2]\,
      O => \FSM_onehot_State[4]_i_1_n_0\
    );
\FSM_onehot_State[4]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0002"
    )
        port map (
      I0 => DataShiftIn,
      I1 => \ShiftCounter_reg_n_0_[2]\,
      I2 => \ShiftCounter_reg_n_0_[0]\,
      I3 => \ShiftCounter_reg_n_0_[1]\,
      O => \FSM_onehot_State[4]_i_2_n_0\
    );
\FSM_onehot_State_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State[4]_i_1_n_0\,
      D => \FSM_onehot_State_reg_n_0_[4]\,
      Q => \FSM_onehot_State_reg_n_0_[0]\,
      R => '0'
    );
\FSM_onehot_State_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State[4]_i_1_n_0\,
      D => \FSM_onehot_State[1]_i_1_n_0\,
      Q => \FSM_onehot_State_reg_n_0_[1]\,
      R => '0'
    );
\FSM_onehot_State_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State[4]_i_1_n_0\,
      D => \FSM_onehot_State[2]_i_1_n_0\,
      Q => \FSM_onehot_State_reg_n_0_[2]\,
      R => '0'
    );
\FSM_onehot_State_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State[4]_i_1_n_0\,
      D => \FSM_onehot_State_reg_n_0_[2]\,
      Q => DataShiftIn,
      R => '0'
    );
\FSM_onehot_State_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State[4]_i_1_n_0\,
      D => \FSM_onehot_State[4]_i_2_n_0\,
      Q => \FSM_onehot_State_reg_n_0_[4]\,
      R => '0'
    );
P_CLK_IBUF_BUFG_inst: unisim.vcomponents.BUFG
     port map (
      I => P_CLK_IBUF,
      O => P_CLK_IBUF_BUFG
    );
P_CLK_IBUF_inst: unisim.vcomponents.IBUF
     port map (
      I => P_CLK,
      O => P_CLK_IBUF
    );
QCLK_OBUF_inst: unisim.vcomponents.OBUF
     port map (
      I => QCLK_OBUF,
      O => QCLK
    );
QCLK_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFEEEEEEEC"
    )
        port map (
      I0 => WR_EN_IBUF,
      I1 => \FSM_onehot_State_reg_n_0_[2]\,
      I2 => \FSM_onehot_State_reg_n_0_[4]\,
      I3 => \FSM_onehot_State_reg_n_0_[0]\,
      I4 => \FSM_onehot_State_reg_n_0_[1]\,
      I5 => DataShiftIn,
      O => QCLK_i_1_n_0
    );
QCLK_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => QCLK_i_1_n_0,
      D => \FSM_onehot_State_reg_n_0_[2]\,
      Q => QCLK_OBUF,
      R => '0'
    );
\QD_IBUF[0]_inst\: unisim.vcomponents.IBUF
     port map (
      I => QD(0),
      O => QD_IBUF(0)
    );
\QD_IBUF[1]_inst\: unisim.vcomponents.IBUF
     port map (
      I => QD(1),
      O => QD_IBUF(1)
    );
\QD_IBUF[2]_inst\: unisim.vcomponents.IBUF
     port map (
      I => QD(2),
      O => QD_IBUF(2)
    );
\QD_IBUF[3]_inst\: unisim.vcomponents.IBUF
     port map (
      I => QD(3),
      O => QD_IBUF(3)
    );
RD_RDY_OBUF_inst: unisim.vcomponents.OBUF
     port map (
      I => RD_RDY_OBUF,
      O => RD_RDY
    );
RD_RDY_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FAFAFAFAFAFAFAF8"
    )
        port map (
      I0 => WR_EN_IBUF,
      I1 => \FSM_onehot_State_reg_n_0_[2]\,
      I2 => \FSM_onehot_State_reg_n_0_[4]\,
      I3 => \FSM_onehot_State_reg_n_0_[0]\,
      I4 => \FSM_onehot_State_reg_n_0_[1]\,
      I5 => DataShiftIn,
      O => RD_RDY_i_1_n_0
    );
RD_RDY_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => RD_RDY_i_1_n_0,
      D => \FSM_onehot_State_reg_n_0_[4]\,
      Q => RD_RDY_OBUF,
      R => '0'
    );
\RD_REG_OBUF[0]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(0),
      O => RD_REG(0)
    );
\RD_REG_OBUF[10]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(10),
      O => RD_REG(10)
    );
\RD_REG_OBUF[11]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(11),
      O => RD_REG(11)
    );
\RD_REG_OBUF[12]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(12),
      O => RD_REG(12)
    );
\RD_REG_OBUF[13]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(13),
      O => RD_REG(13)
    );
\RD_REG_OBUF[14]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(14),
      O => RD_REG(14)
    );
\RD_REG_OBUF[15]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(15),
      O => RD_REG(15)
    );
\RD_REG_OBUF[16]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(16),
      O => RD_REG(16)
    );
\RD_REG_OBUF[17]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(17),
      O => RD_REG(17)
    );
\RD_REG_OBUF[18]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(18),
      O => RD_REG(18)
    );
\RD_REG_OBUF[19]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(19),
      O => RD_REG(19)
    );
\RD_REG_OBUF[1]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(1),
      O => RD_REG(1)
    );
\RD_REG_OBUF[20]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(20),
      O => RD_REG(20)
    );
\RD_REG_OBUF[21]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(21),
      O => RD_REG(21)
    );
\RD_REG_OBUF[22]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(22),
      O => RD_REG(22)
    );
\RD_REG_OBUF[23]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(23),
      O => RD_REG(23)
    );
\RD_REG_OBUF[24]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(24),
      O => RD_REG(24)
    );
\RD_REG_OBUF[25]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(25),
      O => RD_REG(25)
    );
\RD_REG_OBUF[26]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(26),
      O => RD_REG(26)
    );
\RD_REG_OBUF[27]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(27),
      O => RD_REG(27)
    );
\RD_REG_OBUF[28]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(28),
      O => RD_REG(28)
    );
\RD_REG_OBUF[29]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(29),
      O => RD_REG(29)
    );
\RD_REG_OBUF[2]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(2),
      O => RD_REG(2)
    );
\RD_REG_OBUF[30]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(30),
      O => RD_REG(30)
    );
\RD_REG_OBUF[31]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(31),
      O => RD_REG(31)
    );
\RD_REG_OBUF[3]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(3),
      O => RD_REG(3)
    );
\RD_REG_OBUF[4]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(4),
      O => RD_REG(4)
    );
\RD_REG_OBUF[5]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(5),
      O => RD_REG(5)
    );
\RD_REG_OBUF[6]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(6),
      O => RD_REG(6)
    );
\RD_REG_OBUF[7]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(7),
      O => RD_REG(7)
    );
\RD_REG_OBUF[8]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(8),
      O => RD_REG(8)
    );
\RD_REG_OBUF[9]_inst\: unisim.vcomponents.OBUF
     port map (
      I => RD_REG_OBUF(9),
      O => RD_REG(9)
    );
\RD_REG_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(4),
      Q => RD_REG_OBUF(0),
      R => '0'
    );
\RD_REG_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(14),
      Q => RD_REG_OBUF(10),
      R => '0'
    );
\RD_REG_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(15),
      Q => RD_REG_OBUF(11),
      R => '0'
    );
\RD_REG_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(16),
      Q => RD_REG_OBUF(12),
      R => '0'
    );
\RD_REG_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(17),
      Q => RD_REG_OBUF(13),
      R => '0'
    );
\RD_REG_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(18),
      Q => RD_REG_OBUF(14),
      R => '0'
    );
\RD_REG_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(19),
      Q => RD_REG_OBUF(15),
      R => '0'
    );
\RD_REG_reg[16]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(20),
      Q => RD_REG_OBUF(16),
      R => '0'
    );
\RD_REG_reg[17]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(21),
      Q => RD_REG_OBUF(17),
      R => '0'
    );
\RD_REG_reg[18]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(22),
      Q => RD_REG_OBUF(18),
      R => '0'
    );
\RD_REG_reg[19]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(23),
      Q => RD_REG_OBUF(19),
      R => '0'
    );
\RD_REG_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(5),
      Q => RD_REG_OBUF(1),
      R => '0'
    );
\RD_REG_reg[20]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(24),
      Q => RD_REG_OBUF(20),
      R => '0'
    );
\RD_REG_reg[21]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(25),
      Q => RD_REG_OBUF(21),
      R => '0'
    );
\RD_REG_reg[22]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(26),
      Q => RD_REG_OBUF(22),
      R => '0'
    );
\RD_REG_reg[23]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(27),
      Q => RD_REG_OBUF(23),
      R => '0'
    );
\RD_REG_reg[24]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(28),
      Q => RD_REG_OBUF(24),
      R => '0'
    );
\RD_REG_reg[25]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(29),
      Q => RD_REG_OBUF(25),
      R => '0'
    );
\RD_REG_reg[26]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(30),
      Q => RD_REG_OBUF(26),
      R => '0'
    );
\RD_REG_reg[27]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(31),
      Q => RD_REG_OBUF(27),
      R => '0'
    );
\RD_REG_reg[28]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => \DataShiftIn_reg_n_0_[28]\,
      Q => RD_REG_OBUF(28),
      R => '0'
    );
\RD_REG_reg[29]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => \DataShiftIn_reg_n_0_[29]\,
      Q => RD_REG_OBUF(29),
      R => '0'
    );
\RD_REG_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(6),
      Q => RD_REG_OBUF(2),
      R => '0'
    );
\RD_REG_reg[30]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => \DataShiftIn_reg_n_0_[30]\,
      Q => RD_REG_OBUF(30),
      R => '0'
    );
\RD_REG_reg[31]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => \DataShiftIn_reg_n_0_[31]\,
      Q => RD_REG_OBUF(31),
      R => '0'
    );
\RD_REG_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(7),
      Q => RD_REG_OBUF(3),
      R => '0'
    );
\RD_REG_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(8),
      Q => RD_REG_OBUF(4),
      R => '0'
    );
\RD_REG_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(9),
      Q => RD_REG_OBUF(5),
      R => '0'
    );
\RD_REG_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(10),
      Q => RD_REG_OBUF(6),
      R => '0'
    );
\RD_REG_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(11),
      Q => RD_REG_OBUF(7),
      R => '0'
    );
\RD_REG_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(12),
      Q => RD_REG_OBUF(8),
      R => '0'
    );
\RD_REG_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => \FSM_onehot_State_reg_n_0_[4]\,
      D => p_0_in(13),
      Q => RD_REG_OBUF(9),
      R => '0'
    );
\ShiftCounter[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFCCF4FF44FF44"
    )
        port map (
      I0 => WR_EN_IBUF,
      I1 => \FSM_onehot_State_reg_n_0_[1]\,
      I2 => \ShiftCounter_reg_n_0_[2]\,
      I3 => \ShiftCounter_reg_n_0_[0]\,
      I4 => \ShiftCounter_reg_n_0_[1]\,
      I5 => DataShiftIn,
      O => \ShiftCounter[0]_i_1_n_0\
    );
\ShiftCounter[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFCCCCF4FFFF4444"
    )
        port map (
      I0 => WR_EN_IBUF,
      I1 => \FSM_onehot_State_reg_n_0_[1]\,
      I2 => \ShiftCounter_reg_n_0_[2]\,
      I3 => \ShiftCounter_reg_n_0_[0]\,
      I4 => \ShiftCounter_reg_n_0_[1]\,
      I5 => DataShiftIn,
      O => \ShiftCounter[1]_i_1_n_0\
    );
\ShiftCounter[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FCFCFCC4F4F4F4F4"
    )
        port map (
      I0 => WR_EN_IBUF,
      I1 => \FSM_onehot_State_reg_n_0_[1]\,
      I2 => \ShiftCounter_reg_n_0_[2]\,
      I3 => \ShiftCounter_reg_n_0_[0]\,
      I4 => \ShiftCounter_reg_n_0_[1]\,
      I5 => DataShiftIn,
      O => \ShiftCounter[2]_i_1_n_0\
    );
\ShiftCounter_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => '1',
      D => \ShiftCounter[0]_i_1_n_0\,
      Q => \ShiftCounter_reg_n_0_[0]\,
      R => '0'
    );
\ShiftCounter_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => '1',
      D => \ShiftCounter[1]_i_1_n_0\,
      Q => \ShiftCounter_reg_n_0_[1]\,
      R => '0'
    );
\ShiftCounter_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => P_CLK_IBUF_BUFG,
      CE => '1',
      D => \ShiftCounter[2]_i_1_n_0\,
      Q => \ShiftCounter_reg_n_0_[2]\,
      R => '0'
    );
WR_EN_IBUF_inst: unisim.vcomponents.IBUF
     port map (
      I => WR_EN,
      O => WR_EN_IBUF
    );
end STRUCTURE;
