--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: char_drawer_tb                                              |--
--| Description: Testbench for module char_drawer                            |--
--|                                                                          |--
--|==========================================================================|--
--| 06/02/2021 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity char_drawer_tb is
end char_drawer_tb;

architecture Behavioral of char_drawer_tb is
   --|=======================================================================|--
   --| External entities
   --|=======================================================================|--
   component char_drawer
   port (
      BUFFIN_ADDR  : in  std_logic_vector(31 downto 0);
      BUFFIN_DIN   : out std_logic_vector(31 downto 0);
      BUFFIN_DOUT  : in  std_logic_vector(31 downto 0);
      BUFFIN_EN    : in  std_logic;
      BUFFIN_WE    : in  std_logic_vector(3 downto 0);
      BUFFIN_RST   : in  std_logic;
      BUFFIN_CLK   : in  std_logic;
      BUFFOUT_ADDR : out std_logic_vector(31 downto 0);
      BUFFOUT_DIN  : in  std_logic_vector(31 downto 0);
      BUFFOUT_DOUT : out std_logic_vector(31 downto 0);
      BUFFOUT_EN   : out std_logic;
      BUFFOUT_WE   : out std_logic_vector(3 downto 0);
      BUFFOUT_RST  : out std_logic;
      BUFFOUT_CLK  : out std_logic;
      CHAR_VALID   : in  std_logic;
      CHAR_DATA    : in  std_logic_vector(7 downto 0)
   );
   end component char_drawer;
   signal BUFFIN_ADDR  : std_logic_vector(31 downto 0);
   signal BUFFIN_DIN   : std_logic_vector(31 downto 0);
   signal BUFFIN_DOUT  : std_logic_vector(31 downto 0);
   signal BUFFIN_EN    : std_logic;
   signal BUFFIN_WE    : std_logic_vector(3 downto 0);
   signal BUFFIN_RST   : std_logic;
   signal BUFFIN_CLK   : std_logic;
   signal BUFFOUT_ADDR : std_logic_vector(31 downto 0);
   signal BUFFOUT_DIN  : std_logic_vector(31 downto 0);
   signal BUFFOUT_DOUT : std_logic_vector(31 downto 0);
   signal BUFFOUT_EN   : std_logic;
   signal BUFFOUT_WE   : std_logic_vector(3 downto 0);
   signal BUFFOUT_RST  : std_logic;
   signal BUFFOUT_CLK  : std_logic;
   signal CHAR_VALID   : std_logic;
   signal CHAR_DATA    : std_logic_vector(7 downto 0);

   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--

   constant c_CLK_PERIOD : time := 10000 ps;

   signal CLK : std_logic;

begin

   char_drawer_i : char_drawer
   port map (
      BUFFIN_ADDR  => BUFFIN_ADDR,
      BUFFIN_DIN   => BUFFIN_DIN,
      BUFFIN_DOUT  => BUFFIN_DOUT,
      BUFFIN_EN    => BUFFIN_EN,
      BUFFIN_WE    => BUFFIN_WE,
      BUFFIN_RST   => BUFFIN_RST,
      BUFFIN_CLK   => BUFFIN_CLK,
      BUFFOUT_ADDR => BUFFOUT_ADDR,
      BUFFOUT_DIN  => BUFFOUT_DIN,
      BUFFOUT_DOUT => BUFFOUT_DOUT,
      BUFFOUT_EN   => BUFFOUT_EN,
      BUFFOUT_WE   => BUFFOUT_WE,
      BUFFOUT_RST  => BUFFOUT_RST,
      BUFFOUT_CLK  => BUFFOUT_CLK,
      CHAR_VALID   => CHAR_VALID,
      CHAR_DATA    => CHAR_DATA
   );
   BUFFIN_CLK <= CLK;


   --|=======================================================================|--
   --| Process description
   --|=======================================================================|--
   process begin
      CHAR_VALID <= '0';
      CHAR_DATA  <= x"00";
      wait for 10*c_CLK_PERIOD;

      wait for 1*c_CLK_PERIOD;

      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"03";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';

      wait for 20*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"0A";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';

      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"0D";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';

      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"03";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';

      -- Move 2 right
      wait for 50*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"1B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"5B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"32";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"43";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';

      -- Move 1 left
      wait for 50*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"1B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"5B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"31";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"44";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';

      -- Move 2 down
      wait for 50*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"1B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"5B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"32";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"42";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';

      -- Move 1 up
      wait for 50*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"1B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"5B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"31";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"41";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';

      -- Move to (0, 0)
      -- Test without explicit parameters
      wait for 50*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"1B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"5B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"3B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"48";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';

      -- Move to (9, 2)
      -- But we send (10, 3) because the ANSI escape standard expects to start row and columns at 1
      wait for 50*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"1B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"5B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"31";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"30";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"3B";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"33";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"48";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';

      -- Print 'C'
      wait for 10*c_CLK_PERIOD;
      CHAR_VALID <= '1';
      CHAR_DATA  <= x"43";
      wait for 1*c_CLK_PERIOD;
      CHAR_VALID <= '0';


      wait;
   end process;
   process begin
      BUFFIN_ADDR <= x"00000000";
      BUFFIN_DOUT <= x"00000000";
      BUFFIN_EN   <= '0';
      BUFFIN_WE   <= "0000";
      BUFFIN_RST  <= '0';

      BUFFOUT_DIN <= x"00000000";

      wait for 10*c_CLK_PERIOD;

      BUFFIN_ADDR <= x"00000400";
      BUFFIN_DOUT <= x"00360000";
      BUFFIN_EN   <= '1';
      BUFFIN_WE   <= "0001";
      wait for 1*c_CLK_PERIOD;
      BUFFIN_EN   <= '0';
      BUFFIN_WE   <= "0000";

      wait for 10*c_CLK_PERIOD;

      wait for 7*c_CLK_PERIOD;

      -- Collision test
      BUFFIN_EN   <= '1';
      wait for 1*c_CLK_PERIOD;
      BUFFIN_EN   <= '0';


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
