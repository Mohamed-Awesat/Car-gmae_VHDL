library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all;
LIBRARY ALTERA;
USE ALTERA.MAXPLUS2.ALL;

entity car_game is
   port ( clk_50, resetN1         : in  std_logic                    ;
          KEY0,KEY1,KEY2         : in  std_logic                     ;
          RED, GREEN, BLUE       : out std_logic_vector(3 downto 0)  ;          
          VERT_SYNC,HORIZ_SYNC   : out std_logic                   ) ;
end car_game ;

architecture game of car_game is
   
   component tff1 is -- T flip-flop
    port(
        t, clk  :   in std_logic;
        q        :  buffer std_logic);
   end component;
   
   component vgasync  -- syncronize the vga monitor
   port ( resetN    : in  std_logic                    ;
          clk       : in  std_logic                    ;
          sync_h    : out std_logic                    ;   -- horizontal sync
          sync_v    : out std_logic                    ;   -- vertical sync
          count_h   : out std_logic_vector(9 downto 0) ;   -- horizontal count
          count_v   : out std_logic_vector(9 downto 0) ;   -- vertical count
          frame_end : out std_logic                    ;   -- last pixle count
          frame_odd : out std_logic                    ;   -- odd frame count
          video     : out std_logic                    ) ;
   end component ;
   
   
   component pipe  -- delay signal by depth clock cycles
   generic ( depth : positive := 1  ) ;
   port ( resetN,clk,din : in  std_logic ;
          dout      : out std_logic);
   end component ;
   
   
   component rise is -- rise detector
   port ( resetN,clk,din : in  std_logic ;
          dout           : out std_logic ) ;
   end component ;


   component game_base -- main game control
   port ( clk, resetN            : in  std_logic                    ;
          count_h                : in  std_logic_vector(9 downto 0) ;
          count_v                : in  std_logic_vector(9 downto 0) ;
          k0,k2,start            : in  std_logic                    ;
		    counter1,counter2      : in std_logic_vector(3 downto 0)  ;
          counter3,counter4      : in std_logic_vector(3 downto 0)  ;
          red, green, blue       : out std_logic                    ;          
          stop                   : out std_logic                  ) ;
   end component ;
   
   
   component score_timer  -- bcd timer 
      port (clk,resetN,start,stop : in std_logic;
         counter1 : out std_logic_vector( 3 downto 0);
         counter2 : out std_logic_vector( 3 downto 0);
         counter3 : out std_logic_vector( 3 downto 0);
         counter4 : out std_logic_vector( 3 downto 0)
      );
   end component ;
   
   
   component dup4 -- duplicate color x4
   port ( din_r     : in   std_logic                    ;
          din_g     : in   std_logic                    ;
          din_b     : in   std_logic                    ;
          ena       : in   std_logic                    ;  
          dout_r    : out  std_logic_vector(3 downto 0) ;
          dout_g    : out  std_logic_vector(3 downto 0) ;
          dout_b    : out  std_logic_vector(3 downto 0) ) ;
   end component ;
   
   
   -------------------------------------------------------------
   
   signal clk : std_logic ;
   signal resetN : std_logic ;
   signal sync_h : std_logic ;
   signal sync_v : std_logic ;
   signal count_h : std_logic_vector(9 downto 0) ;
   signal count_v : std_logic_vector(9 downto 0) ;
   signal ena : std_logic ;
   signal k0 : std_logic ;
   signal k2 : std_logic ;
   signal stop : std_logic ;
   signal red0 : std_logic ;
   signal green0 : std_logic ;
   signal blue0 : std_logic ;
   signal video : std_logic ;
   signal counter1 : std_logic_vector(3 downto 0) ;
   signal counter2 : std_logic_vector(3 downto 0) ;
   signal counter3 : std_logic_vector(3 downto 0) ;
   signal counter4 : std_logic_vector(3 downto 0) ;
   
   
   
   
   
begin
   
   resetN <= not resetN1 ;
   
   t1:  tff1 PORT MAP (
      t => '1',
      clk => clk_50,
      q => clk
   );
   
   vga:  vgasync PORT MAP (
      resetN => resetN,  
      clk  => clk,    
      sync_h => sync_h, 
      sync_v => sync_v,
      video => video,
      count_h => count_h,
      count_v => count_v
   );
   
   p1:  pipe 
   generic map ( depth => 1 )
   PORT MAP (
      resetN => resetN,
      clk => clk,
      din => sync_h,
      dout => HORIZ_SYNC
   );
   
   p2:  pipe 
   generic map ( depth => 1 )
   PORT MAP (
      resetN => resetN,
      clk => clk,
      din => sync_v,
      dout => VERT_SYNC
   );
   
   p3:  pipe 
   generic map ( depth => 1 )
   PORT MAP (
      resetN => resetN,
      clk => clk,
      din => video,
      dout => ena
   );
   
   r1:  rise PORT MAP (
      resetN => resetN,
      clk => clk,
      din => not KEY0,
      dout => k0
   );
   
   r2:  rise PORT MAP (
      resetN => resetN,
      clk => clk,
      din => not KEY2,
      dout => k2
   );
   
   time1:  score_timer PORT MAP (
      clk => clk,
      resetN => resetN,
      start => KEY1,
      stop => stop,
      counter1 => counter1,
      counter2 => counter2,
      counter3 => counter3,
      counter4 => counter4
   );
   
   g11:  game_base PORT MAP (
      clk => clk,
      resetN => resetN,
      count_h => count_h,
      count_v => count_v,
      k0 => k0,
      k2 => k2,
      start => KEY1,
      counter1 => counter1,
      counter2 => counter2,
      counter3 => counter3,
      counter4 => counter4,
      red => red0,
      green => green0,
      blue => blue0,
      stop => stop
   );
   
   du:  dup4 PORT MAP (
      din_r => red0,
      din_g => green0,
      din_b => blue0,
      ena => ena,
      dout_r => RED,
      dout_g => GREEN,
      dout_b => BLUE
   );
   
end game ;