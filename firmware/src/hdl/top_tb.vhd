--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: top                                                         |--
--| Description:                                                             |--
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

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is
   --|=======================================================================|--
   --| External entities
   --|=======================================================================|--


   component pal
   port (
      CLK  : in  std_logic;
      SYNC : out std_logic;
      POSX : out std_logic_vector(11 downto 0);
      POSY : out std_logic_vector(9  downto 0)
   );
   end component pal;

   component active_video_generator
   port (
      CLK      : in  std_logic;
      POSX_IN  : in  std_logic_vector(11 downto 0);
      POSY_IN  : in  std_logic_vector(9  downto 0);
      OE_VIDEO : out std_logic;
      POSX_OUT : out std_logic_vector(11 downto 0);
      POSY_OUT : out std_logic_vector(9  downto 0)
   );
   end component active_video_generator;


   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--

   signal CLK      : std_logic;
   signal POSX_IN  : std_logic_vector(11 downto 0);
   signal POSY_IN  : std_logic_vector(9  downto 0);
   signal OE_VIDEO : std_logic;
   signal POSX_OUT : std_logic_vector(11 downto 0);
   signal POSY_OUT : std_logic_vector(9  downto 0);

   signal s_posx_u : unsigned(11 downto 0);
   signal s_posy_u : unsigned(9  downto 0);

   signal SYNC   : std_logic;
   signal SYNC_d : std_logic;

   signal s_VID_MINITEL_SYNC : std_logic;
   signal s_VID_MINITEL_DATA : std_logic;

   signal VID_MINITEL_SYNC : std_logic;
   signal VID_MINITEL_DATA : std_logic;

   constant c_CLK_PERIOD : time := 16667 ps;

begin

   s_posx_u <= unsigned(POSX_OUT);
   s_posy_u <= unsigned(POSY_OUT);

   --|=======================================================================|--
   --| Minitel video output
   --|=======================================================================|--
   VID_MINITEL_SYNC <= not s_VID_MINITEL_SYNC;
   VID_MINITEL_DATA <= not s_VID_MINITEL_DATA;
   process(CLK) begin
      if rising_edge(CLK) then
         SYNC_d <= SYNC;
         s_VID_MINITEL_SYNC <= SYNC_d;
         if (OE_VIDEO = '0') then
            s_VID_MINITEL_DATA <= '0';
         else
            if (s_posx_u(s_posx_u'left downto 2) > s_posy_u) then
               s_VID_MINITEL_DATA <= '0';
            else
               s_VID_MINITEL_DATA <= '1';
            end if;
         end if;
      end if;
   end process;


   pal_i : pal
   port map (
      CLK  => CLK,
      SYNC => SYNC,
      POSX => POSX_IN,
      POSY => POSY_IN
   );
   active_video_generator_i : active_video_generator
   port map (
      CLK      => CLK,
      POSX_IN  => POSX_IN,
      POSY_IN  => POSY_IN,
      OE_VIDEO => OE_VIDEO,
      POSX_OUT => POSX_OUT,
      POSY_OUT => POSY_OUT
   );

   process begin
      CLK <= '0';
      wait for c_CLK_PERIOD/2;
      CLK <= '1';
      wait for c_CLK_PERIOD/2;
   end process;

end Behavioral;
