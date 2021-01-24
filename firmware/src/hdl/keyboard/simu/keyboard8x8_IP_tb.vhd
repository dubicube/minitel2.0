--|==========================================================================|--
--|  ____        _    _  _              _                                    |--
--| |    \  _ _ | |_ |_|| |_  ___  ___ | |_                                  |--
--| |  |  || | || . || ||  _|| -_||  _||   |                                 |--
--| |____/ |___||___||_||_|  |___||___||_|_|                                 |--
--|                                                                          |--
--|==========================================================================|--
--| Module name: keyboard8x8_IP_tb                                           |--
--| Description: Testbench for module keyboard8x8_IP                         |--
--|                                                                          |--
--|==========================================================================|--
--| 24/01/2021 | Creation                                                    |--
--|            |                                                             |--
--|==========================================================================|--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity keyboard8x8_IP_tb is
end keyboard8x8_IP_tb;

architecture Behavioral of keyboard8x8_IP_tb is
   --|=======================================================================|--
   --| External entities
   --|=======================================================================|--
   component keyboard8x8_IP
   generic (
      C_FIFO_DEPTH       : integer := 8;
      C_S_AXI_DATA_WIDTH : integer := 32;
      C_S_AXI_ADDR_WIDTH : integer := 4
   );
   port (
      OUTPUTK       : out std_logic_vector(7 downto 0);
      INPUTK        : in  std_logic_vector(7 downto 0);
      FIFO_ITR      : out std_logic;
      S_AXI_ACLK    : in  std_logic;
      S_AXI_ARESETN : in  std_logic;
      S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in  std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID  : in  std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in  std_logic;
      S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in  std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in  std_logic
   );
   end component keyboard8x8_IP;
   constant C_S_AXI_DATA_WIDTH : integer := 32;
   constant C_S_AXI_ADDR_WIDTH : integer := 4;


   signal OUTPUTK       : std_logic_vector(7 downto 0);
   signal INPUTK        : std_logic_vector(7 downto 0);
   signal FIFO_ITR      : std_logic;
   signal S_AXI_ACLK    : std_logic;
   signal S_AXI_ARESETN : std_logic;
   signal S_AXI_AWADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
   signal S_AXI_AWPROT  : std_logic_vector(2 downto 0);
   signal S_AXI_AWVALID : std_logic;
   signal S_AXI_AWREADY : std_logic;
   signal S_AXI_WDATA   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
   signal S_AXI_WSTRB   : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
   signal S_AXI_WVALID  : std_logic;
   signal S_AXI_WREADY  : std_logic;
   signal S_AXI_BRESP   : std_logic_vector(1 downto 0);
   signal S_AXI_BVALID  : std_logic;
   signal S_AXI_BREADY  : std_logic;
   signal S_AXI_ARADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
   signal S_AXI_ARPROT  : std_logic_vector(2 downto 0);
   signal S_AXI_ARVALID : std_logic;
   signal S_AXI_ARREADY : std_logic;
   signal S_AXI_RDATA   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
   signal S_AXI_RRESP   : std_logic_vector(1 downto 0);
   signal S_AXI_RVALID  : std_logic;
   signal S_AXI_RREADY  : std_logic;

   --|=======================================================================|--
   --| Internal signals
   --|=======================================================================|--

   signal s_INPUTK  : std_logic_vector(7 downto 0);

   constant c_CLK_PERIOD : time := 10000 ps;

   signal CLK : std_logic;

begin


   keyboard8x8_IP_i : keyboard8x8_IP
   generic map (
      C_FIFO_DEPTH       => 8,
      C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
   )
   port map (
      OUTPUTK       => OUTPUTK,
      INPUTK        => INPUTK,
      FIFO_ITR      => FIFO_ITR,
      S_AXI_ACLK    => S_AXI_ACLK,
      S_AXI_ARESETN => S_AXI_ARESETN,
      S_AXI_AWADDR  => S_AXI_AWADDR,
      S_AXI_AWPROT  => S_AXI_AWPROT,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_WDATA   => S_AXI_WDATA,
      S_AXI_WSTRB   => S_AXI_WSTRB,
      S_AXI_WVALID  => S_AXI_WVALID,
      S_AXI_WREADY  => S_AXI_WREADY,
      S_AXI_BRESP   => S_AXI_BRESP,
      S_AXI_BVALID  => S_AXI_BVALID,
      S_AXI_BREADY  => S_AXI_BREADY,
      S_AXI_ARADDR  => S_AXI_ARADDR,
      S_AXI_ARPROT  => S_AXI_ARPROT,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RDATA   => S_AXI_RDATA,
      S_AXI_RRESP   => S_AXI_RRESP,
      S_AXI_RVALID  => S_AXI_RVALID,
      S_AXI_RREADY  => S_AXI_RREADY
   );
   S_AXI_ACLK <= CLK;


   s_INPUTK <= (others => 'H'); -- Weak pull up

   s_INPUTK(0) <= OUTPUTK(0);

   GEN_OUT : for I in 0 to 7 generate
      INPUTK(I) <= '0' when s_INPUTK(I)='0' else '1';
   end generate GEN_OUT;

   --|=======================================================================|--
   --| Process description
   --|=======================================================================|--
   process begin
      S_AXI_ARESETN <= '0';
      S_AXI_AWADDR  <= x"0";
      S_AXI_AWPROT  <= "000";
      S_AXI_AWVALID <= '0';
      S_AXI_WDATA   <= x"00000000";
      S_AXI_WSTRB   <= x"0";
      S_AXI_WVALID  <= '0';
      S_AXI_BREADY  <= '0';
      S_AXI_ARADDR  <= x"0";
      S_AXI_ARPROT  <= "000";
      S_AXI_ARVALID <= '0';
      S_AXI_RREADY  <= '0';
      wait for 1 us;
      S_AXI_ARESETN <= '1';
      wait for 327 us;
      S_AXI_ARADDR  <= x"8";
      S_AXI_ARVALID <= '1';
      wait for 2 * c_CLK_PERIOD;
      S_AXI_ARVALID <= '0';
      wait;
   end process;

   --|=======================================================================|--
   --| Process description
   --|=======================================================================|--
   process(CLK) begin
      if rising_edge(CLK) then
      end if;
   end process;

   --|=======================================================================|--
   --| Clocks
   --|=======================================================================|--
   process begin
      CLK <= '0';
      wait for c_CLK_PERIOD/2;
      CLK <= '1';
      wait for c_CLK_PERIOD/2;
   end process;

end Behavioral;
