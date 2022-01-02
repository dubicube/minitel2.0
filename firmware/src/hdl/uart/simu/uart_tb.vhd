--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--| dubicube@gmail.com                                                       |--
--|==========================================================================|--
--| Module name: uart_tb                                                     |--
--| Description: Testbench for uart_tx and uart_rx modules.                  |--
--|                                                                          |--
--|==========================================================================|--
--| 01/01/2022 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity uart_tb is
end uart_tb;

architecture Behavioral of uart_tb is

    --|======================================================================|--
    --| External entities
    --|======================================================================|--

    component uart_tx
    generic (
        g_CLOCK_FREQUENCY : integer := 60000000;
        g_BAUDRATE        : integer := 9600
    );
    port (
        CLK           : in  std_logic;
        UART_TXD      : out std_logic;
        S_AXIS_TDATA  : in  std_logic_vector(7 downto 0);
        S_AXIS_TVALID : in  std_logic;
        S_AXIS_TREADY : out std_logic
    );
    end component uart_tx;
    signal CLK           : std_logic;
    signal UART_TXD      : std_logic;
    signal S_AXIS_TDATA  : std_logic_vector(7 downto 0);
    signal S_AXIS_TVALID : std_logic;
    signal S_AXIS_TREADY : std_logic;

    constant g_CLOCK_FREQUENCY : integer := 100000000;
    constant g_BAUDRATE        : integer := 9600;


    component uart_rx
    generic (
        g_CLOCK_FREQUENCY : integer := 60000000;
        g_BAUDRATE        : integer := 9600
    );
    port (
        CLK           : in  std_logic;
        UART_RXD      : in  std_logic;
        M_AXIS_TDATA  : out std_logic_vector(7 downto 0);
        M_AXIS_TVALID : out std_logic;
        M_AXIS_TREADY : in  std_logic
    );
    end component uart_rx;
    -- signal CLK           : std_logic;
    signal UART_RXD      : std_logic;
    signal M_AXIS_TDATA  : std_logic_vector(7 downto 0);
    signal M_AXIS_TVALID : std_logic;
    signal M_AXIS_TREADY : std_logic;


    --|======================================================================|--
    --| Internal signals
    --|======================================================================|--

    constant c_CLK_PERIOD : time := 10000 ps;


begin

    uart_tx_i : uart_tx
    generic map (
        g_CLOCK_FREQUENCY => g_CLOCK_FREQUENCY,
        g_BAUDRATE        => g_BAUDRATE
    )
    port map (
        CLK           => CLK,
        UART_TXD      => UART_TXD,
        S_AXIS_TDATA  => S_AXIS_TDATA,
        S_AXIS_TVALID => S_AXIS_TVALID,
        S_AXIS_TREADY => S_AXIS_TREADY
    );
    uart_rx_i : uart_rx
    generic map (
        g_CLOCK_FREQUENCY => g_CLOCK_FREQUENCY,
        g_BAUDRATE        => g_BAUDRATE
    )
    port map (
        CLK           => CLK,
        UART_RXD      => UART_RXD,
        M_AXIS_TDATA  => M_AXIS_TDATA,
        M_AXIS_TVALID => M_AXIS_TVALID,
        M_AXIS_TREADY => M_AXIS_TREADY
    );

    UART_RXD      <= UART_TXD;


    process begin
        S_AXIS_TDATA  <= x"FF";
        S_AXIS_TVALID <= '0';
        wait for 10*c_CLK_PERIOD;
        S_AXIS_TDATA  <= x"5A";
        S_AXIS_TVALID <= '1';
        wait for 1*c_CLK_PERIOD;
        S_AXIS_TDATA  <= x"69";
        S_AXIS_TVALID <= '1';
        wait;
    end process;

    process begin
        M_AXIS_TREADY <= '0';
        wait for 2700 us;
        M_AXIS_TREADY <= '1';
        wait;
    end process;

    process(CLK) begin
        if rising_edge(CLK) then

        end if;
    end process;

    process begin
        CLK <= '0';
        wait for c_CLK_PERIOD/2;
        CLK <= '1';
        wait for c_CLK_PERIOD/2;
    end process;
end Behavioral;
