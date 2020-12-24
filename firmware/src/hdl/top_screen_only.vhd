--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: top_screen_only                                             |--
--| Description:                                                             |--
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

entity top_screen_only is
Port (
   -- PS I/O
   DDR_addr          : inout std_logic_vector ( 14 downto 0 );
   DDR_ba            : inout std_logic_vector ( 2 downto 0 );
   DDR_cas_n         : inout std_logic;
   DDR_ck_n          : inout std_logic;
   DDR_ck_p          : inout std_logic;
   DDR_cke           : inout std_logic;
   DDR_cs_n          : inout std_logic;
   DDR_dm            : inout std_logic_vector ( 3 downto 0 );
   DDR_dq            : inout std_logic_vector ( 31 downto 0 );
   DDR_dqs_n         : inout std_logic_vector ( 3 downto 0 );
   DDR_dqs_p         : inout std_logic_vector ( 3 downto 0 );
   DDR_odt           : inout std_logic;
   DDR_ras_n         : inout std_logic;
   DDR_reset_n       : inout std_logic;
   DDR_we_n          : inout std_logic;
   FIXED_IO_ddr_vrn  : inout std_logic;
   FIXED_IO_ddr_vrp  : inout std_logic;
   FIXED_IO_mio      : inout std_logic_vector ( 53 downto 0 );
   FIXED_IO_ps_clk   : inout std_logic;
   FIXED_IO_ps_porb  : inout std_logic;
   FIXED_IO_ps_srstb : inout std_logic;

   -- PL I/O
   VID_MINITEL_SYNC : out std_logic;
   VID_MINITEL_DATA : out std_logic
);
end top_screen_only;

architecture Behavioral of top_screen_only is
   --|=======================================================================|--
   --| External entities
   --|=======================================================================|--

   component d_PS_graphics_0 is
   port (
      -- PS I/O
      DDR_cas_n         : inout std_logic;
      DDR_cke           : inout std_logic;
      DDR_ck_n          : inout std_logic;
      DDR_ck_p          : inout std_logic;
      DDR_cs_n          : inout std_logic;
      DDR_reset_n       : inout std_logic;
      DDR_odt           : inout std_logic;
      DDR_ras_n         : inout std_logic;
      DDR_we_n          : inout std_logic;
      DDR_ba            : inout std_logic_vector ( 2 downto 0 );
      DDR_addr          : inout std_logic_vector ( 14 downto 0 );
      DDR_dm            : inout std_logic_vector ( 3 downto 0 );
      DDR_dq            : inout std_logic_vector ( 31 downto 0 );
      DDR_dqs_n         : inout std_logic_vector ( 3 downto 0 );
      DDR_dqs_p         : inout std_logic_vector ( 3 downto 0 );
      FIXED_IO_mio      : inout std_logic_vector ( 53 downto 0 );
      FIXED_IO_ddr_vrn  : inout std_logic;
      FIXED_IO_ddr_vrp  : inout std_logic;
      FIXED_IO_ps_srstb : inout std_logic;
      FIXED_IO_ps_clk   : inout std_logic;
      FIXED_IO_ps_porb  : inout std_logic;

      -- Graphic buffer access for PL
      GBUFFER_addr      : in std_logic_vector ( 31 downto 0 );
      GBUFFER_clk       : in std_logic;
      GBUFFER_din       : in std_logic_vector ( 31 downto 0 );
      GBUFFER_dout      : out std_logic_vector ( 31 downto 0 );
      GBUFFER_en        : in std_logic;
      GBUFFER_rst       : in std_logic;
      GBUFFER_we        : in std_logic_vector ( 3 downto 0 );

      -- Clock for PL
      CLK_60M           : out std_logic
   );
   end component d_PS_graphics_0;

   component bram2video
   generic (
      g_INVERT_SYNC : std_logic;
      g_INVERT_DATA : std_logic
   );
   port (
      CLK         : in  std_logic;
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
   end component bram2video;


   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--
   signal GBUFFER_addr : std_logic_vector ( 31 downto 0 );
   signal GBUFFER_clk  : std_logic;
   signal GBUFFER_din  : std_logic_vector ( 31 downto 0 );
   signal GBUFFER_dout : std_logic_vector ( 31 downto 0 );
   signal GBUFFER_en   : std_logic;
   signal GBUFFER_rst  : std_logic;
   signal GBUFFER_we   : std_logic_vector ( 3 downto 0 );
   signal CLK_60M      : std_logic;

begin
   d_PS_graphics_0_i: component d_PS_graphics_0
   port map (
      DDR_addr(14 downto 0)     => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0)        => DDR_ba(2 downto 0),
      DDR_cas_n                 => DDR_cas_n,
      DDR_ck_n                  => DDR_ck_n,
      DDR_ck_p                  => DDR_ck_p,
      DDR_cke                   => DDR_cke,
      DDR_cs_n                  => DDR_cs_n,
      DDR_dm(3 downto 0)        => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0)       => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0)     => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0)     => DDR_dqs_p(3 downto 0),
      DDR_odt                   => DDR_odt,
      DDR_ras_n                 => DDR_ras_n,
      DDR_reset_n               => DDR_reset_n,
      DDR_we_n                  => DDR_we_n,
      FIXED_IO_ddr_vrn          => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp          => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk           => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb          => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb         => FIXED_IO_ps_srstb,

      GBUFFER_addr(31 downto 0) => GBUFFER_addr(31 downto 0),
      GBUFFER_clk               => GBUFFER_clk,
      GBUFFER_din(31 downto 0)  => GBUFFER_din(31 downto 0),
      GBUFFER_dout(31 downto 0) => GBUFFER_dout(31 downto 0),
      GBUFFER_en                => GBUFFER_en,
      GBUFFER_rst               => GBUFFER_rst,
      GBUFFER_we(3 downto 0)    => GBUFFER_we(3 downto 0),

      CLK_60M                   => CLK_60M
   );

   bram2video_i : bram2video
   generic map (
      g_INVERT_SYNC => '1',
      g_INVERT_DATA => '0'
   )
   port map (
      CLK         => CLK_60M,
      SYNC_OUT    => VID_MINITEL_SYNC,
      VIDEO_DATA  => VID_MINITEL_DATA,
      BUFFER_ADDR => GBUFFER_addr,
      BUFFER_DIN  => GBUFFER_dout,
      BUFFER_DOUT => GBUFFER_din,
      BUFFER_EN   => GBUFFER_en,
      BUFFER_WE   => GBUFFER_we,
      BUFFER_RST  => GBUFFER_rst,
      BUFFER_CLK  => GBUFFER_clk
   );

end Behavioral;
