library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_uart is
    Generic (
        CLK_FREQ  : integer := 100_000_000; 
        BAUD_RATE : integer := 9600
    );
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        rx_serial   : in  STD_LOGIC;
        tx_serial   : out STD_LOGIC;
        err_led     : out STD_LOGIC
    );
end top_uart;

architecture Structural of top_uart is
    constant DIVIDER_16X : integer := CLK_FREQ / (BAUD_RATE * 16);
    
    signal clk_div_count : integer := 0;
    signal clk_16x       : std_logic := '0';
    signal tx_clk_count  : integer range 0 to 15 := 0;
    signal clk_tx        : std_logic := '0';
    
    signal w_rx_data     : std_logic_vector(7 downto 0);
    signal w_rx_done     : std_logic;
    signal w_tx_busy     : std_logic;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            clk_div_count <= 0;
            clk_16x <= '0';
        elsif rising_edge(clk) then
            if clk_div_count = (DIVIDER_16X - 1) then
                clk_div_count <= 0;
                clk_16x <= not clk_16x;
            else
                clk_div_count <= clk_div_count + 1;
            end if;
        end if;
    end process;

    process(clk_16x, reset)
    begin
        if reset = '1' then
            tx_clk_count <= 0;
            clk_tx <= '0';
        elsif rising_edge(clk_16x) then
            if tx_clk_count = 15 then
                tx_clk_count <= 0;
                clk_tx <= '1'; 
            else
                tx_clk_count <= tx_clk_count + 1;
                clk_tx <= '0';
            end if;
        end if;
    end process;

    RX_INST: entity work.uart_rx
        port map(clk_16x => clk_16x, reset => reset, rx_serial => rx_serial,
                 rx_data => w_rx_data, rx_done => w_rx_done, err_frame => err_led);

    TX_INST: entity work.uart_tx
        port map(clk => clk_tx, reset => reset, tx_start => w_rx_done,
                 tx_data => w_rx_data, tx_serial => tx_serial, tx_busy => w_tx_busy);
end Structural;
