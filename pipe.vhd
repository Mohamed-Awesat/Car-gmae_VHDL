library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
entity pipe is
   generic ( depth : positive := 3  ) ;
   port ( resetN,clk,din : in  std_logic ;
          dout      : out std_logic);
end pipe ;
architecture arc_pipe of pipe is
   component dffx is
      port ( resetN, clk,d   : in  std_logic ;
             q     : out std_logic );
   end component dffx ;
   signal d : std_logic_vector(depth downto 0) ;
begin
   d(depth) <= din ;
   ui: for i in 0 to depth-1 generate
      u: dffx port map (resetN,clk,d(i+1),d(i)) ;
   end generate ;
   dout <= d(0) ;
end arc_pipe ;
