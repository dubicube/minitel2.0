--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: pal                                                         |--
--| Description: Generates synchronization for PAL video standard            |--
--|              Configured for a 60MHz clock                                |--
--|==========================================================================|--
--| 20/12/2020 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity pal is
Port (
   CLK  : in std_logic;

   SYNC : out std_logic; -- Not registered
   POSX : out std_logic_vector(11 downto 0);
   POSY : out std_logic_vector(9  downto 0)
);
end pal;

architecture Behavioral of pal is
   --|=======================================================================|--
   --| Constants
   --|=======================================================================|--

   --Constants are set for a 60MHz clock (minimum frequency for perfect timings)
   constant c_FRAME_WIDTH  : integer := 3840;
   constant c_FRAME_HEIGHT : integer := 625;

   constant c_TIME_2350  : integer := 141;
   constant c_TIME_4700  : integer := 282;
   constant c_TIME_27300 : integer := 1638;

   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--

   -- Complete line pixel counter
   signal s_pixel_count    : integer range 0 to c_FRAME_WIDTH-1 := 0;
   -- Half line pixel counter
   signal s_pixel_count2   : integer range 0 to (c_FRAME_WIDTH/2)-1 := 0;
   signal s_halfline_count : integer range 0 to c_FRAME_HEIGHT*2-1 := 0;

   signal s_hsync : std_logic := '0'; -- Horizontal sync 4.7us
   signal s_ssync : std_logic := '0'; -- Short sync 2.35us
   signal s_bsync : std_logic := '0'; -- Broad sync 27.3us

   signal s_broad_sync    : std_logic;
   signal s_vertical_sync : std_logic;

   -- Sync output
   signal s_SYNC : std_logic := '0';

begin


   --|=======================================================================|--
   --| Sync ouput
   --|=======================================================================|--
   SYNC <= s_SYNC;
   process(s_hsync, s_ssync, s_bsync, s_broad_sync, s_vertical_sync) begin
      if (s_broad_sync='1') then
         s_SYNC <= s_bsync;
      elsif (s_vertical_sync='1') then
         s_SYNC <= s_ssync;
      else
         s_SYNC <= s_hsync;
      end if;
   end process;

   --|=======================================================================|--
   --| Position ouput
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
         POSX <= std_logic_vector(to_unsigned(s_pixel_count, 12));
         POSY <= std_logic_vector(to_unsigned(s_halfline_count/2, 10));
      end if;
   end process;

   --|=======================================================================|--
   --| State detection
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
         if (s_halfline_count <= 4 or (s_halfline_count <= 629 and s_halfline_count >= 625)) then
            s_broad_sync <= '1';
         else
            s_broad_sync <= '0';
         end if;
         if (s_halfline_count <= 9 or s_halfline_count >= 1245 or (s_halfline_count <= 634 and s_halfline_count >= 620)) then
            s_vertical_sync <= '1';
         else
            s_vertical_sync <= '0';
         end if;
      end if;
   end process;

   --|=======================================================================|--
   --| Pulse
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
         if (s_pixel_count < c_TIME_4700) then
            s_hsync <= '0';
         else
            s_hsync <= '1';
         end if;
         if (s_pixel_count2 < c_TIME_2350) then
            s_ssync <= '0';
         else
            s_ssync <= '1';
         end if;
         if (s_pixel_count2 < c_TIME_27300) then
            s_bsync <= '0';
         else
            s_bsync <= '1';
         end if;
      end if;
   end process;

   --|=======================================================================|--
   --| Pixel and line counters
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
         if (s_pixel_count /= c_FRAME_WIDTH-1) then
            s_pixel_count <= s_pixel_count + 1;
         else
            s_pixel_count <= 0;
         end if;

         if (s_pixel_count2 /= (c_FRAME_WIDTH/2)-1) then
            s_pixel_count2 <= s_pixel_count2 + 1;
         else
            s_pixel_count2 <= 0;
         end if;

         if (s_pixel_count2 = (c_FRAME_WIDTH/2)-1) then
            if (s_halfline_count /= c_FRAME_HEIGHT*2-1) then
               s_halfline_count <= s_halfline_count + 1;
            else
               s_halfline_count <= 0;
            end if;
         end if;
      end if;
   end process;

end Behavioral;
