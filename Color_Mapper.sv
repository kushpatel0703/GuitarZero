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
		read_address_orange = draw_y_orange * 10'd40 + draw_x_orange;
		
		draw_x_red = DrawX - red_x_pos;
		draw_y_red = DrawY - red_y_pos;
		read_address_red = draw_y_red * 10'd40 + draw_x_red;
		
		draw_x_green = DrawX - green_x_pos;
		draw_y_green = DrawY - green_y_pos;
		read_address_green = draw_y_green * 10'd40 + draw_x_green;
		
		draw_x_blue = DrawX - blue_x_pos;
		draw_y_blue = DrawY - blue_y_pos;
		read_address_blue = draw_y_blue * 10'd40 + draw_x_blue;
		
		draw_x_yellow = DrawX - yellow_x_pos;
		draw_y_yellow = DrawY - yellow_y_pos;
		read_address_yellow = draw_y_yellow * 10'd40 + draw_x_yellow;
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
		  if (is_sprite_red == 1'b1 && do_red != 24'hffaec9) 
        begin
            // Red Sprite
            Red = do_red[23:16];
            Green = do_red[15:8];
            Blue = do_red[7:0];
        end
		  else if (is_sprite_blue == 1'b1 && do_blue != 24'hffaec9) 
        begin
            // Blue Sprite
            Red = do_blue[23:16];
            Green = do_blue[15:8];
            Blue = do_blue[7:0];
        end
		  else if (is_sprite_green == 1'b1 && do_green != 24'hffaec9) 
        begin
            // Green Sprite
            Red = do_green[23:16];
            Green = do_green[15:8];
            Blue = do_green[7:0];
        end
		  else if (is_sprite_yellow == 1'b1 && do_yellow != 24'hffaec9) 
        begin
            // Yellow Sprite
            Red = do_yellow[23:16];
            Green = do_yellow[15:8];
            Blue = do_yellow[7:0];
        end
		  else if (is_sprite_orange == 1'b1 && do_orange != 24'hffaec9) 
        begin
            // Orange Sprite
            Red = do_orange[23:16];
            Green = do_orange[15:8];
            Blue = do_orange[7:0];
        end
		  else if (DrawX > 149 && DrawX < 491 && DrawY > 419 && DrawY < 451)
		  begin
				Red = 8'hff;
				Green = 8'h39;
				Blue = 8'h88;
		  end
		  else if (DrawX > 144 && DrawX < 150) 
		  begin
				// Left Bar
				Red = 8'hC0;
				Green = 8'hC0;
				Blue = 8'hC0;
		  end
		  else if (DrawX > 490 && DrawX < 496) 
		  begin
				// Right Bar
				Red = 8'hC0;
				Green = 8'hC0;
				Blue = 8'hC0;
		  end
		  else if ((DrawX == 170) ||(DrawX == 245) ||(DrawX == 320) ||(DrawX ==395) || (DrawX ==470)) begin
				//Strings
				Red = 8'hF5;
				Green = 8'hF5;
				Blue = 8'hF5;
		  end
		  else if (DrawX > 149 && DrawX < 491)
		  begin
				//Fret-board
				Red = 8'h38;
				Green = 8'h00;
				Blue = 8'h00;
		  end
        else 
        begin
            // Background with nice color gradient
            Red = 8'h20; 
            Green = 8'h20;
            Blue = 8'h20;
        end
    end 
    
endmodule
