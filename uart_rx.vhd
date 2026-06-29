library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Port (
        clk_16x     : in  STD_LOGIC; 
        reset       : in  STD_LOGIC;
        rx_serial   : in  STD_LOGIC;
        rx_data     : out STD_LOGIC_VECTOR (7 downto 0);
        rx_done     : out STD_LOGIC;
        err_frame   : out STD_LOGIC  
    );
end uart_rx;

architecture Behavioral of uart_rx is
    type state_type is (ST_IDLE, ST_START, ST_DATA, ST_STOP);
    signal state : state_type := ST_IDLE;
    
    signal sample_count : integer range 0 to 15 := 0;
    signal bit_index    : integer range 0 to 7 := 0;
    signal data_buffer  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin
    process(clk_16x, reset)
    begin
        if reset = '1' then
            state <= ST_IDLE;
            rx_done <= '0';
            err_frame <= '0';
            sample_count <= 0;
            bit_index <= 0;
            rx_data <= (others => '0');
        elsif rising_edge(clk_16x) then
            rx_done <= '0';
            case state is
                when ST_IDLE =>
                    sample_count <= 0;
                    bit_index <= 0;
                    if rx_serial = '0' then 
                        state <= ST_START;
                    end if;
                when ST_START =>
                    if sample_count = 7 then 
                        if rx_serial = '0' then
                            sample_count <= 0;
                            state <= ST_DATA;
                        else
                            state <= ST_IDLE; 
                        end if;
                    else
                        sample_count <= sample_count + 1;
                    end if;
                when ST_DATA =>
                    if sample_count = 15 then 
                        sample_count <= 0;
                        data_buffer(bit_index) <= rx_serial;
                        if bit_index = 7 then
                            state <= ST_STOP;
                        else
                            bit_index <= bit_index + 1;
                        end if;
                    else
                        sample_count <= sample_count + 1;
                    end if;
                when ST_STOP =>
                    if sample_count = 15 then 
                        sample_count <= 0;
                        if rx_serial = '1' then
                            rx_data <= data_buffer;
                            rx_done <= '1';
                            err_frame <= '0';
                        else
                            err_frame <= '1'; 
                        end if;
                        state <= ST_IDLE;
                    else
                        sample_count <= sample_count + 1;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
