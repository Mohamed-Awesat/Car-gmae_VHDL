library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

LIBRARY work;

ENTITY score_timer is 
port (clk,resetN,start,stop : in std_logic;
      counter1 : out std_logic_vector( 3 downto 0);
      counter2 : out std_logic_vector( 3 downto 0);
      counter3 : out std_logic_vector( 3 downto 0);
      counter4 : out std_logic_vector( 3 downto 0)
      );
end score_timer ;

architecture arc_timer of score_timer is 
   
   component clk_gen 
   port(   Clk          :   in  std_logic;
         Clk_mod      :   out std_logic;
         divide_value :   in  integer
         );
   end component;

   signal c1 : std_logic_vector(3 downto 0) := "0000";
   signal c2 : std_logic_vector(3 downto 0) := "0000";
   signal c3 : std_logic_vector(3 downto 0) := "0000";
   signal c4 : std_logic_vector(3 downto 0) := "0000";
   signal flag : std_logic ;
   signal clk_slowed : Std_logic ;
   
begin 
   
   process(clk_slowed,resetN)
   begin
      if resetN = '0' then
         flag <= '0'  ;
         c1 <= "0000" ;
         c2 <= "0000" ;
         c3 <= "0000" ;
         c4 <= "0000" ;
      elsif rising_edge(clk_slowed) then
         if stop = '1' then 
            flag <= '0' ;
         elsif start = '0' then
            flag <= '1';
         end if ;
         
         if flag = '1' then 
            if c1 < "1001" then 
               c1 <= c1 + "0001" ;
            elsif c1 = "1001" and c2 /= "1001" then 
               c1 <= "0000" ;
            end if ;
            
            if c2 < "1001" and c1 = "1001" then 
               c2 <= c2 + "0001" ;
            elsif c2 = "1001" and c3 /= "1001" then 
               c2 <= "0000" ;
            end if ;
            
            if c3 < "1001" and c2 = "1001" then 
               c3 <= c3 + "0001" ;
            elsif c3 = "1001" and c4 /= "1001" then 
               c3 <= "0000" ;
            end if ;
            
            if c4 < "1001" and c3 = "1001" then 
               c4 <= c4 + "0001" ;
            end if ;
         
         end if ;
      end if ;
   
   end process;
   b2v_inst5 : clk_gen 
   port map (clk => clk,
         clk_mod => clk_slowed,
         divide_value => 1562500);
      
   counter1 <= c1 ;
   counter2 <= c2 ;
   counter3 <= c3 ;
   counter4 <= c4 ; 	 
   

		 
		 
end arc_timer ;