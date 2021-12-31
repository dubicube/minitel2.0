--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: buffer2pal                                                  |--
--| Description:                                                             |--
--|                                                                          |--
--|==========================================================================|--
--| 20/12/2020 | Creation                                                    |--
--| 06/02/2021 | Converted from 768x574 to 768x512 to easily draw characters |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity buffer2pal is
generic (
   g_INVERT_SYNC : std_logic := '1'; -- '1' to invert SYNC_OUT, else '0' to not invert
   g_INVERT_DATA : std_logic := '0'  -- '1' to invert VIDEO_DATA, else '0' to not invert
);
Port (
   CLK : in std_logic;

   SYNC_IN  : in  std_logic;
   SYNC_OUT : out std_logic;

   VIDEO_DATA : out std_logic;

   OE_VIDEO : in std_logic; -- Output enable video
   POSX     : in std_logic_vector(11 downto 0);
   POSY     : in std_logic_vector(9  downto 0);

   BUFFER_ADDR : out std_logic_vector(31 downto 0);
   BUFFER_DIN  : in  std_logic_vector(31 downto 0);
   BUFFER_DOUT : out std_logic_vector(31 downto 0);
   BUFFER_EN   : out std_logic;
   BUFFER_WE   : out std_logic_vector(3 downto 0);
   BUFFER_RST  : out std_logic;
   BUFFER_CLK  : out std_logic
);
end buffer2pal;

architecture Behavioral of buffer2pal is

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

   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--

   signal s_pixel_enable : std_logic;

   signal s_VIDEO_DATA : std_logic;

begin

   --|=======================================================================|--
   --| Sync conversion
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
         if (g_INVERT_SYNC = '1') then
            SYNC_OUT <= not SYNC_IN;
         else
            SYNC_OUT <= SYNC_IN;
         end if;
      end if;
   end process;


   NORMAL_DATA: if (g_INVERT_DATA = '0') generate
      VIDEO_DATA <= s_VIDEO_DATA and OE_VIDEO;
   end generate NORMAL_DATA;
   INVERTED_DATA: if (g_INVERT_DATA = '1') generate
      VIDEO_DATA <= not (s_VIDEO_DATA and OE_VIDEO);
   end generate INVERTED_DATA;

   BUFFER_CLK  <= CLK;
   BUFFER_RST  <= '0';
   BUFFER_WE   <= (others => '0');
   BUFFER_DOUT <= (others => '0');

   --|=======================================================================|--
   --| Buffer to video data
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
         BUFFER_ADDR <= x"0000" & POSX(11 downto 2) & POSY(8 downto 5) & "00";
         if (POSX(1 downto 0) = "00") then
            BUFFER_EN   <= '1';
         else
            BUFFER_EN <= '0';
         end if;
         if (POSX(1 downto 0) = "10") then
            s_VIDEO_DATA <= BUFFER_DIN(to_integer(unsigned(POSY(4 downto 0))));
         end if;
      end if;
   end process;

end Behavioral;
