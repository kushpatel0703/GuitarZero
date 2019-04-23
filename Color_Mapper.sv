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
	 logic [12:0] read_address, read_address_orange;
	 logic [9:0] drawx_orange, drawy_orange;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
	 assign read_address = DrawY * 10'd64 + DrawX;
	 
	 always_comb begin
		drawx_orange = DrawX - 10'd240;
		drawy_orange = DrawY - 10'd240;
		read_address_orange = drawy_orange * 10'd64 + drawx_orange;
	 
	 end
	 
	 
	 frameRAM_yellow y(
		.read_address(read_address),
		.Clk(Clk),
		.data_Out(do_yellow)
	 );
	 
	 frameRAM_red r(
		.read_address(read_address),
		.Clk(Clk),
		.data_Out(do_red)
	 );
	 
	 frameRAM_blue b(
		.read_address(read_address),
		.Clk(Clk),
		.data_Out(do_blue)
	 );
	 
	 frameRAM_green g(
		.read_address(read_address),
		.Clk(Clk),
		.data_Out(do_green)
	 );
	 
	 frameRAM_orange o(
		.read_address(read_address_orange),
		.Clk(Clk),
		.data_Out(do_orange)
	 );
	 
    
    // Assign color based on is_ball signal
    always_comb
    begin
        if (is_sprite_red == 1'b1) 
        begin
            // White ball
            Red = do_red[23:16];
            Green = do_red[15:8];
            Blue = do_red[7:0];
        end
		  else if (is_sprite_blue == 1'b1) 
        begin
            // White ball
            Red = do_blue[23:16];
            Green = do_blue[15:8];
            Blue = do_blue[7:0];
        end
		  else if (is_sprite_green == 1'b1) 
        begin
            // White ball
            Red = do_green[23:16];
            Green = do_green[15:8];
            Blue = do_green[7:0];
        end
		  else if (is_sprite_yellow == 1'b1) 
        begin
            // White ball
            Red = do_yellow[23:16];
            Green = do_yellow[15:8];
            Blue = do_yellow[7:0];
        end
		  else if (is_sprite_orange == 1'b1) 
        begin
            // White ball
            Red = do_orange[23:16];
            Green = do_orange[15:8];
            Blue = do_orange[7:0];
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
