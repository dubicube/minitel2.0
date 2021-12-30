--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: keyboard8x8_IP                                              |--
--| Description: BRAM interface for keyboard8x8 module                       |--
--|                                                                          |--
--|==========================================================================|--
--| 31/12/2020 | Creation                                                    |--
--| 30/12/2021 | Change AXI interface for a BRAM interface                   |--
--|            |                                                             |--
--|==========================================================================|--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard8x8_IP is
    generic (
        -- Must be a power of 2, or some kraken could eat your computer.
        -- (Some abusive overflow mechanics are used here...)
        C_FIFO_DEPTH : integer := 8
    );
    port (
        -- Raw key data input
        KEY_UPDATE : in std_logic;
        KEY_REG    : in std_logic_vector(63 downto 0);

        -- Char input
        CHAR_VALID : in std_logic;
        CHAR_DATA  : in std_logic_vector(7 downto 0);

        -- Interruption to PS
        FIFO_ITR : out std_logic;

        -- Register interface through BRAM interface
        REG_ADDR : in  std_logic_vector(7  downto 0);
        REG_DIN  : out std_logic_vector(31 downto 0);
        REG_DOUT : in  std_logic_vector(31 downto 0);
        REG_EN   : in  std_logic;
        REG_WE   : in  std_logic_vector(3 downto 0);
        REG_RST  : in  std_logic;
        REG_CLK  : in  std_logic
    );
end keyboard8x8_IP;

architecture arch_imp of keyboard8x8_IP is

    ATTRIBUTE X_INTERFACE_INFO : STRING;

    ATTRIBUTE X_INTERFACE_INFO of REG_EN   : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM EN";
    ATTRIBUTE X_INTERFACE_INFO of REG_WE   : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM WE";
    ATTRIBUTE X_INTERFACE_INFO of REG_DIN  : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM DOUT";
    ATTRIBUTE X_INTERFACE_INFO of REG_DOUT : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM DIN";
    ATTRIBUTE X_INTERFACE_INFO of REG_ADDR : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM ADDR";
    ATTRIBUTE X_INTERFACE_INFO of REG_CLK  : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM CLK";
    ATTRIBUTE X_INTERFACE_INFO of REG_RST  : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM RST";

    type t_MEMORY_8 is array (0 to C_FIFO_DEPTH-1) of std_logic_vector(7 downto 0);
    signal s_char_fifo  : t_MEMORY_8;
    signal s_fifo_rp    : integer range 0 to C_FIFO_DEPTH-1 := 0;
    signal s_fifo_wp    : integer range 0 to C_FIFO_DEPTH-1 := 0;
    signal s_fifo_full  : std_logic;
    signal s_fifo_empty : std_logic;
    signal s_fifo_read  : std_logic;

begin

    --|=======================================================================|--
    --| Register read
    --|=======================================================================|--
    process(REG_CLK) begin
        if rising_edge(REG_CLK) then
            if (REG_EN = '1' and REG_WE = "0000") then
                case (REG_ADDR) is
                    when x"00" =>
                        REG_DIN <= KEY_REG(31 downto 0);
                    when x"04" =>
                        REG_DIN <= KEY_REG(63 downto 32);
                    when x"08" =>
                        REG_DIN <=  x"00000" & "00" & s_fifo_full & s_fifo_empty
                                    & s_char_fifo(s_fifo_rp);
                    when others =>
                        REG_DIN <= (others => '0');
                end case;
            end if;
        end if;
    end process;

    --|=======================================================================|--
    --| Char FIFO
    --|=======================================================================|--

    s_fifo_read <= '1' when REG_RST = '0' and REG_EN = '1'
    and REG_WE = "0000" and REG_ADDR = x"08" else '0';

    process(REG_CLK) is
    begin
        if (rising_edge(REG_CLK)) then
            if (REG_RST = '1') then
                s_fifo_rp <= 0;
                s_fifo_wp <= 0;
            elsif (s_fifo_full = '0' and CHAR_VALID = '1') then
                s_fifo_wp <= s_fifo_wp + 1;
                s_char_fifo(s_fifo_wp) <= CHAR_DATA;
            elsif (s_fifo_empty = '0' and s_fifo_read = '1') then
                s_fifo_rp <= s_fifo_rp + 1;
            end if;

            FIFO_ITR <= not CHAR_VALID;
        end if;
    end process;

    s_fifo_full  <= '1' when s_fifo_rp = s_fifo_wp+1 else '0';
    s_fifo_empty <= '1' when s_fifo_rp = s_fifo_wp else '0';

end arch_imp;
