library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
        Port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_w     : in std_logic;
        
        o_z0    : out std_logic_vector(7 downto 0);
        o_z1    : out std_logic_vector(7 downto 0);
        o_z2    : out std_logic_vector(7 downto 0);
        o_z3    : out std_logic_vector(7 downto 0);
        o_done  : out std_logic;
        
        o_mem_addr  : out std_logic_vector(15 downto 0);
        i_mem_data  : in  std_logic_vector(7 downto 0);
        o_mem_we    : out std_logic;
        o_mem_en    : out std_logic
        );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type is (RST, WAIT_START, READ, ELAB, WAIT_PRINT, PRINT);
    signal s_curr, s_next: state_type;
    signal o_z0_next, o_z1_next, o_z2_next, o_z3_next : std_logic_vector(7 downto 0);
    signal o_done_next : std_logic;
    signal o_addr : std_logic_vector(15 downto 0); 
    signal o_select : std_logic_vector(0 to 1);
    signal count : integer range 0 to 15;
    signal c_clk : integer range 0 to 10;
    
begin    

    SL : process(i_rst, i_clk) --sync logic: update FSM status 
        begin
            if(i_rst = '1') then
                s_curr <= RST;
            elsif rising_edge(i_clk) then   
                s_curr <= s_next;
            end if;
    end process;
    
    OE : process(i_clk) --output entity
        begin
            o_done <= o_done_next;
            if (o_done_next = '1') then
                o_z0 <= o_z0_next;
                o_z1 <= o_z1_next;
                o_z2 <= o_z2_next;
                o_z3 <= o_z3_next;
            else
                o_z0 <= "00000000";
                o_z1 <= "00000000";
                o_z2 <= "00000000";
                o_z3 <= "00000000";
            end if;
    end process;
    
   TL : process(i_rst, i_start, i_mem_data, i_clk)
        begin 
            case s_curr is
                when RST => 
                    if (i_rst = '1') then
                        s_next <= RST;
                    elsif (i_rst = '0') then
                        s_next <= WAIT_START;
                    end if;
                when WAIT_START =>
                    if (i_start='0') then
                        s_next <= WAIT_START;
                    elsif (i_start='1') then
                        s_next <= READ;
                    end if;
                when READ =>
                    if(i_start='1') then
                        s_next <= READ;
                    elsif(i_start='0') then
                        s_next <= ELAB; 
                    end if;
                when ELAB =>
--                    if (i_mem_data'EVENT) then
                        s_next <= WAIT_PRINT;
--                    else 
--                        s_next <= ELAB;
--                    end if;
                when WAIT_PRINT =>
                    s_next <= PRINT; 
                when PRINT =>
                    s_next <= WAIT_START;
                end case;  
        end process;
        
  R : process(s_curr, i_clk)
    begin
        case s_curr is
            when RST =>
                -- code reusability
                o_z0_next <= (Others => '0'); 
                o_z1_next <= (Others => '0');
                o_z2_next <= (Others => '0');
                o_z3_next <= (Others => '0');
                o_done_next <= '0';
                o_mem_we <= '0';
                o_mem_en <= '0';
            when WAIT_START =>
                        count <= 1;
                        o_mem_we <= '0';
                        o_mem_en <= '0';
                        o_done_next <= '0';
                        o_addr <= (Others => '0');
                    if (rising_edge(i_clk) and i_start = '1') then
                        o_select(0) <= i_w;  
                    end if;
            when READ =>
                if(rising_edge(i_clk) and i_start = '1') then
                    if(count < o_select'LENGTH) then
                        o_select(count) <= i_w;
                    elsif (count >= o_select'LENGTH) then
                        o_addr(count-o_select'LENGTH) <= i_w;
                    end if;  
                    count <= count + 1; --# of bits
                end if;
            when ELAB =>
                   for i in 0 to o_mem_addr'LENGTH-1 loop
                       if(i < count - o_select'LENGTH) then
                            o_mem_addr(i) <= o_addr(count - o_select'LENGTH - 1 - i);
                       elsif(i >= count - o_select'LENGTH) then
                            o_mem_addr(i) <= '0';
                       end if;
                    end loop;
                    o_mem_en <= '1';
                    o_mem_we <= '0';
            when WAIT_PRINT =>
            when PRINT =>
                o_done_next <= '1';
                o_mem_en <= '0';
                if (o_select = "00") then
                    o_z0_next <= i_mem_data;
                elsif (o_select = "01") then
                    o_z1_next <= i_mem_data;
                elsif (o_select = "10") then
                    o_z2_next <= i_mem_data;
                elsif (o_select = "11") then
                    o_z3_next <= i_mem_data;
                end if;
            end case;
    end process;
    
end Behavioral;