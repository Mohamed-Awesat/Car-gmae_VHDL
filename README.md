# Car-gmae_VHDL
A simplified version of  the game traffic racer. Created with VHDL running on FPGA and displayed with VGA monitor.

A bit about the files:
car_game - a file that connects everything together. 
game_base - control the player's car, show text and display the elements of the game.
car_generator - generate the cars in each lane based on the car size and array size (how many steps each car moves).
score_timer - 4 bcd timers to count the score.
clk_gen - divide the clock by divide.
vgasyn - synchronize the design to the monitor.
pipe - delay the input signal by depth clock cycles.
rise - rise detector, to move only one step when clicking the buttons.
dffx - d flip flop.
tff1 - T flip flop.
dup4 - duplicate the red, green and blue bits for simplicity (8 colors are enough).
chargen8.MIF - character masks  to display.
de._pins.tcl - tcl commands to assign the pins easily. the source : http://www.aztech.co.il/BRPortal/br/P102.jsp?arc=349423
