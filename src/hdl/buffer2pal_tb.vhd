--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: buffer2pal_tb                                               |--
--| Description: Testbench for module buffer2pal                             |--
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

entity buffer2pal_tb is
end buffer2pal_tb;

architecture Behavioral of buffer2pal_tb is
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
   signal PAL_CLK  : std_logic;
   signal PAL_SYNC : std_logic;
   signal PAL_POSX : std_logic_vector(11 downto 0);
   signal PAL_POSY : std_logic_vector(9  downto 0);

   component active_video_generator
   port (
      CLK      : in  std_logic;
      SYNC_IN  : in  std_logic;
      SYNC_OUT : out std_logic;
      POSX_IN  : in  std_logic_vector(11 downto 0);
      POSY_IN  : in  std_logic_vector(9  downto 0);
      OE_VIDEO : out std_logic;
      POSX_OUT : out std_logic_vector(11 downto 0);
      POSY_OUT : out std_logic_vector(9  downto 0)
   );
   end component active_video_generator;
   signal AVG_CLK      : std_logic;
   signal AVG_SYNC_IN  : std_logic;
   signal AVG_SYNC_OUT : std_logic;
   signal AVG_POSX_IN  : std_logic_vector(11 downto 0);
   signal AVG_POSY_IN  : std_logic_vector(9  downto 0);
   signal AVG_OE_VIDEO : std_logic;
   signal AVG_POSX_OUT : std_logic_vector(11 downto 0);
   signal AVG_POSY_OUT : std_logic_vector(9  downto 0);


   component buffer2pal
   port (
      CLK         : in  std_logic;
      SYNC_IN     : in  std_logic;
      SYNC_OUT    : out std_logic;
      VIDEO_DATA  : out std_logic;
      OE_VIDEO    : in  std_logic;
      POSX        : in  std_logic_vector(11 downto 0);
      POSY        : in  std_logic_vector(9  downto 0);
      BUFFER_ADDR : out std_logic_vector(31 downto 0);
      BUFFER_DIN  : in  std_logic_vector(31 downto 0);
      BUFFER_DOUT : out std_logic_vector(31 downto 0);
      BUFFER_EN   : out std_logic;
      BUFFER_WE   : out std_logic_vector(3 downto 0);
      BUFFER_RST  : out std_logic;
      BUFFER_CLK  : out std_logic
   );
   end component buffer2pal;
   signal B2P_CLK         : std_logic;
   signal B2P_SYNC_IN     : std_logic;
   signal B2P_SYNC_OUT    : std_logic;
   signal B2P_VIDEO_DATA  : std_logic;
   signal B2P_OE_VIDEO    : std_logic;
   signal B2P_POSX        : std_logic_vector(11 downto 0);
   signal B2P_POSY        : std_logic_vector(9  downto 0);
   signal B2P_BUFFER_ADDR : std_logic_vector(31 downto 0);
   signal B2P_BUFFER_DIN  : std_logic_vector(31 downto 0);
   signal B2P_BUFFER_DOUT : std_logic_vector(31 downto 0);
   signal B2P_BUFFER_EN   : std_logic;
   signal B2P_BUFFER_WE   : std_logic_vector(3 downto 0);
   signal B2P_BUFFER_RST  : std_logic;
   signal B2P_BUFFER_CLK  : std_logic;

   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--

   constant c_CLK_PERIOD : time := 16667 ps;

   signal CLK : std_logic;

begin

   buffer2pal_i : buffer2pal
   port map (
      CLK         => B2P_CLK,
      SYNC_IN     => B2P_SYNC_IN,
      SYNC_OUT    => B2P_SYNC_OUT,
      VIDEO_DATA  => B2P_VIDEO_DATA,
      OE_VIDEO    => B2P_OE_VIDEO,
      POSX        => B2P_POSX,
      POSY        => B2P_POSY,
      BUFFER_ADDR => B2P_BUFFER_ADDR,
      BUFFER_DIN  => B2P_BUFFER_DIN,
      BUFFER_DOUT => B2P_BUFFER_DOUT,
      BUFFER_EN   => B2P_BUFFER_EN,
      BUFFER_WE   => B2P_BUFFER_WE,
      BUFFER_RST  => B2P_BUFFER_RST,
      BUFFER_CLK  => B2P_BUFFER_CLK
   );
   active_video_generator_i : active_video_generator
   port map (
      CLK      => AVG_CLK,
      SYNC_IN  => AVG_SYNC_IN,
      SYNC_OUT => AVG_SYNC_OUT,
      POSX_IN  => AVG_POSX_IN,
      POSY_IN  => AVG_POSY_IN,
      OE_VIDEO => AVG_OE_VIDEO,
      POSX_OUT => AVG_POSX_OUT,
      POSY_OUT => AVG_POSY_OUT
   );
   pal_i : pal
   port map (
      CLK  => PAL_CLK,
      SYNC => PAL_SYNC,
      POSX => PAL_POSX,
      POSY => PAL_POSY
   );

   PAL_CLK <= CLK;

   AVG_CLK     <= CLK;
   AVG_SYNC_IN <= PAL_SYNC;
   AVG_POSX_IN <= PAL_POSX;
   AVG_POSY_IN <= PAL_POSY;

   B2P_CLK      <= CLK;
   B2P_SYNC_IN  <= AVG_SYNC_OUT;
   B2P_OE_VIDEO <= AVG_OE_VIDEO;
   B2P_POSX     <= AVG_POSX_OUT;
   B2P_POSY     <= AVG_POSY_OUT;

   --|=======================================================================|--
   --| Process description
   --|=======================================================================|--
   process begin
      B2P_BUFFER_DIN <= (others => '0');
      wait for 1 us;
      B2P_BUFFER_DIN <= x"0000000F";
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
