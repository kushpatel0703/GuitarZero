module scoring ( input       Clk,                // 50 MHz clock
                             Reset,             // Active-high reset signal
					  input [15:0] keycode,
					  input 		  player_flag,
					  input [9:0] orange_y_pos, yellow_y_pos, green_y_pos, blue_y_pos, red_y_pos,
					  output[7:0] score_1, score_2
              );
				  
				  logic [7:0] score_in_1, score_in_2;
				  logic 		  score_counted_g, score_counted_b, score_counted_y, score_counted_o, score_counted_r; 
				  logic       score_counted_in_g, score_counted_in_b, score_counted_in_y, score_counted_in_o, score_counted_in_r;
				  
				  always_ff @ (posedge Clk) begin
						if (Reset) begin
							score_1 <= 0;
							score_2 <= 0;
						end
						else begin
							score_1 <= score_in_1;
							score_2 <= score_in_2;
							score_counted_g <= score_counted_in_g;
							score_counted_b <= score_counted_in_b;
							score_counted_y <= score_counted_in_y;
							score_counted_o <= score_counted_in_o;
							score_counted_r <= score_counted_in_r;
						end
				  end
				  
				  always_comb begin
				     score_in_1 = score_1;
					  score_in_2 = score_2;
					  score_counted_in_g = score_counted_g;
					  score_counted_in_b = score_counted_b;
					  score_counted_in_y = score_counted_y;
					  score_counted_in_r = score_counted_r;
					  score_counted_in_o = score_counted_o;
					  
					  if (green_y_pos > 410 && green_y_pos < 440 && keycode == 16'h8f7f && score_counted_g == 1'b0) begin
							if (player_flag == 1'b1) begin
								score_in_1 = score_1 + 1'b1;
								score_counted_in_g = 1'b1;
							end
							else begin
								score_in_2 = score_2 + 1'b1;
								score_counted_in_g = 1'b1;
							end
					  end 
					  else if (green_y_pos > 440) begin
							score_counted_in_g = 1'b0;
					  end
					  
					  if (red_y_pos > 410 && red_y_pos < 440 && keycode == 16'h2f7f && score_counted_r == 1'b0) begin
							if (player_flag == 1'b1) begin
								score_in_1 = score_1 + 1'b1;
								score_counted_in_r = 1'b1;
							end
							else begin
								score_in_2 = score_2 + 1'b1;
								score_counted_in_r = 1'b1;
							end
					  end 
					  else if (red_y_pos > 440) begin
							score_counted_in_r = 1'b0;
					  end
					  
					  if (yellow_y_pos > 410 && yellow_y_pos < 440 && keycode == 16'h4f7f && score_counted_y == 1'b0) begin
							if (player_flag == 1'b1) begin
								score_in_1 = score_1 + 1'b1;
								score_counted_in_y = 1'b1;
							end
							else begin
								score_in_2 = score_2 + 1'b1;
								score_counted_in_y = 1'b1;
							end
					  end 
					  else if (yellow_y_pos > 440) begin
							score_counted_in_y = 1'b0;
					  end
					  
					  if (blue_y_pos > 410 && blue_y_pos < 440 && keycode == 16'h1f7f && score_counted_b == 1'b0) begin
							if (player_flag == 1'b1) begin
								score_in_1 = score_1 + 1'b1;
								score_counted_in_b = 1'b1;
							end
							else begin
								score_in_2 = score_2 + 1'b1;
								score_counted_in_b = 1'b1;
							end
					  end 
					  else if (blue_y_pos > 440) begin
							score_counted_in_b = 1'b0;
					  end
					  
					  if (orange_y_pos > 410 && orange_y_pos < 440 && keycode == 16'h0f00 && score_counted_o == 1'b0) begin
							if (player_flag == 1'b1) begin
								score_in_1 = score_1 + 1'b1;
								score_counted_in_o = 1'b1;
							end
							else begin
								score_in_2 = score_2 + 1'b1;
								score_counted_in_o = 1'b1;
							end
					  end 
					  else if (orange_y_pos > 440) begin
							score_counted_in_o = 1'b0;
					  end
				  end
				  
endmodule 