library ieee;
use ieee.std_logic_1164.all;

entity tff1 is
    port(
        t, clk  :  in  std_logic;
        q        :  buffer std_logic);
   end tff1;


architecture tff_arch of tff1 is
begin
    process(clk)
    begin
        if rising_edge(Clk)
        then
            if t = '1' then
               q <= not q;
            end if;
        end if;
    end process;
end tff_arch;