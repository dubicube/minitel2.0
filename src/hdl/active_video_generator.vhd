--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: active_video_generator                                      |--
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

entity active_video_generator is
Port (
   CLK : in std_logic;

   SYNC_IN  : in  std_logic;
   SYNC_OUT : out std_logic;

   POSX_IN : in std_logic_vector(11 downto 0);
   POSY_IN : in std_logic_vector(9  downto 0);

   OE_VIDEO : out std_logic; -- Output enable video
   POSX_OUT : out std_logic_vector(11 downto 0);
   POSY_OUT : out std_logic_vector(9  downto 0)
);
end active_video_generator;

architecture Behavioral of active_video_generator is
   --|=======================================================================|--
   --| Constants
   --|=======================================================================|--

   constant c_START_X  : unsigned(11 downto 0) := to_unsigned(646, 12); -- Included
   constant c_END_X    : unsigned(11 downto 0) := to_unsigned(3718, 12); -- Not included
   constant c_START_Y1 : unsigned(9  downto 0) := to_unsigned(23, 10); -- Included
   constant c_END_Y1   : unsigned(9  downto 0) := to_unsigned(310, 10); -- Not included
   constant c_START_Y2 : unsigned(9  downto 0) := to_unsigned(335, 10); -- Included
   constant c_END_Y2   : unsigned(9  downto 0) := to_unsigned(622, 10); -- Not included

   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--

   signal s_POS_X_IN  : unsigned(11 downto 0);
   signal s_POS_Y_IN  : unsigned(9  downto 0);
   signal s_POS_X_OUT : unsigned(11 downto 0);
   signal s_POS_Y_OUT : unsigned(9  downto 0);

begin

   s_POS_X_IN <= unsigned(POSX_IN);
   s_POS_Y_IN <= unsigned(POSY_IN);

   --|=======================================================================|--
   --| Output enable
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
         if (s_POS_X_IN<c_START_X or s_POS_X_IN>=c_END_X or (not(s_POS_Y_IN>=c_START_Y1 and s_POS_Y_IN<c_END_Y1) and not(s_POS_Y_IN>=c_START_Y2 and s_POS_Y_IN<c_END_Y2))) then
            OE_VIDEO <= '0';
         else
            OE_VIDEO <= '1';
         end if;
         SYNC_OUT <= SYNC_IN;
      end if;
   end process;

   --|=======================================================================|--
   --| Position output
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
         s_POS_X_OUT <= s_POS_X_IN-c_START_X;
         if (s_POS_Y_IN < c_START_Y2) then
            s_POS_Y_OUT <= (s_POS_Y_IN(s_POS_Y_IN'left-1 downto 0)-c_START_Y1(c_START_Y1'left-1 downto 0)) & "0";
         else
            s_POS_Y_OUT <= (s_POS_Y_IN(s_POS_Y_IN'left-1 downto 0)-c_START_Y2(c_START_Y2'left-1 downto 0)) & "1";
         end if;
      end if;
   end process;
   POSX_OUT <= std_logic_vector(s_POS_X_OUT);
   POSY_OUT <= std_logic_vector(s_POS_Y_OUT);

end Behavioral;
