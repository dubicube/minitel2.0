--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--| dubicube@gmail.com                                                       |--
--|==========================================================================|--
--| Module name: uart_rx                                                     |--
--| Description: Just an UART receiver.                                      |--
--|                                                                          |--
--|==========================================================================|--
--| 01/01/2022 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
generic (
    g_CLOCK_FREQUENCY : integer := 60000000;
    g_BAUDRATE        : integer := 9600
);
port (
    CLK : in std_logic;

    -- UART RX input
    UART_RXD : in std_logic;

    -- Data output
    -- AXI stream, because it is cool
    M_AXIS_TDATA  : out std_logic_vector(7 downto 0) := (others => '0');
    M_AXIS_TVALID : out std_logic := '0';
    M_AXIS_TREADY : in std_logic;

    -- Valid when M_AXIS_TVALID is high
    -- Indicates stop bit has not been successfully detected
    FRAME_ERROR : out std_logic := '0';
    -- Valid when M_AXIS_TVALID is high
    -- Indicates some data has been lost because M_AXIS_TREADY
    -- was low for too long.
    OVERFLOW : out std_logic := '0'
);
end uart_rx;

architecture Behavioral of uart_rx is

    --|======================================================================|--
    --| Internal signals
    --|======================================================================|--

    -- Number of clock cycles for 1 bit on UART_RX input
    constant c_CLK_PER_BIT : integer := g_CLOCK_FREQUENCY/g_BAUDRATE;
    -- Number of clock cycles for 1 bit on UART_RX input, but divied by 2
    constant c_CLK_PER_BIT_DIV2 : integer := (g_CLOCK_FREQUENCY/g_BAUDRATE)/2;

    -- Prescaler to divide input CLK to baudrate
    signal s_prescaler : integer range 0 to c_CLK_PER_BIT-1;
    -- Indicates when prescaler as reached its top value
    signal s_prescaler_at_top : std_logic := '0';

    -- Output bit counter. Some kind of state machine state.
    signal s_bit_counter : unsigned(3 downto 0) := (others => '0');
    -- Shift register to shift bits of data to send
    signal s_shift_reg : std_logic_vector(7 downto 0) := (others => '0');

    -- Counter, not for the number of time you where high,
    -- but for the number of high bits (at '1') whithin a bit-window.
    -- Some kind of cheap average filter.
    signal s_high_counter : integer range 0 to c_CLK_PER_BIT-1 := c_CLK_PER_BIT-1;
    -- UART_RX after filter
    signal s_filtered_uart_rx : std_logic := '1';

    -- Just M_AXIS_TVALID
    signal s_M_AXIS_TVALID : std_logic := '0';

    -- Registers for meta-stability resolution
    signal s_uart_rx_d1 : std_logic := '1';
    signal s_uart_rx_d2 : std_logic := '1';

    -- Attribute to place registers as close as possible
    attribute ASYNC_REG : string;
    -- Attribute to not infer SRL
    attribute SHREG_EXTRACT : string;

    attribute ASYNC_REG     of s_uart_rx_d1, s_uart_rx_d2: signal is "TRUE";
    attribute SHREG_EXTRACT of s_uart_rx_d1, s_uart_rx_d2: signal is "NO";

begin

    --|======================================================================|--
    --| Input filtering
    --|======================================================================|--
    process(CLK) begin
        if rising_edge(CLK) then
            -- Metastability resolution
            s_uart_rx_d1 <= UART_RXD;
            s_uart_rx_d2 <= s_uart_rx_d1;

            -- s_high_counter
            if (s_uart_rx_d2 = '0') then
                if (s_high_counter > 0) then
                    s_high_counter <= s_high_counter - 1;
                end if;
            else
                if (s_high_counter < c_CLK_PER_BIT-1) then
                    s_high_counter <= s_high_counter + 1;
                end if;
            end if;

            -- s_filtered_uart_rx
            -- Maybe I should put an hysteresis here...
            if (s_high_counter < c_CLK_PER_BIT_DIV2) then
                s_filtered_uart_rx <= '0';
            else
                s_filtered_uart_rx <= '1';
            end if;
        end if;
    end process;

    --|======================================================================|--
    --| Shift register
    --|======================================================================|--
    process(CLK) begin
        if rising_edge(CLK) then
            if (s_prescaler_at_top = '1') then
                s_shift_reg <= s_filtered_uart_rx & s_shift_reg(s_shift_reg'left downto 1);
            end if;
        end if;
    end process;

    --|======================================================================|--
    --| AXI stream output
    --|======================================================================|--
    process(CLK) begin
        if rising_edge(CLK) then
            if (s_prescaler_at_top = '1' and s_bit_counter = 10) then
                M_AXIS_TDATA    <= s_shift_reg;
                s_M_AXIS_TVALID <= '1';
                FRAME_ERROR     <= not s_filtered_uart_rx;
                if (s_M_AXIS_TVALID = '1' and M_AXIS_TREADY = '0') then
                    OVERFLOW <= '1';
                else
                    OVERFLOW <= '0';
                end if;
            elsif (M_AXIS_TREADY = '1') then
                s_M_AXIS_TVALID <= '0';
                OVERFLOW        <= '0';
            end if;
        end if;
    end process;
    M_AXIS_TVALID <= s_M_AXIS_TVALID;

    --|======================================================================|--
    --| s_bit_counter
    --|======================================================================|--
    process(CLK) begin
        if rising_edge(CLK) then
            if (s_bit_counter = 0) then
                if (s_filtered_uart_rx = '0') then
                    s_bit_counter <= s_bit_counter + 1;
                end if;
            else
                if (s_prescaler_at_top = '1') then
                    if (s_bit_counter = 10) then
                        s_bit_counter <= (others => '0');
                    else
                        s_bit_counter <= s_bit_counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    --|======================================================================|--
    --| Prescaler
    --|======================================================================|--
    process(CLK) begin
        if rising_edge(CLK) then
            -- Just a basic counter
            if (s_bit_counter = 0) then
                -- Some kind of reset
                -- Start prescaler at half the top value, because we start when
                -- s_filtered_uart_rx toggles to low, and we want to sample
                -- this signal when it is stable.
                -- Thus, first prescaler period is half the full period
                -- to synchronize with moment when s_filtered_uart_rx is stable.
                s_prescaler <= c_CLK_PER_BIT_DIV2-1;
            else
                if (s_prescaler = c_CLK_PER_BIT-1) then
                    s_prescaler <= 0;
                else
                    s_prescaler <= s_prescaler + 1;
                end if;
            end if;
            -- Top flag
            -- Registered to minimize equations using the signal,
            -- to help routing algorithm in implementation
            if (s_prescaler = c_CLK_PER_BIT-2) then
                s_prescaler_at_top <= '1';
            else
                s_prescaler_at_top <= '0';
            end if;
        end if;
    end process;

end Behavioral;
