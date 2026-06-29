-- ==============================================================
-- File generated on Thu Jun 25 21:35:16 +0700 2026
-- Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2018.3 (64-bit)
-- SW Build 2405991 on Thu Dec  6 23:38:27 MST 2018
-- IP Build 2404404 on Fri Dec  7 01:43:56 MST 2018
-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity fft1d_fixed_TWIDDcud_rom is 
    generic(
             DWIDTH     : integer := 13; 
             AWIDTH     : integer := 5; 
             MEM_SIZE    : integer := 32
    ); 
    port (
          addr0      : in std_logic_vector(AWIDTH-1 downto 0); 
          ce0       : in std_logic; 
          q0         : out std_logic_vector(DWIDTH-1 downto 0);
          clk       : in std_logic
    ); 
end entity; 


architecture rtl of fft1d_fixed_TWIDDcud_rom is 

signal addr0_tmp : std_logic_vector(AWIDTH-1 downto 0); 
type mem_array is array (0 to MEM_SIZE-1) of std_logic_vector (DWIDTH-1 downto 0); 
signal mem : mem_array := (
    0 => "0000000000000", 1 => "1111001101111", 2 => "1110011100001", 
    3 => "1101101011011", 4 => "1100111100001", 5 => "1100001110101", 
    6 => "1011100011100", 7 => "1010111011010", 8 => "1010010110000", 
    9 => "1001110100010", 10 => "1001010110010", 11 => "1000111100100", 
    12 => "1000100111000", 13 => "1000010110000", 14 => "1000001001111", 
    15 => "1000000010100", 16 => "1000000000000", 17 => "1000000010100", 
    18 => "1000001001111", 19 => "1000010110000", 20 => "1000100111000", 
    21 => "1000111100100", 22 => "1001010110010", 23 => "1001110100010", 
    24 => "1010010110000", 25 => "1010111011010", 26 => "1011100011100", 
    27 => "1100001110101", 28 => "1100111100001", 29 => "1101101011011", 
    30 => "1110011100001", 31 => "1111001101111" );

attribute syn_rom_style : string;
attribute syn_rom_style of mem : signal is "select_rom";
attribute ROM_STYLE : string;
attribute ROM_STYLE of mem : signal is "distributed";

begin 


memory_access_guard_0: process (addr0) 
begin
      addr0_tmp <= addr0;
--synthesis translate_off
      if (CONV_INTEGER(addr0) > mem_size-1) then
           addr0_tmp <= (others => '0');
      else 
           addr0_tmp <= addr0;
      end if;
--synthesis translate_on
end process;

p_rom_access: process (clk)  
begin 
    if (clk'event and clk = '1') then
        if (ce0 = '1') then 
            q0 <= mem(CONV_INTEGER(addr0_tmp)); 
        end if;
    end if;
end process;

end rtl;

Library IEEE;
use IEEE.std_logic_1164.all;

entity fft1d_fixed_TWIDDcud is
    generic (
        DataWidth : INTEGER := 13;
        AddressRange : INTEGER := 32;
        AddressWidth : INTEGER := 5);
    port (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        address0 : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
        ce0 : IN STD_LOGIC;
        q0 : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0));
end entity;

architecture arch of fft1d_fixed_TWIDDcud is
    component fft1d_fixed_TWIDDcud_rom is
        port (
            clk : IN STD_LOGIC;
            addr0 : IN STD_LOGIC_VECTOR;
            ce0 : IN STD_LOGIC;
            q0 : OUT STD_LOGIC_VECTOR);
    end component;



begin
    fft1d_fixed_TWIDDcud_rom_U :  component fft1d_fixed_TWIDDcud_rom
    port map (
        clk => clk,
        addr0 => address0,
        ce0 => ce0,
        q0 => q0);

end architecture;


