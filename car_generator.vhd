library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all ;

entity car_generator is
   port ( clk, resetN, start,stop      : in  std_logic                     ;
          array_size, car_size         : in  std_logic_vector (10 downto 0);
          lane1out,lane2out,lane3out   : out std_logic                     );
end car_generator ;

architecture t1 of car_generator is
   signal clk_s                      : std_logic ;
   signal flag1, flag2, flag3        : std_logic ;
   signal loop_count,loop_count_au   : integer   ;
   signal lane1, lane2, lane3        : std_logic ;
   
   type long_a_array1 is array (0 to 90) of std_logic ;
   type long_a_array2 is array (0 to 126) of std_logic ;
   type long_a_array3 is array (0 to 75) of std_logic ;
   
   constant seq1 : long_a_array1 := (
    "0000000000000000000001000000000000000000000000000000000010000000000000000000000000000000000"
    );
    constant seq2 : long_a_array2 := (
    "0000010000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000"
    );
    constant seq3 : long_a_array3 := (
    "0000000000000000000000000000010000000000000000000000000000000000100000000000"
    );
begin
   
   g2: entity work.clk_gen PORT MAP(
     clk => clk,
     clk_mod => clk_s,
     divide_value => 10 
   ); 
   
   process(clk_s,resetN)
      variable start_flag : std_logic ;
      variable array_count1,array_count2,array_count3 : integer ;
   begin
      if resetN = '0' then
         lane1  <= '0' ;
         lane2  <= '0' ;
         lane3  <= '0' ;
         array_count1 := 11 ;
         array_count2 := 25 ;
         array_count3 := 36 ;
         start_flag := '0' ;
      elsif rising_edge(clk_s) then
         if start = '0' then
            start_flag := '1' ;
         end if ;
         array_count1 := array_count1 + 1 ;
         array_count2 := array_count2 + 1 ;
         array_count3 := array_count3 + 1 ;
         if start_flag = '1' then
            lane1  <= seq1(array_count1) ;
            lane2  <= seq2(array_count2) ;
            lane3  <= seq3(array_count3) ;
         end if ;
         if array_count1 >= 91 then
            array_count1 := 0 ;
         end if ;
         if array_count2 >= 127 then
            array_count2 := 0 ;
         end if ;
         if array_count3 >= 76 then
            array_count3 := 0 ;
         end if ;
      end if ;
   end process ;
   
   process(clk,resetN)
   variable count1, count2, count3 : integer;
   begin
      if resetN = '0' then
         lane1out <= '0' ;
         lane2out <= '0' ;
         lane3out <= '0' ;
         flag1    <= '0' ;
         flag2    <= '0' ;
         flag3    <= '0' ;
      elsif rising_edge(clk) then
         lane1out <= '0' ;
         lane2out <= '0' ;
         lane3out <= '0' ;

         if lane1 = '1' then -- first lane car generator
            if stop = '0' then
               if flag1 = '0' then
                  flag1 <= '1' ;
                  count1 := 0 ; 
               end if ;
            end if ;
         end if ;
         
         if flag1 = '1' then
            if count1 <= loop_count then
               count1 := count1 + 1 ;
               lane1out <= '1' ;
            else
               flag1 <= '0';
               count1 := 0;
               lane1out <= '0' ;
            end if ;
         end if ;              -- first lane car generator
         
         
         if lane2 = '1' then -- second lane car generator
            if stop = '0' then
               if flag2 = '0' then
                  flag2 <= '1' ;
                  count2 := 0 ; 
               end if ;
            end if ;
         end if ;
         
         if flag2 = '1' then
            if count2 <= loop_count then
               count2 := count2 + 1 ;
               lane2out <= '1' ;
            else
               flag2 <= '0';
               count2 := 0;
               lane2out <= '0' ;
            end if ;
         end if ;              -- second lane car generator
         
         
         if lane3 = '1' then -- third lane car generator
            if stop = '0' then
               if flag3 = '0' then
                  flag3 <= '1' ;
                  count3 := 0 ; 
               end if ;
            end if ;
         end if ;
         
         if flag3 = '1' then
            if count3 <= loop_count then
               count3 := count3 + 1 ;
               lane3out <= '1' ;
            else
               flag3 <= '0';
               count3 := 0;
               lane3out <= '0' ;
            end if ;
         end if ;              -- third lane car generator
      end if ;   
   end process ;
   loop_count_au <= 640/conv_integer(array_size) ;
   loop_count <= conv_integer(car_size)/loop_count_au - 1;
end t1 ;		
