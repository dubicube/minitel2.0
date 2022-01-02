--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--| dubicube@gmail.com                                                       |--
--|==========================================================================|--
--| Module name: uart_tx                                                     |--
--| Description: Just an UART transmitter.                                   |--
--|                                                                          |--
--|==========================================================================|--
--| 01/01/2022 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
generic (
    g_CLOCK_FREQUENCY : integer := 60000000;
    g_BAUDRATE        : integer := 9600
);
port (
    CLK : in std_logic;

    -- UART TX output
    UART_TXD : out std_logic := '1';

    -- Data input
    -- AXI stream, because it is cool
    S_AXIS_TDATA  : in std_logic_vector(7 downto 0);
    S_AXIS_TVALID : in std_logic;
    S_AXIS_TREADY : out std_logic := '0'
);
end uart_tx;

architecture Behavioral of uart_tx is

    --|======================================================================|--
    --| Internal signals
    --|======================================================================|--

    -- Number of clock cycles for 1 bit on UART_TX output
    constant c_CLK_PER_BIT : integer := g_CLOCK_FREQUENCY/g_BAUDRATE;

    -- Prescaler to divide input CLK to baudrate
    signal s_prescaler : integer range 0 to c_CLK_PER_BIT-1;
    -- Indicates when prescaler as reached its top value
    signal s_prescaler_at_top : std_logic := '0';

    -- Output bit counter. Some kind of state machine state.
    signal s_bit_counter : unsigned(3 downto 0) := (others => '0');
    -- Shift register to shift bits of data to send
    signal s_shift_reg : std_logic_vector(9 downto 0) := (others => '0');


begin

    --|======================================================================|--
    --| UART_TXD
    --|======================================================================|--
    process(CLK) begin
        if rising_edge(CLK) then
            -- Wait for data to send
            if (s_bit_counter = 0) then
                UART_TXD <= '1';
            -- Send bits
            elsif (s_bit_counter >= 1 and s_bit_counter <= 10) then
                UART_TXD <= s_shift_reg(0);
            end if;
        end if;
    end process;

    --|======================================================================|--
    --| Shift register
    --|======================================================================|--
    process(CLK) begin
        if rising_edge(CLK) then
            if (s_bit_counter = 0) then
                s_shift_reg <= "1" & S_AXIS_TDATA & "0";
            elsif (s_bit_counter >= 1 and s_bit_counter <= 10) then
                if (s_prescaler_at_top = '1') then
                    s_shift_reg <= "0" & s_shift_reg(s_shift_reg'left downto 1);
                end if;
            end if;
        end if;
    end process;

    --|======================================================================|--
    --| s_bit_counter
    --|======================================================================|--
    process(CLK) begin
        if rising_edge(CLK) then
            if (s_bit_counter = 0) then
                if (S_AXIS_TVALID = '1') then
                    s_bit_counter <= s_bit_counter + 1;
                    S_AXIS_TREADY <= '0';
                end if;
            else
                if (s_prescaler_at_top = '1') then
                    if (s_bit_counter = 10) then
                        s_bit_counter <= (others => '0');
                        S_AXIS_TREADY <= '1';
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
                s_prescaler <= 0;
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
