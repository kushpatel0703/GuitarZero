//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              is_sprite_red,            // Whether current pixel belongs to ball
							  input					is_sprite_blue,
							  input					is_sprite_green,
							  input					is_sprite_orange,
							  input					is_sprite_yellow,
							  input					Clk,
                                                              //   or background (computed in ball.sv)
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
	 logic [23:0] do_yellow, do_green, do_blue, do_orange, do_red;
	 logic [12:0] read_address;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
	 assign read_address = DrawY * 10'd64 + DrawX;
	 
	 frameRAM_yellow(
		.read_address(read_address),
		.Clk(Clk),
		.data_Out(do_yellow)
	 );
	 
	 frameRAM_red(
		.read_address(read_address),
		.Clk(Clk),
		.data_Out(do_red)
	 );
	 
	 frameRAM_blue(
		.read_address(read_address),
		.Clk(Clk),
		.data_Out(do_blue)
	 );
	 
	 frameRAM_green(
		.read_address(read_address),
		.Clk(Clk),
		.data_Out(do_green)
	 );
	 
	 frameRAM_orange(
		.read_address(read_address),
		.Clk(Clk),
		.data_Out(do_orange)
	 );
	 
    
    // Assign color based on is_ball signal
    always_comb
    begin
        if (is_sprite_red == 1'b1) 
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
		  else if (is_sprite_blue == 1'b1) 
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
		  else if (is_sprite_green == 1'b1) 
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
		  else if (is_sprite_yellow == 1'b1) 
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
		  else if (is_sprite_orange == 1'b1) 
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
        else 
        begin
            // Background with nice color gradient
            Red = 8'h3f; 
            Green = 8'h00;
            Blue = 8'h7f - {1'b0, DrawX[9:3]};
        end
    end 
    
endmodule
