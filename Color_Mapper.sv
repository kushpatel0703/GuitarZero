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
							  input 			[9:0] orange_x_pos, orange_y_pos, red_x_pos, red_y_pos, green_x_pos, green_y_pos, blue_x_pos, blue_y_pos, yellow_x_pos, yellow_y_pos,
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
	 logic [23:0] do_yellow, do_green, do_blue, do_orange, do_red;
	 logic [12:0] read_address_orange, read_address_red, read_address_blue, read_address_green, read_address_yellow;
	 logic [9:0] draw_x_orange, draw_y_orange, draw_x_red, draw_y_red, draw_x_blue, draw_y_blue, draw_x_green, draw_y_green, draw_x_yellow, draw_y_yellow;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
	 
	 always_comb begin
		draw_x_orange = DrawX - orange_x_pos;
		draw_y_orange = DrawY - orange_y_pos;
		read_address_orange = draw_y_orange * 10'd64 + draw_x_orange;
		
		draw_x_red = DrawX - red_x_pos;
		draw_y_red = DrawY - red_y_pos;
		read_address_red = draw_y_red * 10'd64 + draw_x_red;
		
		draw_x_green = DrawX - green_x_pos;
		draw_y_green = DrawY - green_y_pos;
		read_address_green = draw_y_green * 10'd64 + draw_x_green;
		
		draw_x_blue = DrawX - blue_x_pos;
		draw_y_blue = DrawY - blue_y_pos;
		read_address_blue = draw_y_blue * 10'd64 + draw_x_blue;
		
		draw_x_yellow = DrawX - yellow_x_pos;
		draw_y_yellow = DrawY - yellow_y_pos;
		read_address_yellow = draw_y_yellow * 10'd64 + draw_x_yellow;
	 end
	 
	 
	 frameRAM_yellow y(
		.read_address(read_address_yellow),
		.Clk(Clk),
		.data_Out(do_yellow)
	 );
	 
	 frameRAM_red r(
		.read_address(read_address_red),
		.Clk(Clk),
		.data_Out(do_red)
	 );
	 
	 frameRAM_blue b(
		.read_address(read_address_blue),
		.Clk(Clk),
		.data_Out(do_blue)
	 );
	 
	 frameRAM_green g(
		.read_address(read_address_green),
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
