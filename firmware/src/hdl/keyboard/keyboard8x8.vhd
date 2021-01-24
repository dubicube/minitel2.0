--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: keyboard8x8                                                 |--
--| Description: Controls a matrix keyboard 8x8                              |--
--|                                                                          |--
--|==========================================================================|--
--| 27/12/2020 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity keyboard8x8 is
Port (
   CLK : in std_logic;

   -- Key states output
   KEY_UPDATE : out std_logic; -- Pulse when the matrix is swept
   KEY_REG    : out std_logic_vector(63 downto 0);

   -- Keyboard connection
   OUTPUTK : out std_logic_vector(7 downto 0);
   INPUTK  : in  std_logic_vector(7 downto 0)
);
end keyboard8x8;

architecture Behavioral of keyboard8x8 is
   --|=======================================================================|--
   --| External entities
   --|=======================================================================|--

   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--

   signal s_key_reg : std_logic_vector(63 downto 0) := (others => '1');
   type t_KEY_CONTER is array(7 downto 0) of unsigned(7 downto 0);

   signal s_key_counters : t_KEY_CONTER := (others => (others => '0'));

   signal s_step       : unsigned(2 downto 0) := (others => '0');
   signal s_step_i     : integer range 0 to 7;
   signal s_prescaler  : unsigned(6 downto 0) := (others => '0');
   signal s_step_timer : unsigned(7 downto 0) := (others => '0');

   signal s_step_update : std_logic;

   signal s_inputk_d1 : std_logic_vector(7 downto 0); -- Sampling
   signal s_inputk_d2 : std_logic_vector(7 downto 0); -- Meta stability resolution
   signal s_inputk_d3 : std_logic_vector(7 downto 0); -- Change detection

begin

   -- Key output
   KEY_REG <= s_key_reg;

   s_step_i <= to_integer(s_step);
   s_step_update <= '1' when s_step_timer=(s_step_timer'range => '1') and s_prescaler=0 else '0';

   -- Nice

   --|=======================================================================|--
   --| Input keyboard matrix and step counters
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
         s_inputk_d1 <= INPUTK;
         s_inputk_d2 <= s_inputk_d1;
         s_inputk_d3 <= s_inputk_d2;

         s_prescaler <= s_prescaler + 1;
         if (s_prescaler = 0) then
            s_step_timer <= s_step_timer + 1;
         end if;
         if (s_step_update = '1') then
            s_step <= s_step + 1;
         end if;
      end if;
   end process;

   --|=======================================================================|--
   --| Counters to filter input bounces
   --|=======================================================================|--
   GEN_REG : for I in 0 to 7 generate
      process(CLK) begin
         if rising_edge(CLK) then
            if (s_inputk_d3(I) /= s_inputk_d2(I)) then
               s_key_counters(I) <= (others => '0');
            elsif (s_key_counters(I) /= 255) then
               s_key_counters(I) <= s_key_counters(I) + 1;
            end if;
         end if;
      end process;
   end generate GEN_REG;

   --|=======================================================================|--
   --| Key register update
   --|=======================================================================|--
   GEN_REGI : for I in 0 to 7 generate
      GEN_REGJ : for J in 0 to 7 generate
         process(CLK) begin
            if rising_edge(CLK) then
               if (s_step_update='1' and s_key_counters(J)=255 and s_step_i=I) then
                  s_key_reg(I*8+J) <= s_inputk_d3(J);
               else
                  s_key_reg(I*8+J) <= s_key_reg(I*8+J);
               end if;
            end if;
         end process;
      end generate GEN_REGJ;
   end generate GEN_REGI;

   --|=======================================================================|--
   --| Key update output
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
         -- if (s_step_update='1' and s_key_counters(7)=255 and s_step_i=7) then
         --    KEY_UPDATE <= '1';
         -- else
         --    KEY_UPDATE <= '0';
         -- end if;
         KEY_UPDATE <= s_step_update;
      end if;
   end process;

   --|=======================================================================|--
   --| Output keyboard matrix
   --|=======================================================================|--
   GEN_OUT : for I in 0 to 7 generate
      OUTPUTK(I) <= '0' when s_step=I else 'Z';
   end generate GEN_OUT;


end Behavioral;
