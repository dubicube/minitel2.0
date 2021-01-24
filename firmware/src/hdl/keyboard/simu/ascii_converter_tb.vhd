--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: ascii_converter_tb                                          |--
--| Description: Testbench for module ascii_converter                        |--
--|                                                                          |--
--|==========================================================================|--
--| 24/01/2021 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity ascii_converter_tb is
end ascii_converter_tb;

architecture Behavioral of ascii_converter_tb is
   --|=======================================================================|--
   --| External entities
   --|=======================================================================|--
   component ascii_converter
   port (
      CLK        : in  std_logic;
      KEY_UPDATE : in  std_logic;
      KEY_REG    : in  std_logic_vector(63 downto 0);
      CHAR_VALID : out std_logic;
      CHAR_DATA  : out std_logic_vector(7 downto 0)
   );
   end component ascii_converter;

   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--
   --signal CLK        : std_logic;
   signal KEY_UPDATE : std_logic;
   signal KEY_REG    : std_logic_vector(63 downto 0);
   signal CHAR_VALID : std_logic;
   signal CHAR_DATA  : std_logic_vector(7 downto 0);


   constant c_CLK_PERIOD : time := 10000 ps;

   signal CLK : std_logic;

begin

   ascii_converter_i : ascii_converter
   port map (
      CLK        => CLK,
      KEY_UPDATE => KEY_UPDATE,
      KEY_REG    => KEY_REG,
      CHAR_VALID => CHAR_VALID,
      CHAR_DATA  => CHAR_DATA
   );


   --|=======================================================================|--
   --| Process description
   --|=======================================================================|--
   process begin
      KEY_UPDATE <= '0';
      KEY_REG <= x"FFFFFFFFFFFFFFFF";
      wait for 10 us;

      KEY_UPDATE <= '1';
      KEY_REG <= x"FFFFFFFFFFFFFFFE";
      wait for c_CLK_PERIOD;
      KEY_UPDATE <= '0';
      wait for 10 us;

      KEY_UPDATE <= '1';
      KEY_REG <= x"FFFFFFFFFFFFFFFE";
      wait for c_CLK_PERIOD;
      KEY_UPDATE <= '0';
      wait for 10 us;

      KEY_UPDATE <= '1';
      KEY_REG <= x"FFFFFFFFFFEFFFFF";
      wait for c_CLK_PERIOD;
      KEY_UPDATE <= '0';
      wait for 10 us;
      wait;
   end process;

   --|=======================================================================|--
   --| Process description
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
      end if;
   end process;

   --|=======================================================================|--
   --| Clocks
   --|=======================================================================|--
   process begin
      CLK <= '0';
      wait for c_CLK_PERIOD/2;
      CLK <= '1';
      wait for c_CLK_PERIOD/2;
   end process;

end Behavioral;
