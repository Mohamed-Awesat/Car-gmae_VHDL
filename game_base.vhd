library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all ;
library lpm ;
use lpm.lpm_components.all ;

entity game_base is
   port ( clk, resetN            : in  std_logic                    ;
          count_h                : in  std_logic_vector(9 downto 0) ;
          count_v                : in  std_logic_vector(9 downto 0) ;
          k0,k2,start            : in  std_logic                    ;
		    counter1,counter2      : in std_logic_vector(3 downto 0)  ;
          counter3,counter4      : in std_logic_vector(3 downto 0)  ;
          red, green, blue       : out std_logic                    ;          
          stop                   : out std_logic                  ) ;
end game_base ;


architecture t1 of game_base is

   signal car_position : std_logic_vector(1 downto 0); -- wich lane the car in
   signal street_dash : std_logic_vector(63 downto 0); 
   signal s_clk : std_logic ;
   signal fail : std_logic ; -- up when a crash occur 
   signal clk_dash,clk_cars  :  std_logic ;
   signal divide_value :  integer ;
   
   -- screen res 640x480 @60Hz
   constant lane_width : integer := 60 ; -- space between lane lines
   constant lane_line_width : integer := 7 ; -- width of the lane line rec. 7
   constant lane_start : integer := 136 ; -- where the first lane starts rec. 136
   constant car_size_horizontal  : integer := 60 ; -- car width rec. 60
   constant car_size_vertical  : integer := 30 ; -- car height rec. 30
   constant array_size  : integer := 160 ; -- array size to move cars (how many steps)
   constant step_size   : integer := 640/array_size ; -- cars movement step size
   constant car_start_position_v : integer := lane_start + lane_line_width + (( lane_width - car_size_vertical )/2) ; -- the start of the car vertical
   constant car_end_position_v : integer := car_start_position_v + car_size_vertical ; -- the end of the car vertical
   constant car_start_position_h : integer := 30 ; -- the start of the car horizontal 
   constant car_end_position_h : integer := car_start_position_h + car_size_horizontal ; -- the end of the car horizontal
   
   signal lane1out,lane2out,lane3out : std_logic ;
   signal cars1,cars2,cars3 : std_logic_vector(array_size-1 downto 0) ;
   signal start_flag : std_logic ;
   
   signal  coh   :  std_logic_vector(2 downto 0) ;
   signal  cov   :  std_logic_vector(2 downto 0) ;
   signal  h     :  std_logic_vector(8 downto 0) ;
   signal  v     :  std_logic_vector(8 downto 0) ;
   
   signal internal_rom_address : std_logic_vector(11 downto 0) ;
   signal internal_rom_data    : std_logic_vector(0 downto 0 ) ;
   
   signal char_code            : std_logic_vector(5 downto 0) ;
   signal pospix_v             : std_logic_vector(2 downto 0) ;
   signal pospix_h             : std_logic_vector(2 downto 0) ;
   
   signal int_char_code        : std_logic_vector(5 downto 0) ;
   signal int_pospix_h         : std_logic_vector(2 downto 0) ;
   signal int_pospix_v         : std_logic_vector(2 downto 0) ;
   signal int_poschr_h         : std_logic_vector(6 downto 0) ;
   signal int_poschr_v         : std_logic_vector(6 downto 0) ;
   
   signal lane1crash           : std_logic ;
   signal lane2crash           : std_logic ;
   signal lane3crash           : std_logic ;
   
begin
	  -- Component Instantiation
   g1: entity work.clk_gen PORT MAP( -- create clock for dashed lines
           clk => clk,
           clk_mod => clk_dash,
           divide_value => 1250000 -- 20 Hz 
   );
   
   g2: entity work.clk_gen PORT MAP( -- create 100Hz clock for the other cars
           clk => clk,
           clk_mod => clk_cars,
           divide_value => divide_value -- 156250 -- 250000 
   ); 
  
   cg1: entity work.car_generator PORT MAP ( 
               clk => clk_cars,
               resetN => resetN,    
               array_size => std_logic_vector(to_unsigned(array_size, 11)),
               car_size => std_logic_vector(to_unsigned(car_size_horizontal, 11)),       
               lane1out => lane1out,
               lane2out => lane2out,
               lane3out => lane3out,
               start => start,
               stop => fail
   );
  
   int_pospix_h <= count_h(3 downto 1) ;
   int_poschr_h <= '0' & count_h(9 downto 4) ;
   int_pospix_v <= count_v(3 downto 1) ;
   int_poschr_v <= '0' & count_v(9 downto 4) ;
   
   process (int_poschr_h, int_poschr_v,fail,counter1,counter2,counter3,counter4,start_flag)
   begin 
      int_char_code <= "110000" ; -- space default value
      
      case conv_integer(int_poschr_v) is -- display text
         when 1 => -- chose what text to display based on the state of the game
            if fail = '1' then 
               case conv_integer(int_poschr_h) is
                  when   14   => int_char_code <= "010000" ; -- G
                  when   15   => int_char_code <= "001010" ; -- A
                  when   16   => int_char_code <= "010110" ; -- M
                  when   17   => int_char_code <= "001110" ; -- E
                  when   18   => int_char_code <= "110000" ; -- space
                  when   19   => int_char_code <= "011000" ; -- O
                  when   20   => int_char_code <= "011111" ; -- V
                  when   21   => int_char_code <= "001110" ; -- E
                  when   22   => int_char_code <= "011011" ; -- R
                  when   23   => int_char_code <= "110000" ; -- space
                  when   24   => int_char_code <= "100101" ; -- !
                  when   25   => int_char_code <= "100101" ; -- !
                  when others => int_char_code <= "110000" ; -- space   
               end case ;
            elsif start_flag = '0'then
               case conv_integer(int_poschr_h) is
                  when   11  => int_char_code  <= "011001" ; -- P
                  when   12  => int_char_code  <= "011011" ; -- R
                  when   13   => int_char_code <= "001110" ; -- E
                  when   14   => int_char_code <= "001110" ; -- E
                  when   15   => int_char_code <= "011100" ; -- S
                  when   16   => int_char_code <= "110000" ; -- space
                  when   17   => int_char_code <= "010100" ; -- K
                  when   18   => int_char_code <= "001110" ; -- E
                  when   19   => int_char_code <= "100010" ; -- Y
                  when   20   => int_char_code <= "000001" ; -- 1
                  when   21   => int_char_code <= "110000" ; -- space
                  when   22   => int_char_code <= "011101" ; -- T
                  when   23   => int_char_code <= "011000" ; -- O
                  when   24   => int_char_code <= "110000" ; -- space
                  when   25   => int_char_code <= "011100" ; -- S
                  when   26   => int_char_code <= "011101" ; -- T
                  when   27   => int_char_code <= "001010" ; -- A
                  when   28   => int_char_code <= "011011" ; -- R
                  when   29   => int_char_code <= "011101" ; -- T
                  when others => int_char_code <= "110000" ; -- space   
               end case ;
            end if ;
			   
         when 25 =>
            case conv_integer(int_poschr_h) is
               when 2      => int_char_code <= "011100" ; -- S
               when 3      => int_char_code <= "001100" ; -- C
               when 4      => int_char_code <= "011000" ; -- O
               when 5      => int_char_code <= "011011" ; -- R
               when 6      => int_char_code <= "001110" ; -- E
               when 7      => int_char_code <= "110000" ; -- space
               when 8      => int_char_code <= "00" & counter4;
               when 9      => int_char_code <= "00" & counter3;
               when 10     => int_char_code <= "00" & counter2;
               when 11     => int_char_code <= "00" & counter1;
               when others => int_char_code <= "110000" ; -- space      
            end case ;
            
            if counter3 >= 5 then
               case conv_integer(int_poschr_h) is
                  when 2      => int_char_code <= "011100" ; -- S
                  when 3      => int_char_code <= "001100" ; -- C
                  when 4      => int_char_code <= "011000" ; -- O
                  when 5      => int_char_code <= "011011" ; -- R
                  when 6      => int_char_code <= "001110" ; -- E
                  when 7      => int_char_code <= "110000" ; -- space
                  when 8      => int_char_code <= "00" & counter4;
                  when 9      => int_char_code <= "00" & counter3;
                  when 10     => int_char_code <= "00" & counter2;
                  when 11     => int_char_code <= "00" & counter1;
                  
                  when 26     => int_char_code <= "011100" ; -- S
                  when 27     => int_char_code <= "011001" ; -- P
                  when 28     => int_char_code <= "001110" ; -- E
                  when 29     => int_char_code <= "001110" ; -- E
                  when 30     => int_char_code <= "001101" ; -- D
                  when 32     => int_char_code <= "011110" ; -- U
                  when 33     => int_char_code <= "011001" ; -- P
                  when others => int_char_code <= "110000" ; -- space      
               end case ;
            end if ;
         when others => int_char_code <= "110000" ; -- space    
      end case ;
   end process ;
   
   process(clk) -- synchronize the text display controls
   begin
      if clk'event and clk = '1' then 
         char_code <= int_char_code ;
         pospix_h  <= int_pospix_h  ;
         pospix_v  <= int_pospix_v  ;  
               
      end if ;
   end process ;
   
   -- rom to save characters
   internal_rom_address <= char_code & pospix_v & pospix_h ;
   r1: lpm_rom
   generic map (
      lpm_widthad         => 12             , 
      lpm_numwords        => 4096           ,
      lpm_outdata         => "REGISTERED"   ,
      lpm_address_control => "UNREGISTERED" ,
      lpm_file            => "CHRGEN8.MIF"  ,
      lpm_width           => 1              )
   port map (
      address             => internal_rom_address ,
      outclock            => clk                  ,
      q                   => internal_rom_data    ) ;
      
   
	process (count_h, count_v,fail,internal_rom_data,cars1,cars2,cars3,street_dash,car_position)  -- display process
	variable car_place,c : integer ;
	 
	begin
      red   <= '0' ;
      green <= '0' ;
      blue  <= '0' ;
      
      if fail = '1' then
         red <= internal_rom_data(0) ;
      else 
         blue <= internal_rom_data(0) ;
      end if ;
		
		
      if ((count_v >= lane_start) and (count_v <= lane_start + lane_line_width)) then -- first line
         red <= '1' ;
         green <= '1' ;
         blue <= '1' ;
      elsif ((count_v >= lane_start + 3*(lane_width + lane_line_width)) and (count_v <= lane_start + 3*(lane_width + lane_line_width) + lane_line_width)) then -- line 4
         red <= '1' ;
         green <= '1' ;
         blue <= '1' ;
      end if ;
      
      
      
      for i in 0 to array_size-1 loop
         if cars1(i) = '1' then
            if (count_h >= i*step_size ) and (count_h <= i*step_size + step_size) then
               if (count_v >= car_start_position_v ) and (count_v <= car_end_position_v ) then
                  green <= '1' ;
                  blue  <= '1' ;
               end if;
            end if ;
         end if;
         
         if cars2(i) = '1' then
            if (count_h >= i*step_size ) and (count_h <= i*step_size + step_size ) then
               if (count_v >= car_start_position_v + (lane_width+lane_line_width)) and (count_v <= car_end_position_v + (lane_width+lane_line_width)) then
                  green <= '1' ;
                  blue  <= '1' ;
               end if;
            end if ;
         end if;
         
         if cars3(i) = '1' then
            if (count_h >= i*step_size ) and (count_h <= i*step_size + step_size ) then
               if (count_v >= car_start_position_v + 2*(lane_width+lane_line_width)) and (count_v <= car_end_position_v + 2*(lane_width+lane_line_width)) then
                  green <= '1' ;
                  blue  <= '1' ;
               end if;
            end if ;
         end if;
      end loop ;
      
      for j in 0 to 63 loop  -- painting the street (dashed street)
         if( street_dash(j) = '1') then
            if ((count_v >= lane_start + (lane_width + lane_line_width)) and (count_v <= lane_start + (lane_width + lane_line_width) + lane_line_width)) or 
               ((count_v >= lane_start + 2*(lane_width + lane_line_width)) and (count_v <= lane_start + 2*(lane_width + lane_line_width) + lane_line_width)) 
               then
               if (count_h >= j*10) and (count_h <=(j+1)*10) then -- since the array size is 64 then each one represents 10 pixles 
                  red <= '1' ;
                  green <= '1' ;
                  blue <= '1' ;
               end if ;
            end if ;
         end if ;
      end loop ;
      
      -- car_position movement
      if (count_h >= car_start_position_h) and (count_h <= car_end_position_h) then -- car_position from 100 to 200
         c := conv_integer(car_position);
         car_place := c*(lane_width+lane_line_width);
         if (count_v >= car_start_position_v + car_place) and (count_v <= car_end_position_v + car_place) then
            red   <= '1' ;
            green <= '1' ;
            blue  <= '0' ;
            if fail = '1' then
               green <= '0' ;
            end if ;
         end if;
      end if;
   end process ;
   
   process(clk, resetN) -- keep track of the player input to change position of the car_position
   begin
      if resetN = '0' then 
         car_position <= (others => '0') ;
      elsif clk'event and clk = '1' then 
         if fail = '0' then 
            if k0 = '1' then
               if (car_position < 2) then
                     car_position <= car_position + 1 ;
                  end if ;
            end if;
            if k2 = '1' then
               if (car_position > 0) then
                     car_position <= car_position - 1 ;
               end if ;
            end if;
         end if ;
	   end if ;
	end process ;
	
	process(clk_dash,resetN) -- move the dashed line
		variable i0 : std_logic;
	begin
		 if resetN = '0' then 
			for i in 0 to 63 loop 
				street_dash(i) <= '1';
				if( i mod 4 = 0) then
					street_dash(i) <= '0';
				end if ;
			end loop ;
		 elsif rising_edge(clk_dash) then -- shift register
         if fail = '0' then 
            i0 := street_dash(0);
            for i in 0 to 63 loop 
               
               if i /= 63 then
                  street_dash(i) <= street_dash(i+1);
               else 
                  street_dash(63) <= i0 ;
               end if ;
            end loop ;
         end if ;
      end if ;
	end process ;
   
   process(clk_cars,resetN) -- cars and lanes and stuff
      variable crash_counter : integer ; 
      variable move1,move2,move3 : std_logic ;
   begin
      if resetN = '0' then
         cars1 <= (others => '0') ;
         cars2 <= (others => '0') ;
         cars3 <= (others => '0') ;
         crash_counter := array_size ;
         move1 := '1' ;
         move2 := '1' ;
         move3 := '1' ;
      elsif rising_edge(clk_cars) then
         if fail = '0' then 
            move1 := '1' ;
            move2 := '1' ;
            move3 := '1' ;
         else
            if crash_counter > 0 then
               crash_counter := crash_counter - 1 ;
               if lane1crash = '1' then
                  move1 := '0' ;
               end if ;
               if lane2crash = '1' then
                  move2 := '0' ;   
               end if ;
               if lane3crash = '1' then
                  move3 := '0' ;
               end if ;
            else
               move1 := '0' ;
               move2 := '0' ;
               move3 := '0' ;
            end if ;
         end if ;
         
         if move1 = '1' then
            for i in 0 to array_size-2 loop
               cars1(i) <= cars1(i+1);
            end loop ;
            cars1(array_size-1) <= lane1out;
         end if ;
         if move2  = '1' then
            for i in 0 to array_size-2 loop
               cars2(i) <= cars2(i+1);
            end loop ;
            cars2(array_size-1) <= lane2out;
         end if ;
         if move3 = '1' then
            for i in 0 to array_size-2 loop
               cars3(i) <= cars3(i+1);
            end loop ;
            cars3(array_size-1) <= lane3out;
         end if ;
      end if ;
   end process ;
   
   process (clk_cars,resetN)
   begin
      if resetN = '0' then
         fail <= '0';
         lane1crash <= '0' ;
         lane2crash <= '0' ;
         lane3crash <= '0' ;
      elsif rising_edge(clk_cars) then
         for i in 0 to array_size-1 loop
            if i*step_size >= car_start_position_h and i*step_size <= car_end_position_h then
               if car_position = 0 then
                  if cars1(i) = '1' then
                     fail <= '1';
                     lane1crash <= '1' ;
                  end if ;
               elsif car_position = 1 then
                  if cars2(i) = '1' then
                     fail <= '1';
                     lane2crash <= '1' ;
                  end if ;
               else
                  if cars3(i) = '1' then
                     fail <= '1';
                     lane3crash <= '1' ;
                  end if ;
               end if ;
            end if ;
         end loop ;
      end if;
   end process ;
   
   process(clk,resetN)
   begin
      if resetN = '0' then
         start_flag <= '0';
      elsif rising_edge(clk) then
         if start = '0' then 
            start_flag <= '1' ;
         end if ;
      end if ;
   end process ;
   
   process(counter3) -- change speed based on score
   begin
      if counter3 >= 5 then
         divide_value <= 15000;--156250 ;-- 250000
      else
         divide_value <= 156250;--250000 ;
      end if ;
   end process ;
   
   stop <= fail ;
end t1 ;		


