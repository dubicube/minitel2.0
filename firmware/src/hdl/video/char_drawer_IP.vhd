--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: char_drawer_IP                                              |--
--| Description: BRAM interface for char_drawer module                       |--
--|                                                                          |--
--|==========================================================================|--
--| 31/12/2020 | Creation                                                    |--
--| 30/12/2021 | Change AXI interface for a BRAM interface                   |--
--|            |                                                             |--
--|==========================================================================|--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity char_drawer_IP is
	port (
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

        -- Register interface through BRAM interface
        REG_ADDR : in  std_logic_vector(7  downto 0);
        REG_DIN  : out std_logic_vector(31 downto 0);
        REG_DOUT : in  std_logic_vector(31 downto 0);
        REG_EN   : in  std_logic;
        REG_WE   : in  std_logic_vector(3 downto 0);
        REG_RST  : in  std_logic;
        REG_CLK  : in  std_logic
	);
end char_drawer_IP;

architecture arch_imp of char_drawer_IP is

    ATTRIBUTE X_INTERFACE_INFO : STRING;

    ATTRIBUTE X_INTERFACE_INFO of BUFFIN_EN   : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFIN_BRAM EN";
    ATTRIBUTE X_INTERFACE_INFO of BUFFIN_WE   : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFIN_BRAM WE";
    ATTRIBUTE X_INTERFACE_INFO of BUFFIN_DIN  : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFIN_BRAM DOUT";
    ATTRIBUTE X_INTERFACE_INFO of BUFFIN_DOUT : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFIN_BRAM DIN";
    ATTRIBUTE X_INTERFACE_INFO of BUFFIN_ADDR : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFIN_BRAM ADDR";
    ATTRIBUTE X_INTERFACE_INFO of BUFFIN_CLK  : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFIN_BRAM CLK";
    ATTRIBUTE X_INTERFACE_INFO of BUFFIN_RST  : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFIN_BRAM RST";

    ATTRIBUTE X_INTERFACE_INFO of BUFFOUT_EN   : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFOUT_BRAM EN";
    ATTRIBUTE X_INTERFACE_INFO of BUFFOUT_WE   : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFOUT_BRAM WE";
    ATTRIBUTE X_INTERFACE_INFO of BUFFOUT_DIN  : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFOUT_BRAM DOUT";
    ATTRIBUTE X_INTERFACE_INFO of BUFFOUT_DOUT : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFOUT_BRAM DIN";
    ATTRIBUTE X_INTERFACE_INFO of BUFFOUT_ADDR : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFOUT_BRAM ADDR";
    ATTRIBUTE X_INTERFACE_INFO of BUFFOUT_CLK  : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFOUT_BRAM CLK";
    ATTRIBUTE X_INTERFACE_INFO of BUFFOUT_RST  : SIGNAL is "xilinx.com:interface:bram:1.0 BUFFOUT_BRAM RST";

    ATTRIBUTE X_INTERFACE_INFO of REG_EN   : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM EN";
    ATTRIBUTE X_INTERFACE_INFO of REG_WE   : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM WE";
    ATTRIBUTE X_INTERFACE_INFO of REG_DIN  : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM DOUT";
    ATTRIBUTE X_INTERFACE_INFO of REG_DOUT : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM DIN";
    ATTRIBUTE X_INTERFACE_INFO of REG_ADDR : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM ADDR";
    ATTRIBUTE X_INTERFACE_INFO of REG_CLK  : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM CLK";
    ATTRIBUTE X_INTERFACE_INFO of REG_RST  : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM RST";


    component char_drawer
    port (
        BUFFIN_ADDR  : in  std_logic_vector(31 downto 0);
        BUFFIN_DIN   : out std_logic_vector(31 downto 0);
        BUFFIN_DOUT  : in  std_logic_vector(31 downto 0);
        BUFFIN_EN    : in  std_logic;
        BUFFIN_WE    : in  std_logic_vector(3 downto 0);
        BUFFIN_RST   : in  std_logic;
        BUFFIN_CLK   : in  std_logic;
        BUFFOUT_ADDR : out std_logic_vector(31 downto 0);
        BUFFOUT_DIN  : in  std_logic_vector(31 downto 0);
        BUFFOUT_DOUT : out std_logic_vector(31 downto 0);
        BUFFOUT_EN   : out std_logic;
        BUFFOUT_WE   : out std_logic_vector(3 downto 0);
        BUFFOUT_RST  : out std_logic;
        BUFFOUT_CLK  : out std_logic;
        CHAR_VALID   : in  std_logic;
        CHAR_DATA    : in  std_logic_vector(7 downto 0)
    );
    end component char_drawer;
    signal CHAR_VALID : std_logic;
    signal CHAR_DATA  : std_logic_vector(7 downto 0);

begin

    --|=======================================================================|--
    --| Register read
    --|=======================================================================|--
    process(REG_CLK) begin
        if rising_edge(REG_CLK) then
            CHAR_DATA <= REG_DOUT(7 downto 0);
            if (REG_EN = '1' and REG_WE(0) = '1' and REG_ADDR = (REG_ADDR'range => '0')) then
                CHAR_VALID <= '1';
            else
                CHAR_VALID <= '0';
            end if;
        end if;
    end process;


    char_drawer_i : char_drawer
    port map (
        BUFFIN_ADDR  => BUFFIN_ADDR,
        BUFFIN_DIN   => BUFFIN_DIN,
        BUFFIN_DOUT  => BUFFIN_DOUT,
        BUFFIN_EN    => BUFFIN_EN,
        BUFFIN_WE    => BUFFIN_WE,
        BUFFIN_RST   => BUFFIN_RST,
        BUFFIN_CLK   => BUFFIN_CLK,
        BUFFOUT_ADDR => BUFFOUT_ADDR,
        BUFFOUT_DIN  => BUFFOUT_DIN,
        BUFFOUT_DOUT => BUFFOUT_DOUT,
        BUFFOUT_EN   => BUFFOUT_EN,
        BUFFOUT_WE   => BUFFOUT_WE,
        BUFFOUT_RST  => BUFFOUT_RST,
        BUFFOUT_CLK  => BUFFOUT_CLK,
        CHAR_VALID   => CHAR_VALID,
        CHAR_DATA    => CHAR_DATA
    );

end arch_imp;
