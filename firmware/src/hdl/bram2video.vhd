--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: bram2video                                                  |--
--| Description: This module generates a video output from pixels in a BRAM. |--
--|                                                                          |--
--| The BRAM interface is intended to be connected to a shared RAM with PS.  |--
--| The RAM should contains at least 13776 32-bit words (768x574 pixels).    |--
--| The module has write signals for the BRAM but never actually writes data.|--
--| BUFFER_ADDR address the RAM in byte unit, but access are always          |--
--| multiples of 4 (to addresse 32-bit words)                                |--
--|                                                                          |--
--| The external RAM stores pixels of the frame.                             |--
--| Each pixel is stored with 1 bit.                                         |--
--| A line is composed of 768 pixels, thus 24 32-bit words.                  |--
--| There are 574 lines.                                                     |--
--| So, the first pixels of line 0 are at offset 0 (in bytes), the first     |--
--| pixels of line 1 are at offset 24 (in bytes), and so on.                 |--
--|                                                                          |--
--| CLK frequency must be 60MHz                                              |--
--|                                                                          |--
--| The analog video generated is interlaced.                                |--
--|                                                                          |--
--|==========================================================================|--
--| 23/12/2020 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity bram2video is
generic (
   g_INVERT_SYNC : std_logic := '1'; -- '1' to invert SYNC_OUT, else '0' to not invert
   g_INVERT_DATA : std_logic := '0'  -- '1' to invert VIDEO_DATA, else '0' to not invert
);
Port (
   CLK : in std_logic;

   SYNC_OUT    : out std_logic;
   VIDEO_DATA  : out std_logic;

   BUFFER_ADDR : out std_logic_vector(31 downto 0);
   BUFFER_DIN  : in  std_logic_vector(31 downto 0);
   BUFFER_DOUT : out std_logic_vector(31 downto 0);
   BUFFER_EN   : out std_logic;
   BUFFER_WE   : out std_logic_vector(3 downto 0);
   BUFFER_RST  : out std_logic;
   BUFFER_CLK  : out std_logic
);
end bram2video;

architecture Behavioral of bram2video is

   --|=======================================================================|--
   --| BRAM interface declaration for Vivado
   --|=======================================================================|--
   ATTRIBUTE X_INTERFACE_INFO : STRING;

   ATTRIBUTE X_INTERFACE_INFO of BUFFER_EN   : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFER_BRAM EN";
   ATTRIBUTE X_INTERFACE_INFO of BUFFER_WE   : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFER_BRAM WE";
   ATTRIBUTE X_INTERFACE_INFO of BUFFER_DIN  : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFER_BRAM DOUT";
   ATTRIBUTE X_INTERFACE_INFO of BUFFER_DOUT : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFER_BRAM DIN";
   ATTRIBUTE X_INTERFACE_INFO of BUFFER_ADDR : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFER_BRAM ADDR";
   ATTRIBUTE X_INTERFACE_INFO of BUFFER_CLK  : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFER_BRAM CLK";
   ATTRIBUTE X_INTERFACE_INFO of BUFFER_RST  : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFER_BRAM RST";

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
   signal P_CLK  : std_logic;
   signal P_SYNC : std_logic;
   signal P_POSX : std_logic_vector(11 downto 0);
   signal P_POSY : std_logic_vector(9  downto 0);

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
   generic (
      g_INVERT_SYNC : std_logic := '1';
      g_INVERT_DATA : std_logic := '0'
   );
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

begin

   pal_i : pal
   port map (
      CLK  => P_CLK,
      SYNC => P_SYNC,
      POSX => P_POSX,
      POSY => P_POSY
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
   buffer2pal_i : buffer2pal
   generic map(
      g_INVERT_SYNC => g_INVERT_SYNC,
      g_INVERT_DATA => g_INVERT_DATA
   )
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

   -- Clocks
   P_CLK   <= CLK;
   AVG_CLK <= CLK;
   B2P_CLK <= CLK;

   -- PAL to active_video_generator
   AVG_SYNC_IN <= P_SYNC;
   AVG_POSX_IN <= P_POSX;
   AVG_POSY_IN <= P_POSY;

   -- active_video_generator to buffer2pal
   B2P_SYNC_IN  <= AVG_SYNC_OUT;
   B2P_OE_VIDEO <= AVG_OE_VIDEO;
   B2P_POSX     <= AVG_POSX_OUT;
   B2P_POSY     <= AVG_POSY_OUT;

   -- Video output
   SYNC_OUT   <= B2P_SYNC_OUT;
   VIDEO_DATA <= B2P_VIDEO_DATA;

   -- Buffer access
   BUFFER_ADDR    <= B2P_BUFFER_ADDR;
   B2P_BUFFER_DIN <= BUFFER_DIN;
   BUFFER_DOUT    <= B2P_BUFFER_DOUT;
   BUFFER_EN      <= B2P_BUFFER_EN;
   BUFFER_WE      <= B2P_BUFFER_WE;
   BUFFER_RST     <= B2P_BUFFER_RST;
   BUFFER_CLK     <= B2P_BUFFER_CLK;

end Behavioral;
