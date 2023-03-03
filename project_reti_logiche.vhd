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
    type state_type is (RST, WAIT_START, READ, ELAB, PRINT);
    signal o_z0_next, o_z1_next, o_z2_next, o_z3_next : std_logic_vector(7 downto 0);
    signal o_done_next : std_logic;
    signal s_curr, s_next: state_type;
    signal o_addr: std_logic_vector(0 to 15);
    signal count : integer range 0 to 3 ;
    signal o_select : std_logic_vector(0 to 1);
    
    
begin

    OL : process(i_rst, i_clk) --Reset e output
    begin
        if(i_rst = '1') then
            s_curr <= RST;
        elsif rising_edge(i_clk) then   
            s_curr <= s_next;
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
       end if;
    end process OL;
    
    R : process(i_start, i_w, i_mem_data)
    begin
        case s_curr is
            when RST =>
                o_z0 <= "00000000";
                o_z1 <= "00000000";
                o_z2 <= "00000000";
                o_z3 <= "00000000";
                o_done <= '0';
            when WAIT_START =>
                if (i_start='1') then
                    count <= 0;
                end if;
            when READ =>
                if(i_start='1') then
                    if(count<2) then
                        o_select(count) <= i_w;
                    else
                        o_addr(count) <= i_w;
                    end if;  
                    count <= count + 1;
                end if;
            when ELAB =>
                if(o_done_next='0') then
                    for i in 0 to 15 loop
                        if(i<count+1) then
                            --o_mem_addr <= ((15-i) => o_addr(count-i));
                            o_mem_addr(15-i)<=o_addr(count-i);
                        end if;
                    end loop;
                    o_mem_addr <= (Others => '0');
                    o_mem_we <= '0';
                    o_mem_en <= '1';
                           --Modulo Memoria
                    o_done_next <= '1';              
                end if;
            when PRINT =>
                case o_select is
                    when "00" =>
                        o_z0_next <= i_mem_data;
                    when "01" =>
                        o_z1_next <= i_mem_data;
                    when "10" =>
                        o_z2_next <= i_mem_data;
                    when "11" =>
                        o_z3_next <= i_mem_data;
                end case;
        end case;
    end process R;
    
    TL : process(i_rst, i_clk, i_start, o_done_next)
        begin 
            if rising_edge(i_clk) then
                        case s_curr is
                            when RST => 
                                if (i_rst = '1') then
                                    s_next <= s_curr;
                                elsif (i_rst = '0') then
                                    s_next <= WAIT_START;
                                end if;
                            when WAIT_START =>
                                if (i_start='0') then
                                    s_next <= s_curr;
                                elsif (i_start='1') then
                                    s_next <= READ; 
                                end if;
                            when READ =>
                                if(i_start='1') then
                                    s_next <= s_curr;
                                elsif(i_start='0') then
                                    s_next <= ELAB; 
                                end if;
                            when ELAB =>
                                if(o_done_next='0') then
                                    s_next <= s_curr;
                                elsif(o_done_next='1') then
                                    s_next <= PRINT;
                                end if;
                             when PRINT =>
                                s_next <= WAIT_START;
                        end case;  
            end if;   
        end process TL;

end Behavioral;
