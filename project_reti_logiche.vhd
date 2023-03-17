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
    type state_type is (WAIT_START, READ, WAIT_MEM, ELAB, PRINT);
    signal s_curr: state_type;
    signal o_z0_next, o_z1_next, o_z2_next, o_z3_next : std_logic_vector(7 downto 0);
    signal s_addr : std_logic_vector(15 downto 0);
    signal s_select : std_logic_vector(1 downto 0);
    signal flag : std_logic;
    
begin    

    process(i_clk,i_rst)
    begin
        if(i_rst='1') then
            o_done<='0';
            o_z0<=(others=>'0');
            o_z1<=(others=>'0');
            o_z2<=(others=>'0');
            o_z3<=(others=>'0');
            o_z0_next<=(others=>'0');
            o_z1_next<=(others=>'0');
            o_z2_next<=(others=>'0');
            o_z3_next<=(others=>'0');
            s_curr<=WAIT_START;
            
        elsif(rising_edge(i_clk)) then
            case s_curr is
                when WAIT_START =>
                    o_done<='0';
                    o_z0<=(others=>'0');
                    o_z1<=(others=>'0');
                    o_z2<=(others=>'0');
                    o_z3<=(others=>'0');
                    if(i_start='1') then
                        s_select(1)<=i_w;
                        flag<='0';
                        s_addr<=(others=>'0');
                        s_curr<=READ;
                    else 
                        s_curr<=WAIT_START;
                    end if;  
                                      
                when READ =>
                    if(i_start='1') then
                        if(flag = '0') then
                            s_select(0)<=i_w;
                            flag <= '1';
                        else
                            s_addr(15 downto 1)<=s_addr(14 downto 0);
                            s_addr(0)<=i_w;
                        end if;
                        s_curr<=READ;
                    else
                        o_mem_addr<=s_addr;
                        o_mem_we<='0';
                        o_mem_en<='1';
                        s_curr<=WAIT_MEM;
                    end if;
                    
                when WAIT_MEM =>
                    o_mem_en<='0';
                    o_mem_we<='0';
                    s_curr<=ELAB;
                    
                when ELAB =>
                    case s_select is
                        when "00" => o_z0_next <= i_mem_data;
                        when "01" => o_z1_next <= i_mem_data;
                        when "10" => o_z2_next <= i_mem_data;
                        when "11" => o_z3_next <= i_mem_data;
                        when others => null;
                    end case;
                    s_curr<=PRINT;
                
                when PRINT => 
                    o_z0<=o_z0_next;
                    o_z1<=o_z1_next;
                    o_z2<=o_z2_next;
                    o_z3<=o_z3_next;
                    o_done<='1';
                    s_curr<=WAIT_START;
                    
                when others => null;
            end case;
        end if;
    end process;
end Behavioral;