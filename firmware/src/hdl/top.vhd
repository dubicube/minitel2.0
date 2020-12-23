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

entity top is
port (
   DDR_addr          : inout STD_LOGIC_VECTOR ( 14 downto 0 );
   DDR_ba            : inout STD_LOGIC_VECTOR ( 2 downto 0 );
   DDR_cas_n         : inout STD_LOGIC;
   DDR_ck_n          : inout STD_LOGIC;
   DDR_ck_p          : inout STD_LOGIC;
   DDR_cke           : inout STD_LOGIC;
   DDR_cs_n          : inout STD_LOGIC;
   DDR_dm            : inout STD_LOGIC_VECTOR ( 3 downto 0 );
   DDR_dq            : inout STD_LOGIC_VECTOR ( 31 downto 0 );
   DDR_dqs_n         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
   DDR_dqs_p         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
   DDR_odt           : inout STD_LOGIC;
   DDR_ras_n         : inout STD_LOGIC;
   DDR_reset_n       : inout STD_LOGIC;
   DDR_we_n          : inout STD_LOGIC;
   FIXED_IO_ddr_vrn  : inout STD_LOGIC;
   FIXED_IO_ddr_vrp  : inout STD_LOGIC;
   FIXED_IO_mio      : inout STD_LOGIC_VECTOR ( 53 downto 0 );
   FIXED_IO_ps_clk   : inout STD_LOGIC;
   FIXED_IO_ps_porb  : inout STD_LOGIC;
   FIXED_IO_ps_srstb : inout STD_LOGIC;

   VID_MINITEL_SYNC : out STD_LOGIC;
   VID_MINITEL_DATA : out STD_LOGIC
);
end top;

architecture Behavioral of top is
   --|=======================================================================|--
   --| External entities
   --|=======================================================================|--
   component design_1 is
   port (
      DDR_cas_n         : inout STD_LOGIC;
      DDR_cke           : inout STD_LOGIC;
      DDR_ck_n          : inout STD_LOGIC;
      DDR_ck_p          : inout STD_LOGIC;
      DDR_cs_n          : inout STD_LOGIC;
      DDR_reset_n       : inout STD_LOGIC;
      DDR_odt           : inout STD_LOGIC;
      DDR_ras_n         : inout STD_LOGIC;
      DDR_we_n          : inout STD_LOGIC;
      DDR_ba            : inout STD_LOGIC_VECTOR ( 2 downto 0 );
      DDR_addr          : inout STD_LOGIC_VECTOR ( 14 downto 0 );
      DDR_dm            : inout STD_LOGIC_VECTOR ( 3 downto 0 );
      DDR_dq            : inout STD_LOGIC_VECTOR ( 31 downto 0 );
      DDR_dqs_n         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
      DDR_dqs_p         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
      FIXED_IO_mio      : inout STD_LOGIC_VECTOR ( 53 downto 0 );
      FIXED_IO_ddr_vrn  : inout STD_LOGIC;
      FIXED_IO_ddr_vrp  : inout STD_LOGIC;
      FIXED_IO_ps_srstb : inout STD_LOGIC;
      FIXED_IO_ps_clk   : inout STD_LOGIC;
      FIXED_IO_ps_porb  : inout STD_LOGIC;

      CLK_60MHz : out STD_LOGIC
   );
   end component design_1;

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

begin

   -- 780x574

   s_posx_u <= unsigned(POSX_OUT);
   s_posy_u <= unsigned(POSY_OUT);

   --|=======================================================================|--
   --| Minitel video output
   --|=======================================================================|--
   VID_MINITEL_SYNC <= not s_VID_MINITEL_SYNC;
   VID_MINITEL_DATA <= s_VID_MINITEL_DATA;
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

   design_1_i: component design_1
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

      CLK_60MHz                 => CLK
   );

end Behavioral;
