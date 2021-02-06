--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: char_drawer                                                 |--
--| Description: Draw characters in video buffer                             |--
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

entity char_drawer is
Port (

   -- Buffer input
   BUFFIN_ADDR : in  std_logic_vector(31 downto 0);
   BUFFIN_DIN  : out std_logic_vector(31 downto 0);
   BUFFIN_DOUT : in  std_logic_vector(31 downto 0);
   BUFFIN_EN   : in  std_logic;
   BUFFIN_WE   : in  std_logic_vector(3 downto 0);
   BUFFIN_RST  : in  std_logic;
   BUFFIN_CLK  : in  std_logic;

   -- Buffer output
   BUFFOUT_ADDR : out std_logic_vector(31 downto 0);
   BUFFOUT_DIN  : in  std_logic_vector(31 downto 0);
   BUFFOUT_DOUT : out std_logic_vector(31 downto 0);
   BUFFOUT_EN   : out std_logic;
   BUFFOUT_WE   : out std_logic_vector(3 downto 0);
   BUFFOUT_RST  : out std_logic;
   BUFFOUT_CLK  : out std_logic;

   -- Char input
   CHAR_VALID : in  std_logic;
   CHAR_DATA  : in  std_logic_vector(7 downto 0)
);
end char_drawer;

architecture Behavioral of char_drawer is
   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--

   -- Font ROM (40 pixels per character)
   -- Generated from script in /fonts repertory
   type t_MEMORY_8 is array (0 to 256*5-1) of std_logic_vector(7 downto 0);
   constant c_FONT_TABLE : t_MEMORY_8 := (
      x"00", x"00", x"00", x"00", x"00", x"3e", x"45", x"51", x"45", x"3e", x"3e", x"6b", x"6f", x"6b", x"3e", x"1c",
      x"3e", x"7c", x"3e", x"1c", x"00", x"1c", x"38", x"1c", x"00", x"30", x"36", x"7f", x"36", x"30", x"18", x"5c",
      x"7e", x"5c", x"18", x"00", x"18", x"18", x"00", x"00", x"ff", x"e7", x"e7", x"ff", x"ff", x"3c", x"24", x"24",
      x"3c", x"00", x"c3", x"db", x"db", x"c3", x"ff", x"30", x"48", x"4a", x"36", x"0e", x"06", x"29", x"79", x"29",
      x"06", x"60", x"70", x"3f", x"02", x"04", x"60", x"7e", x"0a", x"35", x"3f", x"18", x"24", x"24", x"24", x"18",
      x"00", x"7f", x"3e", x"1c", x"08", x"08", x"1c", x"3e", x"7f", x"00", x"7e", x"7e", x"00", x"7e", x"7e", x"3c",
      x"3c", x"3c", x"3c", x"00", x"50", x"5c", x"5f", x"5c", x"50", x"7f", x"3e", x"1c", x"08", x"7f", x"7f", x"08",
      x"1c", x"3e", x"7f", x"80", x"80", x"80", x"80", x"80", x"c0", x"c0", x"c0", x"c0", x"c0", x"e0", x"e0", x"e0",
      x"e0", x"e0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f8", x"f8", x"f8", x"f8", x"f8", x"fc", x"fc", x"fc", x"fc",
      x"fc", x"fe", x"fe", x"fe", x"fe", x"fe", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
      x"00", x"00", x"00", x"00", x"00", x"00", x"06", x"5f", x"06", x"00", x"07", x"03", x"00", x"07", x"03", x"24",
      x"7e", x"24", x"7e", x"24", x"24", x"2a", x"6b", x"12", x"00", x"63", x"13", x"08", x"64", x"63", x"36", x"49",
      x"56", x"20", x"50", x"00", x"07", x"03", x"00", x"00", x"00", x"3e", x"41", x"00", x"00", x"00", x"41", x"3e",
      x"00", x"00", x"08", x"3e", x"1c", x"3e", x"08", x"08", x"08", x"3e", x"08", x"08", x"00", x"e0", x"60", x"00",
      x"00", x"08", x"08", x"08", x"08", x"08", x"00", x"60", x"60", x"00", x"00", x"20", x"10", x"08", x"04", x"02",
      x"3e", x"51", x"49", x"45", x"3e", x"00", x"42", x"7f", x"40", x"00", x"62", x"51", x"49", x"49", x"46", x"22",
      x"49", x"49", x"49", x"36", x"18", x"14", x"12", x"7f", x"10", x"2f", x"49", x"49", x"49", x"31", x"3c", x"4a",
      x"49", x"49", x"30", x"01", x"71", x"09", x"05", x"03", x"36", x"49", x"49", x"49", x"36", x"06", x"49", x"49",
      x"29", x"1e", x"00", x"36", x"36", x"00", x"00", x"00", x"ec", x"6c", x"00", x"00", x"08", x"14", x"22", x"41",
      x"00", x"24", x"24", x"24", x"24", x"24", x"00", x"41", x"22", x"14", x"08", x"02", x"01", x"59", x"09", x"06",
      x"3e", x"41", x"5d", x"55", x"1e", x"7e", x"11", x"11", x"11", x"7e", x"7f", x"49", x"49", x"49", x"36", x"3e",
      x"41", x"41", x"41", x"22", x"7f", x"41", x"41", x"41", x"3e", x"7f", x"49", x"49", x"49", x"41", x"7f", x"09",
      x"09", x"09", x"01", x"3e", x"41", x"49", x"49", x"7a", x"7f", x"08", x"08", x"08", x"7f", x"00", x"41", x"7f",
      x"41", x"00", x"30", x"40", x"40", x"40", x"3f", x"7f", x"08", x"14", x"22", x"41", x"7f", x"40", x"40", x"40",
      x"40", x"7f", x"02", x"04", x"02", x"7f", x"7f", x"02", x"04", x"08", x"7f", x"3e", x"41", x"41", x"41", x"3e",
      x"7f", x"09", x"09", x"09", x"06", x"3e", x"41", x"51", x"21", x"5e", x"7f", x"09", x"09", x"19", x"66", x"26",
      x"49", x"49", x"49", x"32", x"01", x"01", x"7f", x"01", x"01", x"3f", x"40", x"40", x"40", x"3f", x"1f", x"20",
      x"40", x"20", x"1f", x"3f", x"40", x"3c", x"40", x"3f", x"63", x"14", x"08", x"14", x"63", x"07", x"08", x"70",
      x"08", x"07", x"71", x"49", x"45", x"43", x"00", x"00", x"7f", x"41", x"41", x"00", x"02", x"04", x"08", x"10",
      x"20", x"00", x"41", x"41", x"7f", x"00", x"04", x"02", x"01", x"02", x"04", x"80", x"80", x"80", x"80", x"80",
      x"00", x"03", x"07", x"00", x"00", x"20", x"54", x"54", x"54", x"78", x"7f", x"44", x"44", x"44", x"38", x"38",
      x"44", x"44", x"44", x"28", x"38", x"44", x"44", x"44", x"7f", x"38", x"54", x"54", x"54", x"08", x"08", x"7e",
      x"09", x"09", x"00", x"18", x"a4", x"a4", x"a4", x"7c", x"7f", x"04", x"04", x"78", x"00", x"00", x"00", x"7d",
      x"40", x"00", x"40", x"80", x"84", x"7d", x"00", x"7f", x"10", x"28", x"44", x"00", x"00", x"00", x"7f", x"40",
      x"00", x"7c", x"04", x"18", x"04", x"78", x"7c", x"04", x"04", x"78", x"00", x"38", x"44", x"44", x"44", x"38",
      x"fc", x"44", x"44", x"44", x"38", x"38", x"44", x"44", x"44", x"fc", x"44", x"78", x"44", x"04", x"08", x"08",
      x"54", x"54", x"54", x"20", x"04", x"3e", x"44", x"24", x"00", x"3c", x"40", x"20", x"7c", x"00", x"1c", x"20",
      x"40", x"20", x"1c", x"3c", x"60", x"30", x"60", x"3c", x"6c", x"10", x"10", x"6c", x"00", x"9c", x"a0", x"60",
      x"3c", x"00", x"64", x"54", x"54", x"4c", x"00", x"08", x"3e", x"41", x"41", x"00", x"00", x"00", x"ff", x"00",
      x"00", x"00", x"41", x"41", x"3e", x"08", x"02", x"01", x"02", x"01", x"00", x"80", x"80", x"80", x"80", x"00",
      x"c0", x"c0", x"c0", x"c0", x"00", x"e0", x"e0", x"e0", x"e0", x"00", x"f0", x"f0", x"f0", x"f0", x"00", x"f8",
      x"f8", x"f8", x"f8", x"00", x"fc", x"fc", x"fc", x"fc", x"00", x"fe", x"fe", x"fe", x"fe", x"00", x"ff", x"ff",
      x"ff", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"3c", x"00", x"00", x"00", x"00", x"3c", x"3c", x"00",
      x"00", x"00", x"3c", x"3c", x"3c", x"00", x"00", x"3c", x"3c", x"3c", x"3c", x"00", x"3c", x"3c", x"3c", x"3c",
      x"3c", x"ff", x"ff", x"ff", x"ff", x"ff", x"22", x"55", x"59", x"30", x"00", x"1c", x"2a", x"2a", x"2a", x"00",
      x"02", x"7e", x"02", x"7e", x"02", x"18", x"24", x"24", x"1c", x"04", x"08", x"04", x"78", x"04", x"00", x"18",
      x"24", x"7e", x"24", x"18", x"18", x"24", x"18", x"24", x"18", x"7f", x"01", x"01", x"03", x"00", x"3e", x"49",
      x"49", x"3e", x"00", x"08", x"55", x"77", x"55", x"08", x"4c", x"72", x"02", x"72", x"4c", x"8c", x"8c", x"94",
      x"94", x"a4", x"94", x"94", x"8c", x"8c", x"fc", x"08", x"1c", x"2a", x"08", x"08", x"04", x"02", x"7f", x"02",
      x"04", x"08", x"08", x"2a", x"1c", x"08", x"10", x"20", x"7f", x"20", x"10", x"1c", x"2a", x"2a", x"1c", x"08",
      x"00", x"00", x"00", x"00", x"00", x"00", x"30", x"7d", x"30", x"00", x"18", x"24", x"7e", x"24", x"00", x"48",
      x"3e", x"49", x"49", x"62", x"38", x"54", x"54", x"44", x"28", x"29", x"2a", x"7c", x"2a", x"29", x"48", x"55",
      x"56", x"55", x"24", x"22", x"4d", x"55", x"59", x"22", x"08", x"55", x"56", x"55", x"20", x"38", x"7c", x"6c",
      x"44", x"38", x"08", x"55", x"55", x"55", x"5e", x"08", x"14", x"00", x"08", x"14", x"04", x"04", x"04", x"04",
      x"1c", x"08", x"08", x"08", x"08", x"08", x"38", x"7c", x"5c", x"74", x"38", x"01", x"01", x"01", x"01", x"01",
      x"06", x"09", x"09", x"09", x"06", x"24", x"24", x"3f", x"24", x"24", x"09", x"0d", x"0a", x"00", x"00", x"15",
      x"15", x"0a", x"00", x"00", x"65", x"56", x"4e", x"45", x"00", x"fc", x"20", x"20", x"1c", x"00", x"06", x"09",
      x"7f", x"01", x"7f", x"00", x"18", x"18", x"00", x"00", x"65", x"56", x"56", x"4d", x"00", x"12", x"1f", x"10",
      x"00", x"00", x"4e", x"51", x"51", x"4e", x"00", x"14", x"08", x"00", x"14", x"08", x"7f", x"41", x"7f", x"49",
      x"49", x"7c", x"44", x"7c", x"54", x"48", x"04", x"09", x"70", x"09", x"04", x"30", x"48", x"4d", x"40", x"20",
      x"70", x"29", x"25", x"2a", x"70", x"70", x"2a", x"25", x"29", x"70", x"70", x"2a", x"25", x"2a", x"70", x"72",
      x"29", x"26", x"29", x"70", x"70", x"29", x"24", x"29", x"70", x"78", x"2f", x"25", x"2f", x"78", x"7e", x"09",
      x"7f", x"49", x"49", x"1e", x"a1", x"e1", x"21", x"12", x"7c", x"55", x"55", x"56", x"46", x"7c", x"56", x"56",
      x"55", x"45", x"7e", x"55", x"55", x"56", x"44", x"7c", x"55", x"54", x"54", x"45", x"00", x"45", x"7d", x"46",
      x"00", x"00", x"46", x"7d", x"45", x"00", x"00", x"46", x"7d", x"46", x"00", x"00", x"45", x"7c", x"45", x"00",
      x"7f", x"49", x"49", x"41", x"3e", x"7a", x"11", x"22", x"79", x"00", x"39", x"45", x"46", x"38", x"00", x"38",
      x"46", x"45", x"39", x"00", x"38", x"46", x"45", x"3a", x"00", x"3a", x"45", x"46", x"39", x"00", x"39", x"44",
      x"44", x"39", x"00", x"28", x"10", x"10", x"28", x"00", x"3e", x"61", x"5d", x"43", x"3e", x"3c", x"41", x"41",
      x"3e", x"00", x"3c", x"42", x"41", x"3d", x"00", x"38", x"42", x"41", x"3a", x"00", x"3c", x"41", x"40", x"3d",
      x"00", x"04", x"0a", x"71", x"09", x"04", x"ff", x"44", x"44", x"44", x"38", x"7e", x"0a", x"4a", x"34", x"00",
      x"20", x"55", x"55", x"56", x"78", x"20", x"56", x"55", x"55", x"78", x"20", x"56", x"55", x"56", x"78", x"20",
      x"56", x"55", x"56", x"79", x"20", x"55", x"54", x"55", x"78", x"20", x"57", x"55", x"57", x"78", x"34", x"54",
      x"7c", x"54", x"58", x"1c", x"a2", x"e2", x"22", x"14", x"38", x"55", x"55", x"56", x"08", x"38", x"54", x"56",
      x"55", x"09", x"38", x"56", x"55", x"56", x"08", x"38", x"55", x"54", x"55", x"08", x"00", x"01", x"7d", x"42",
      x"00", x"00", x"02", x"7d", x"41", x"00", x"00", x"02", x"79", x"42", x"00", x"00", x"01", x"7c", x"41", x"00",
      x"39", x"47", x"45", x"45", x"3e", x"7a", x"09", x"0a", x"71", x"00", x"39", x"45", x"46", x"38", x"00", x"38",
      x"46", x"45", x"39", x"00", x"38", x"46", x"45", x"3a", x"00", x"3a", x"45", x"46", x"39", x"00", x"38", x"45",
      x"44", x"39", x"00", x"08", x"08", x"2a", x"08", x"08", x"b8", x"64", x"54", x"4c", x"3a", x"3d", x"41", x"22",
      x"7c", x"00", x"3c", x"42", x"21", x"7d", x"00", x"38", x"42", x"21", x"7a", x"00", x"3c", x"41", x"20", x"7d",
      x"00", x"9c", x"a2", x"61", x"3d", x"00", x"ff", x"48", x"48", x"48", x"30", x"9c", x"a1", x"60", x"3d", x"00"
   );
   signal s_rom_addr     : unsigned(10 downto 0) := (others => '0');
   signal s_rom_data     : std_logic_vector(7 downto 0) := (others => '0');
   signal s_rom_en       : std_logic := '0';

   -- Input latch
   signal s_char_valid_d : std_logic := '0';
   signal s_char_data_l  : unsigned(7 downto 0) := (others => '0');
   -- Steps for state machine
   signal s_step         : integer range 0 to 7 := 0;
   signal s_stop         : std_logic := '1';

   -- Cursor position
   signal s_posx : unsigned(9 downto 0) := (others => '0');
   signal s_posy : unsigned(5 downto 0) := (others => '0');

   -- Buufer internal signals
   signal s_buff_addr  : std_logic_vector(31 downto 0) := (others => '0');
   signal s_buff_wen   : std_logic_vector(3 downto 0) := (others => '0');
   signal s_buff_en    : std_logic := '0';
   signal s_buff_wdata : std_logic_vector(31 downto 0) := (others => '0');

   -- Char input stage
   signal s_control_code : integer range 0 to 255 := 0;
   signal s_control_char : std_logic := '0';
   signal s_char_valid   : std_logic := '0';
   signal s_char_data    : std_logic_vector(7 downto 0) := (others => '0');

   -- Escape mode signals
   signal s_escape_mode : std_logic := '0';
   signal s_param0      : unsigned(7 downto 0) := (others => '0');
   signal s_param1      : unsigned(7 downto 0) := (others => '0');

begin

   --|=======================================================================|--
   --| Buffer output
   --|=======================================================================|--
   BUFFOUT_ADDR <= BUFFIN_ADDR when BUFFIN_EN='1' else s_buff_addr;
   BUFFIN_DIN   <= BUFFOUT_DIN;
   BUFFOUT_DOUT <= BUFFIN_DOUT when BUFFIN_EN='1' else s_buff_wdata;
   BUFFOUT_EN   <= BUFFIN_EN or s_buff_en;
   BUFFOUT_WE   <= BUFFIN_WE when BUFFIN_EN='1' else s_buff_wen;
   BUFFOUT_RST  <= BUFFIN_RST;
   BUFFOUT_CLK  <= BUFFIN_CLK;

   --|=======================================================================|--
   --| Internal buffer
   --|=======================================================================|--
   -- s_buff_addr <= std_logic_vector(x"0000" & s_posx & s_posy(5 downto 2) & "00");
   -- s_buff_en <= '1' when s_stop='0' and BUFFIN_EN='0' and s_char_valid_d='0' else '0';
   -- GEN_REG : for I in 0 to 3 generate
   --    s_buff_wen(I) <= '1' when s_posy(1 downto 0)=I and s_buff_en='1' else '0';
   --    s_buff_wdata(I*8+7 downto I*8) <= s_rom_data;
   -- end generate GEN_REG;

   s_buff_addr <= std_logic_vector(x"0000" & s_posx & s_posy(4 downto 1) & "00");
   s_buff_en <= '1' when s_stop='0' and BUFFIN_EN='0' and s_char_valid_d='0' else '0';
   GEN_WEN : for I in 0 to 1 generate
      s_buff_wen(I*2+1 downto I*2) <= "11" when s_posy(0 downto 0)=I and s_buff_en='1' else "00";
   end generate GEN_WEN;
   GEN_WDATA : for I in 0 to 7 generate
      s_buff_wdata(I*2)    <= s_rom_data(I);
      s_buff_wdata(I*2+1)  <= s_rom_data(I);
      s_buff_wdata(I*2+16) <= s_rom_data(I);
      s_buff_wdata(I*2+17) <= s_rom_data(I);
   end generate GEN_WDATA;

   --|=======================================================================|--
   --| Cursor position
   --|=======================================================================|--
   process(BUFFIN_CLK) begin
      if rising_edge(BUFFIN_CLK) then
         if (s_control_code /= 0) then
            if (s_control_code = 1) then
               s_posy <= s_posy + 1;
            elsif (s_control_code = 2) then
               s_posx <= (others => '0');
            elsif (s_control_code = 65) then
               s_posy <= resize(s_posy - s_param0, 6);
            elsif (s_control_code = 66) then
               s_posy <= resize(s_posy + s_param0, 6);
            elsif (s_control_code = 67) then
               s_posx <= resize(s_posx + s_param0*12, 10);
            elsif (s_control_code = 68) then
               s_posx <= resize(s_posx - s_param0*12, 10);
            elsif (s_control_code = 72) then
               if (s_param1 = 0) then
                  s_posx <= (others => '0');
               else
                  s_posx <= resize((s_param1-1)*12, 10);
               end if;
               if (s_param0 = 0) then
                  s_posy <= (others => '0');
               else
                  s_posy <= resize(s_param0-1, 6);
               end if;
            end if;
         else
            if (s_stop = '1' and s_char_valid = '1') then
               s_posx <= s_posx + 2;
            elsif (s_buff_en = '1') then
               if (s_posx = 767) then
                  s_posx <= (others => '0');
                  s_posy <= s_posy + 1;
               else
                  s_posx <= s_posx + 1;
               end if;
            end if;
         end if;
      end if;
   end process;

   --|=======================================================================|--
   --| State machine
   --|=======================================================================|--
   process(BUFFIN_CLK) begin
      if rising_edge(BUFFIN_CLK) then
         if (s_stop = '1') then
            if (s_char_valid = '1') then
               s_stop <= '0';
            end if;
         else
            if (BUFFIN_EN = '0') then
               if (s_step = 5 and s_buff_en = '1' and s_posx(0)='1') then
                  s_stop <= '1';
               end if;
            end if;
         end if;
         if (s_rom_en = '1' and s_step /= 5) then
            s_step <= s_step + 1;
         elsif (s_step = 5 and s_buff_en = '1' and s_posx(0)='1') then
            s_step <= 0;
         end if;
      end if;
   end process;

   --|=======================================================================|--
   --| ROM
   --|=======================================================================|--
   s_rom_en <= '1' when (s_char_valid_d='1') or (s_stop='0' and s_buff_en='1' and s_posx(0)='1') else '0';
   s_rom_addr <= resize(5*s_char_data_l + to_unsigned(s_step, 3), 11);
   process(BUFFIN_CLK) begin
      if rising_edge(BUFFIN_CLK) then
         if (s_rom_en = '1') then
            s_rom_data <= c_FONT_TABLE(to_integer(s_rom_addr));
         end if;
      end if;
   end process;

   --|=======================================================================|--
   --| Char data latch
   --|=======================================================================|--
   s_char_data_l <= unsigned(CHAR_DATA);
   process(BUFFIN_CLK) begin
      if rising_edge(BUFFIN_CLK) then
         s_char_valid_d <= s_char_valid;
      end if;
   end process;

   s_control_char <= '1' when CHAR_DATA=x"0A" or CHAR_DATA=x"0D" or CHAR_DATA=x"1B" or s_escape_mode='1' else '0';
   process(BUFFIN_CLK) begin
      if rising_edge(BUFFIN_CLK) then
         s_control_code <= 0;
         s_char_valid   <= '0';
         if (s_stop = '1') then
            s_char_data  <= CHAR_DATA;
            if (CHAR_VALID = '1' and s_control_char = '0') then
               s_char_valid <= '1';
            end if;
            if (CHAR_VALID = '1') then
               if (CHAR_DATA = x"0A") then -- New line
                  s_control_code <= 1;
               elsif (CHAR_DATA = x"0D") then -- Carriage return
                  s_control_code <= 2;
               elsif (CHAR_DATA = x"1B") then -- ESC
                  s_escape_mode <= '1';
                  s_param0 <= (others => '0');
                  s_param1 <= (others => '0');
               elsif (s_escape_mode = '1') then
                  if (unsigned(CHAR_DATA) > 63 and CHAR_DATA/=x"5B") then
                     s_escape_mode <= '0';
                     s_control_code <= to_integer(unsigned(CHAR_DATA));
                  elsif (unsigned(CHAR_DATA) >= 48 and unsigned(CHAR_DATA) <= 57) then
                     s_param0 <= resize(s_param0*10 + unsigned(CHAR_DATA)-48, 8);
                  elsif (CHAR_DATA = x"3B") then
                     s_param1 <= s_param0;
                     s_param0 <= (others => '0');
                  end if;
               end if;
            end if;
         end if;
      end if;
   end process;

end Behavioral;
