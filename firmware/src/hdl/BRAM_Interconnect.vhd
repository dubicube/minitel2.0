--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: BRAM_Interconnect                                           |--
--| Description: Interconnect circuitry to connect custom peripherals.       |--
--| Adds 2 clock cycle latency.                                              |--
--|                                                                          |--
--|==========================================================================|--
--| 30/12/2021 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BRAM_Interconnect is
    port (
        -- Input interface
        REG_ADDR : in  std_logic_vector(23 downto 0);
        REG_DIN  : out std_logic_vector(31 downto 0);
        REG_DOUT : in  std_logic_vector(31 downto 0);
        REG_EN   : in  std_logic;
        REG_WE   : in  std_logic_vector(3 downto 0);
        REG_RST  : in  std_logic;
        REG_CLK  : in  std_logic;

        -- Output interface 0
        REG0_ADDR : out std_logic_vector(15 downto 0);
        REG0_DIN  : in  std_logic_vector(31 downto 0);
        REG0_DOUT : out std_logic_vector(31 downto 0);
        REG0_EN   : out std_logic;
        REG0_WE   : out std_logic_vector(3 downto 0);
        REG0_RST  : out std_logic;
        REG0_CLK  : out std_logic;

        -- Output interface 1
        REG1_ADDR : out std_logic_vector(15 downto 0);
        REG1_DIN  : in  std_logic_vector(31 downto 0);
        REG1_DOUT : out std_logic_vector(31 downto 0);
        REG1_EN   : out std_logic;
        REG1_WE   : out std_logic_vector(3 downto 0);
        REG1_RST  : out std_logic;
        REG1_CLK  : out std_logic;

        -- Output interface 2
        REG2_ADDR : out std_logic_vector(15 downto 0);
        REG2_DIN  : in  std_logic_vector(31 downto 0);
        REG2_DOUT : out std_logic_vector(31 downto 0);
        REG2_EN   : out std_logic;
        REG2_WE   : out std_logic_vector(3 downto 0);
        REG2_RST  : out std_logic;
        REG2_CLK  : out std_logic
    );
end BRAM_Interconnect;

architecture arch_imp of BRAM_Interconnect is

    ATTRIBUTE X_INTERFACE_INFO : STRING;

    ATTRIBUTE X_INTERFACE_INFO of REG_EN   : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM EN";
    ATTRIBUTE X_INTERFACE_INFO of REG_WE   : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM WE";
    ATTRIBUTE X_INTERFACE_INFO of REG_DIN  : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM DOUT";
    ATTRIBUTE X_INTERFACE_INFO of REG_DOUT : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM DIN";
    ATTRIBUTE X_INTERFACE_INFO of REG_ADDR : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM ADDR";
    ATTRIBUTE X_INTERFACE_INFO of REG_CLK  : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM CLK";
    ATTRIBUTE X_INTERFACE_INFO of REG_RST  : SIGNAL is "xilinx.com:interface:bram:1.0 REG_BRAM RST";

    ATTRIBUTE X_INTERFACE_INFO of REG0_EN   : SIGNAL is "xilinx.com:interface:bram:1.0 REG0_BRAM EN";
    ATTRIBUTE X_INTERFACE_INFO of REG0_WE   : SIGNAL is "xilinx.com:interface:bram:1.0 REG0_BRAM WE";
    ATTRIBUTE X_INTERFACE_INFO of REG0_DIN  : SIGNAL is "xilinx.com:interface:bram:1.0 REG0_BRAM DOUT";
    ATTRIBUTE X_INTERFACE_INFO of REG0_DOUT : SIGNAL is "xilinx.com:interface:bram:1.0 REG0_BRAM DIN";
    ATTRIBUTE X_INTERFACE_INFO of REG0_ADDR : SIGNAL is "xilinx.com:interface:bram:1.0 REG0_BRAM ADDR";
    ATTRIBUTE X_INTERFACE_INFO of REG0_CLK  : SIGNAL is "xilinx.com:interface:bram:1.0 REG0_BRAM CLK";
    ATTRIBUTE X_INTERFACE_INFO of REG0_RST  : SIGNAL is "xilinx.com:interface:bram:1.0 REG0_BRAM RST";

    ATTRIBUTE X_INTERFACE_INFO of REG1_EN   : SIGNAL is "xilinx.com:interface:bram:1.0 REG1_BRAM EN";
    ATTRIBUTE X_INTERFACE_INFO of REG1_WE   : SIGNAL is "xilinx.com:interface:bram:1.0 REG1_BRAM WE";
    ATTRIBUTE X_INTERFACE_INFO of REG1_DIN  : SIGNAL is "xilinx.com:interface:bram:1.0 REG1_BRAM DOUT";
    ATTRIBUTE X_INTERFACE_INFO of REG1_DOUT : SIGNAL is "xilinx.com:interface:bram:1.0 REG1_BRAM DIN";
    ATTRIBUTE X_INTERFACE_INFO of REG1_ADDR : SIGNAL is "xilinx.com:interface:bram:1.0 REG1_BRAM ADDR";
    ATTRIBUTE X_INTERFACE_INFO of REG1_CLK  : SIGNAL is "xilinx.com:interface:bram:1.0 REG1_BRAM CLK";
    ATTRIBUTE X_INTERFACE_INFO of REG1_RST  : SIGNAL is "xilinx.com:interface:bram:1.0 REG1_BRAM RST";

    ATTRIBUTE X_INTERFACE_INFO of REG2_EN   : SIGNAL is "xilinx.com:interface:bram:1.0 REG2_BRAM EN";
    ATTRIBUTE X_INTERFACE_INFO of REG2_WE   : SIGNAL is "xilinx.com:interface:bram:1.0 REG2_BRAM WE";
    ATTRIBUTE X_INTERFACE_INFO of REG2_DIN  : SIGNAL is "xilinx.com:interface:bram:1.0 REG2_BRAM DOUT";
    ATTRIBUTE X_INTERFACE_INFO of REG2_DOUT : SIGNAL is "xilinx.com:interface:bram:1.0 REG2_BRAM DIN";
    ATTRIBUTE X_INTERFACE_INFO of REG2_ADDR : SIGNAL is "xilinx.com:interface:bram:1.0 REG2_BRAM ADDR";
    ATTRIBUTE X_INTERFACE_INFO of REG2_CLK  : SIGNAL is "xilinx.com:interface:bram:1.0 REG2_BRAM CLK";
    ATTRIBUTE X_INTERFACE_INFO of REG2_RST  : SIGNAL is "xilinx.com:interface:bram:1.0 REG2_BRAM RST";


    signal s_blockAddress    : unsigned(REG_ADDR'left-16 downto 0);
    signal s_blockAddress_d1 : unsigned(REG_ADDR'left-16 downto 0) := (others => '0');
    signal s_blockAddress_d2 : unsigned(REG_ADDR'left-16 downto 0) := (others => '0');

    signal s_REG_EN_d1 : std_logic := '0';
    signal s_REG_EN_d2 : std_logic := '0';

begin
    -- Clocks
    REG0_CLK <= REG_CLK;
    REG1_CLK <= REG_CLK;
    REG2_CLK <= REG_CLK;
    -- Resets
    REG0_RST <= REG_RST;
    REG1_RST <= REG_RST;
    REG2_RST <= REG_RST;


    --|=======================================================================|--
    --| Read pipe
    --|=======================================================================|--
    s_blockAddress <= unsigned(REG_ADDR(REG_ADDR'left downto 16));
    process(REG_CLK) begin
        if rising_edge(REG_CLK) then
            s_blockAddress_d1 <= s_blockAddress;
            s_blockAddress_d2 <= s_blockAddress_d1;
            s_REG_EN_d1       <= REG_EN;
            s_REG_EN_d2       <= s_REG_EN_d1;
            if (s_REG_EN_d2 = '1') then
                case (s_blockAddress_d2) is
                    when to_unsigned(0, s_blockAddress_d2'length) =>
                        REG_DIN <= REG0_DIN;
                    when to_unsigned(1, s_blockAddress_d2'length) =>
                        REG_DIN <= REG1_DIN;
                    when to_unsigned(2, s_blockAddress_d2'length) =>
                        REG_DIN <= REG2_DIN;
                    when others =>
                        REG_DIN <= (others => '0');
                end case;
            end if;
        end if;
    end process;

    --|=======================================================================|--
    --| REG0
    --|=======================================================================|--
    process(REG_CLK) begin
        if rising_edge(REG_CLK) then
            if (REG_EN = '1' and s_blockAddress = 0) then
                REG0_EN <= '1';
            else
                REG0_EN <= '0';
            end if;
            REG0_WE   <= REG_WE;
            REG0_DOUT <= REG_DOUT;
            REG0_ADDR <= REG_ADDR(REG0_ADDR'left downto 0);
        end if;
    end process;

    --|=======================================================================|--
    --| REG1
    --|=======================================================================|--
    process(REG_CLK) begin
        if rising_edge(REG_CLK) then
            if (REG_EN = '1' and s_blockAddress = 1) then
                REG1_EN <= '1';
            else
                REG1_EN <= '0';
            end if;
            REG1_WE   <= REG_WE;
            REG1_DOUT <= REG_DOUT;
            REG1_ADDR <= REG_ADDR(REG1_ADDR'left downto 0);
        end if;
    end process;

    --|=======================================================================|--
    --| REG2
    --|=======================================================================|--
    process(REG_CLK) begin
        if rising_edge(REG_CLK) then
            if (REG_EN = '1' and s_blockAddress = 2) then
                REG2_EN <= '1';
            else
                REG2_EN <= '0';
            end if;
            REG2_WE   <= REG_WE;
            REG2_DOUT <= REG_DOUT;
            REG2_ADDR <= REG_ADDR(REG2_ADDR'left downto 0);
        end if;
    end process;

end arch_imp;
