--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: pal_tb                                                      |--
--| Description: Testbench for module pal                                    |--
--|                                                                          |--
--|==========================================================================|--
--| 20/12/2020 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity pal_tb is
end pal_tb;

architecture Behavioral of pal_tb is
   --|=======================================================================|--
   --| External entities
   --|=======================================================================|--
   component pal
   port (
      CLK  : in  std_logic;
      SYNC : out std_logic;
      POSX : out std_logic_vector(10 downto 0);
      POSY : out std_logic_vector(10 downto 0)
   );
   end component pal;
   signal CLK  : std_logic;
   signal SYNC : std_logic;
   signal POSX : std_logic_vector(10 downto 0);
   signal POSY : std_logic_vector(10 downto 0);

   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--

   constant c_CLK_PERIOD : time := 16667 ps;

begin

   pal_i : pal
   port map (
      CLK  => CLK,
      SYNC => SYNC,
      POSX => POSX,
      POSY => POSY
   );

   process begin
      wait;
   end process;

   process begin
      CLK <= '0';
      wait for c_CLK_PERIOD/2;
      CLK <= '1';
      wait for c_CLK_PERIOD/2;
   end process;

   --|=======================================================================|--
   --| Process description
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
      end if;
   end process;

end Behavioral;
