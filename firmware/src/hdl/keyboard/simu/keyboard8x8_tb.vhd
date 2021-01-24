--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: keyboard8x8_tb                                              |--
--| Description: Testbench for module keyboard8x8                            |--
--|                                                                          |--
--|==========================================================================|--
--| 28/12/2020 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity keyboard8x8_tb is
end keyboard8x8_tb;

architecture Behavioral of keyboard8x8_tb is
   --|=======================================================================|--
   --| External entities
   --|=======================================================================|--
   component keyboard8x8
   port (
      CLK     : in  std_logic;
      KEY_REG : out std_logic_vector(63 downto 0);
      OUTPUTK : out std_logic_vector(7 downto 0);
      INPUTK  : in  std_logic_vector(7 downto 0)
   );
   end component keyboard8x8;
   --signal CLK     : std_logic;
   signal KEY_REG : std_logic_vector(63 downto 0);
   signal OUTPUTK : std_logic_vector(7 downto 0);
   signal INPUTK  : std_logic_vector(7 downto 0);

   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--

   signal s_INPUTK  : std_logic_vector(7 downto 0);

   constant c_CLK_PERIOD : time := 10000 ps;

   signal CLK : std_logic;

begin
   keyboard8x8_i : keyboard8x8
   port map (
      CLK     => CLK,
      KEY_REG => KEY_REG,
      OUTPUTK => OUTPUTK,
      INPUTK  => INPUTK
   );

   s_INPUTK <= (others => 'H'); -- Weak pull up

   s_INPUTK(0) <= OUTPUTK(0);

   GEN_OUT : for I in 0 to 7 generate
      INPUTK(I) <= '0' when s_INPUTK(I)='0' else '1';
   end generate GEN_OUT;
   -- Nice

   --|=======================================================================|--
   --| Process description
   --|=======================================================================|--
   process begin
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
