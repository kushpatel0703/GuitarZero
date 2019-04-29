//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Nikhil Parmar & Kush Patel                                       --
//      Spring 2019                                                      --
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab Final Proj                              --
//-------------------------------------------------------------------------


module toplevel(
				input               CLOCK_50,
            input        [3:0]  KEY,          //bit 0 is set up as Reset
            output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
				
				
				//Audio Interface
				input logic AUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,
				output logic AUD_DACDAT, AUD_MCLK, I2C_SCLK, I2C_SDAT,
				
				output logic [19:0] SRAM_ADDR,
				inout wire   [15:0] SRAM_DQ,
				output logic        SRAM_UB_N,
										  SRAM_LB_N,
										  SRAM_CE_N,
										  SRAM_OE_N,
										  SRAM_WE_N,
				
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA vertical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
											
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
				 
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	 
    logic Reset_h, Clk, is_sprite_red, is_sprite_blue, is_sprite_green, is_sprite_yellow, is_sprite_orange;
    logic [7:0] keycode;
	 logic [3:0] toHex;
	 logic [9:0] DrawX;
	 logic [9:0] DrawY;
	 
	 logic [3:0] toHex00;
	 logic [3:0] toHex01;
	 logic [3:0] toHex02;
	 logic [3:0] toHex03;
	 logic [3:0] toHex10;
	 logic [3:0] toHex11;
	 logic [3:0] toHex12;
	 logic [3:0] toHex13;
	 
	 logic [9:0] orange_x_pos, orange_y_pos, yellow_x_pos, yellow_y_pos, red_x_pos, red_y_pos, blue_x_pos, blue_y_pos, green_x_pos, green_y_pos;
	 
	 
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
		 .Clk(Clk),
		 .Reset(Reset_h),
		 // signals connected to NIOS II
		 .from_sw_address(hpi_addr),
		 .from_sw_data_in(hpi_data_in),
		 .from_sw_data_out(hpi_data_out),
		 .from_sw_r(hpi_r),
		 .from_sw_w(hpi_w),
		 .from_sw_cs(hpi_cs),
		 .from_sw_reset(hpi_reset),
		 // signals connected to EZ-OTG chip
		 .OTG_DATA(OTG_DATA),    
		 .OTG_ADDR(OTG_ADDR),    
		 .OTG_RD_N(OTG_RD_N),    
		 .OTG_WR_N(OTG_WR_N),    
		 .OTG_CS_N(OTG_CS_N),
		 .OTG_RST_N(OTG_RST_N)
	);

     finalproj_soc nios_system(
		  .clk_clk(Clk),         
		  .reset_reset_n(1'b1),    // Never reset NIOS
		  .sdram_wire_addr(DRAM_ADDR), 
		  .sdram_wire_ba(DRAM_BA),   
		  .sdram_wire_cas_n(DRAM_CAS_N),
		  .sdram_wire_cke(DRAM_CKE),  
		  .sdram_wire_cs_n(DRAM_CS_N), 
		  .sdram_wire_dq(DRAM_DQ),   
		  .sdram_wire_dqm(DRAM_DQM),  
		  .sdram_wire_ras_n(DRAM_RAS_N),
		  .sdram_wire_we_n(DRAM_WE_N), 
		  .sdram_clk_clk(DRAM_CLK),
		  .keycode_export(keycode),  
		  .otg_hpi_address_export(hpi_addr),
		  .otg_hpi_data_in_port(hpi_data_in),
		  .otg_hpi_data_out_port(hpi_data_out),
		  .otg_hpi_cs_export(hpi_cs),
		  .otg_hpi_r_export(hpi_r),
		  .otg_hpi_w_export(hpi_w),
		  .otg_hpi_reset_export(hpi_reset)
	);
 
 
	vga_clk vga_clk_instance(
		.inclk0(Clk),
		.c0(VGA_CLK)
	);
	 

	 VGA_controller vga_controller_instance(
		.Clk(Clk),        
		.Reset(Reset_h),
		.VGA_CLK(VGA_CLK),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_HS(VGA_HS),     
		.VGA_VS(VGA_VS),          
		.DrawX(DrawX),
		.DrawY(DrawY)
	);

    
	music_statemachine msm(
		.CLK(Clk),
		.RESET(Reset_h),
		.MUS_DONE(MUS_DONE), //Signal 
		.debug00(toHex00[3:0]),
		.debug01(toHex01[3:0]),
		.debug02(toHex02[3:0]),
		.debug03(toHex03[3:0]),
		.debug10(toHex10[3:0]),
		.debug11(toHex11[3:0]),
		.debug12(toHex12[3:0]),
		.debug13(toHex13[3:0]),
		.AUD_ADCDAT, .AUD_DACLRCK, .AUD_ADCLRCK, .AUD_BCLK,
		.AUD_DACDAT, .AUD_MCLK, .I2C_SCLK, .I2C_SDAT,
		.SRAM_ADDR, .SRAM_DQ, .SRAM_UB_N, .SRAM_LB_N, .SRAM_CE_N, .SRAM_OE_N, .SRAM_WE_N	
		
	);  

	
	
	color_mapper col(
		.is_sprite_red(is_sprite_red),
		.is_sprite_blue(is_sprite_blue),
		.is_sprite_green(is_sprite_green),
		.is_sprite_yellow(is_sprite_yellow),
		.is_sprite_orange(is_sprite_orange),
		.orange_x_pos(orange_x_pos),
		.orange_y_pos(orange_y_pos),
		.red_x_pos(red_x_pos),
	   .red_y_pos(red_y_pos),
		.blue_x_pos(blue_x_pos),
	   .blue_y_pos(blue_y_pos),
		.green_x_pos(green_x_pos),
	   .green_y_pos(green_y_pos),
		.yellow_x_pos(yellow_x_pos),
	   .yellow_y_pos(yellow_y_pos),
		.Clk(Clk),
		.DrawX(DrawX),
		.DrawY(DrawY),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B)
	);
	
	
	sprite_red r1(
	  .Clk(Clk),         
	  .Reset(Reset_h),       
	  .frame_clk(VGA_VS),   
	  .DrawX(DrawX),
	  .DrawY(DrawY),
	  .is_sprite_red(is_sprite_red),  
	  .keycode(keycode),
	  .red_x_pos(red_x_pos),
	  .red_y_pos(red_y_pos)
	);
	
	
	sprite_blue b1(
	  .Clk(Clk),         
	  .Reset(Reset_h),       
	  .frame_clk(VGA_VS),   
	  .DrawX(DrawX),
	  .DrawY(DrawY),
	  .is_sprite_blue(is_sprite_blue),  
	  .keycode(keycode),
	  .blue_x_pos(blue_x_pos),
	  .blue_y_pos(blue_y_pos)
	);
	
	
	sprite_green g1(
	  .Clk(Clk),         
	  .Reset(Reset_h),       
	  .frame_clk(VGA_VS),   
	  .DrawX(DrawX),
	  .DrawY(DrawY),
	  .is_sprite_green(is_sprite_green),  
	  .keycode(keycode),
	  .green_x_pos(green_x_pos),
	  .green_y_pos(green_y_pos)
	);

	
	sprite_yellow y1(
	  .Clk(Clk),         
	  .Reset(Reset_h),       
	  .frame_clk(VGA_VS),   
	  .DrawX(DrawX),
	  .DrawY(DrawY),
	  .is_sprite_yellow(is_sprite_yellow),  
	  .keycode(keycode),
	  .yellow_x_pos(yellow_x_pos),
	  .yellow_y_pos(yellow_y_pos)
	);
	
	sprite_orange o1(
	  .Clk(Clk),         
	  .Reset(Reset_h),       
	  .frame_clk(VGA_VS),   
	  .DrawX(DrawX),
	  .DrawY(DrawY),
	  .is_sprite_orange(is_sprite_orange),  
	  .keycode(keycode),
	  .orange_x_pos(orange_x_pos),
	  .orange_y_pos(orange_y_pos)
	);


    // Display keycode on hex display
    HexDriver hex_inst_0 (toHex00[3:0], HEX0);
    HexDriver hex_inst_1 (toHex01[3:0], HEX1);
	 HexDriver hex_inst_2 (toHex02[3:0], HEX2);
    HexDriver hex_inst_3 (toHex03[3:0], HEX3);
	 
	 HexDriver hex_inst_4 (toHex10[3:0], HEX4);
    HexDriver hex_inst_5 (toHex11[3:0], HEX5);
	 HexDriver hex_inst_6 (toHex12[3:0], HEX6);
    HexDriver hex_inst_7 (toHex13[3:0], HEX7);
    
endmodule
