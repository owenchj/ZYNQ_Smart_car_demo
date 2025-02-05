
`timescale 1 ns / 1 ps

//`include "ultrasonic_control_v1_0_tb_include.vh"

// lite_response Type Defines
`define RESPONSE_OKAY 2'b00
`define RESPONSE_EXOKAY 2'b01
`define RESP_BUS_WIDTH 2
`define BURST_TYPE_INCR  2'b01
`define BURST_TYPE_WRAP  2'b10

// AMBA AXI4 Lite Range Constants
`define S00_AXI_MAX_BURST_LENGTH 1
`define S00_AXI_DATA_BUS_WIDTH 32
`define S00_AXI_ADDRESS_BUS_WIDTH 32
`define S00_AXI_MAX_DATA_SIZE (`S00_AXI_DATA_BUS_WIDTH*`S00_AXI_MAX_BURST_LENGTH)/8

// AMBA AXI4 Lite Range Constants
`define S_AXI_INTR_MAX_BURST_LENGTH 1
`define S_AXI_INTR_DATA_BUS_WIDTH 32
`define S_AXI_INTR_ADDRESS_BUS_WIDTH 32
`define S_AXI_INTR_MAX_DATA_SIZE (`S_AXI_INTR_DATA_BUS_WIDTH*`S_AXI_INTR_MAX_BURST_LENGTH)/8

module ultrasonic_control_v1_0_tb;
	reg tb_ACLK;
	reg tb_ARESETn;
	wire tb_irq;

	// Create an instance of the example tb
	ultrasonic_control_v1_0 dut (.ACLK(tb_ACLK),
				.ARESETN(tb_ARESETn),
				.irq(tb_irq));

	// Local Variables

	// AMBA S00_AXI AXI4 Lite Local Reg
	reg [`S00_AXI_DATA_BUS_WIDTH-1:0] S00_AXI_rd_data_lite;
	reg [`S00_AXI_DATA_BUS_WIDTH-1:0] S00_AXI_test_data_lite [3:0];
	reg [`RESP_BUS_WIDTH-1:0] S00_AXI_lite_response;
	reg [`S00_AXI_ADDRESS_BUS_WIDTH-1:0] S00_AXI_mtestAddress;
	reg [3-1:0]   S00_AXI_mtestProtection_lite;
	integer S00_AXI_mtestvectorlite; // Master side testvector
	integer S00_AXI_mtestdatasizelite;

	// AMBA S_AXI_INTR Interrupt AXI4 Lite Local Reg
	reg [`S_AXI_INTR_DATA_BUS_WIDTH-1:0] S_AXI_INTR_globalenData;
	reg [`S_AXI_INTR_DATA_BUS_WIDTH-1:0] S_AXI_INTR_intrenData;
	reg [`S_AXI_INTR_DATA_BUS_WIDTH-1:0] S_AXI_INTR_pendData;
	reg [`S_AXI_INTR_DATA_BUS_WIDTH-1:0] S_AXI_INTR_ackData;
	reg [`S_AXI_INTR_ADDRESS_BUS_WIDTH-1:0] S_AXI_INTR_globalenAddress;
	reg [`S_AXI_INTR_ADDRESS_BUS_WIDTH-1:0] S_AXI_INTR_intrenAddress;
	reg [`S_AXI_INTR_ADDRESS_BUS_WIDTH-1:0] S_AXI_INTR_pendAddress;	
	reg [`S_AXI_INTR_ADDRESS_BUS_WIDTH-1:0] S_AXI_INTR_ackAddress;
	reg [`RESP_BUS_WIDTH-1:0] S_AXI_INTR_lite_response;
	reg [3-1:0] S_AXI_INTR_mtestProtection_lite;
	integer S_AXI_INTR_mtestdatasizelite;
	integer result_slave_lite;


	// Simple Reset Generator and test
	initial begin
		tb_ARESETn = 1'b0;
	  #500;
		// Release the reset on the posedge of the clk.
		@(posedge tb_ACLK);
	  tb_ARESETn = 1'b1;
		@(posedge tb_ACLK);
	end

	// Simple Clock Generator
	initial tb_ACLK = 1'b0;
	always #10 tb_ACLK = !tb_ACLK;

	//------------------------------------------------------------------------
	// TEST LEVEL API: CHECK_RESPONSE_OKAY
	//------------------------------------------------------------------------
	// Description:
	// CHECK_RESPONSE_OKAY(lite_response)
	// This task checks if the return lite_response is equal to OKAY
	//------------------------------------------------------------------------
	task automatic CHECK_RESPONSE_OKAY;
		input [`RESP_BUS_WIDTH-1:0] response;
		begin
		  if (response !== `RESPONSE_OKAY) begin
			  $display("TESTBENCH ERROR! lite_response is not OKAY",
				         "\n expected = 0x%h",`RESPONSE_OKAY,
				         "\n actual   = 0x%h",response);
		    $stop;
		  end
		end
	endtask

	//------------------------------------------------------------------------
	// TEST LEVEL API: COMPARE_LITE_DATA
	//------------------------------------------------------------------------
	// Description:
	// COMPARE_LITE_DATA(expected,actual)
	// This task checks if the actual data is equal to the expected data.
	// X is used as don't care but it is not permitted for the full vector
	// to be don't care.
	//------------------------------------------------------------------------
	`define S_AXI_DATA_BUS_WIDTH 32 
	task automatic COMPARE_LITE_DATA;
		input [`S_AXI_DATA_BUS_WIDTH-1:0]expected;
		input [`S_AXI_DATA_BUS_WIDTH-1:0]actual;
		begin
			if (expected === 'hx || actual === 'hx) begin
				$display("TESTBENCH ERROR! COMPARE_LITE_DATA cannot be performed with an expected or actual vector that is all 'x'!");
		    result_slave_lite = 0;
		    $stop;
		  end

			if (actual != expected) begin
				$display("TESTBENCH ERROR! Data expected is not equal to actual.",
				         "\nexpected = 0x%h",expected,
				         "\nactual   = 0x%h",actual);
		    result_slave_lite = 0;
		    $stop;
		  end
			else 
			begin
			   $display("TESTBENCH Passed! Data expected is equal to actual.",
			            "\n expected = 0x%h",expected,
			            "\n actual   = 0x%h",actual);
			end
		end
	endtask

	task automatic S00_AXI_TEST;
		begin
			$display("---------------------------------------------------------");
			$display("EXAMPLE TEST : S00_AXI");
			$display("Simple register write and read example");
			$display("---------------------------------------------------------");

			S00_AXI_mtestvectorlite = 0;
			S00_AXI_mtestAddress = 32'h44A10000;
			S00_AXI_mtestProtection_lite = 0;
			S00_AXI_mtestdatasizelite = 32;

			 result_slave_lite = 1;

			for (S00_AXI_mtestvectorlite = 0; S00_AXI_mtestvectorlite <= 3; S00_AXI_mtestvectorlite = S00_AXI_mtestvectorlite + 1)
			begin
			  dut.ultrasonic_control_v1_0_S00_AXI_inst.master_0.cdn_axi4_lite_master_bfm_inst.WRITE_BURST_CONCURRENT( S00_AXI_mtestAddress,
				                     S00_AXI_mtestProtection_lite,
				                     S00_AXI_test_data_lite[S00_AXI_mtestvectorlite],
				                     S00_AXI_mtestdatasizelite,
				                     S00_AXI_lite_response);
			  $display("EXAMPLE TEST %d write : DATA = 0x%h, lite_response = 0x%h",S00_AXI_mtestvectorlite,S00_AXI_test_data_lite[S00_AXI_mtestvectorlite],S00_AXI_lite_response);
			  CHECK_RESPONSE_OKAY(S00_AXI_lite_response);
			  dut.ultrasonic_control_v1_0_S00_AXI_inst.master_0.cdn_axi4_lite_master_bfm_inst.READ_BURST(S00_AXI_mtestAddress,
				                     S00_AXI_mtestProtection_lite,
				                     S00_AXI_rd_data_lite,
				                     S00_AXI_lite_response);
			  $display("EXAMPLE TEST %d read : DATA = 0x%h, lite_response = 0x%h",S00_AXI_mtestvectorlite,S00_AXI_rd_data_lite,S00_AXI_lite_response);
			  CHECK_RESPONSE_OKAY(S00_AXI_lite_response);
			  COMPARE_LITE_DATA(S00_AXI_test_data_lite[S00_AXI_mtestvectorlite],S00_AXI_rd_data_lite);
			  $display("EXAMPLE TEST %d : Sequential write and read burst transfers complete from the master side. %d",S00_AXI_mtestvectorlite,S00_AXI_mtestvectorlite);
			  S00_AXI_mtestAddress = S00_AXI_mtestAddress + 32'h00000004;
			end

			$display("---------------------------------------------------------");
			$display("EXAMPLE TEST S00_AXI: PTGEN_TEST_FINISHED!");
				if ( result_slave_lite ) begin                                        
					$display("PTGEN_TEST: PASSED!");                 
				end	else begin                                         
					$display("PTGEN_TEST: FAILED!");                 
				end							   
			$display("---------------------------------------------------------");
		end
	endtask

	task automatic S_AXI_INTR_TEST;
		begin
			$display("---------------------------------------------------------");
			$display("EXAMPLE TEST : S_AXI_INTR");
			$display("Simple Interrupt generation test");
			$display("---------------------------------------------------------");

			//Initializing local registers	                                                                                
			S_AXI_INTR_globalenAddress = 32'h44A20000;                                                
			S_AXI_INTR_intrenAddress = 32'h44A20000 + 32'h00000004;                                   
			S_AXI_INTR_pendAddress = 32'h44A20000 + 32'h00000010;                                     
			S_AXI_INTR_ackAddress = 32'h44A20000 + 32'h0000000c;                                      
			S_AXI_INTR_globalenData = 32'h00000001;                                                                    
			S_AXI_INTR_intrenData = 32'h00000001;                                                                      
			S_AXI_INTR_ackData = 32'h00000001;                                                                         
			S_AXI_INTR_pendData = 32'h00000000;                                                                        
			S_AXI_INTR_mtestProtection_lite = 0;                                                                       
			S_AXI_INTR_mtestdatasizelite = `S_AXI_INTR_MAX_DATA_SIZE;                                              
			                                                                                                               
			//Enabling global interrupt generation	                                                                        
			dut.ultrasonic_control_v1_0_S00_AXI_inst.master_1.cdn_axi4_lite_master_bfm_inst.WRITE_BURST_CONCURRENT(S_AXI_INTR_globalenAddress,
						                   S_AXI_INTR_mtestProtection_lite,                                             
						                   S_AXI_INTR_globalenData,                                                     
						                   S_AXI_INTR_mtestdatasizelite,                                                
						                   S_AXI_INTR_lite_response);                                                   
										                                                                                    
			//Enabling Interrupt generation at bit 0							                                            
			dut.ultrasonic_control_v1_0_S00_AXI_inst.master_1.cdn_axi4_lite_master_bfm_inst.WRITE_BURST_CONCURRENT(S_AXI_INTR_intrenAddress,  
						                   S_AXI_INTR_mtestProtection_lite,                                             
						                   S_AXI_INTR_intrenData,                                                       
						                   S_AXI_INTR_mtestdatasizelite,                                                
						                   S_AXI_INTR_lite_response);                                                   
						                                                                                                    
			wait(tb_irq == 1) @(posedge tb_ACLK);	                                                        
			begin                                                                                                          
				#100;                                                                                                       
				//Reading Interrupt pending register value                                                                  
				dut.ultrasonic_control_v1_0_S00_AXI_inst.master_1.cdn_axi4_lite_master_bfm_inst.READ_BURST(S_AXI_INTR_pendAddress,             
					                     S_AXI_INTR_mtestProtection_lite,                                               
					                     S_AXI_INTR_pendData,                                                           
					                     S_AXI_INTR_lite_response);                                                     
			                                                                                                               
				if ( S_AXI_INTR_pendData[0] != 1'b1) begin                                                              
					$display("ERROR: Interrupt not generated at bit0");                                                   
					$display("PTGEN_TEST: FAILED!");                                                                      
					$stop;                                                                                                  
				end                                                                                                         
					                                                                                                        
				//clearing irq_f2p through Interrupt acknowledgement register                                               
				dut.ultrasonic_control_v1_0_S00_AXI_inst.master_1.cdn_axi4_lite_master_bfm_inst.WRITE_BURST_CONCURRENT(S_AXI_INTR_ackAddress,  
						                   S_AXI_INTR_mtestProtection_lite,                                             
						                   S_AXI_INTR_ackData,                                                          
						                   S_AXI_INTR_mtestdatasizelite,                                                
						                   S_AXI_INTR_lite_response);		                                            
				#100;                                                                                                       
				//Reading Interrupt pending register value                                                                  
				dut.ultrasonic_control_v1_0_S00_AXI_inst.master_1.cdn_axi4_lite_master_bfm_inst.READ_BURST(S_AXI_INTR_pendAddress,             
					                     S_AXI_INTR_mtestProtection_lite,                                               
					                     S_AXI_INTR_pendData,                                                           
					                     S_AXI_INTR_lite_response);	                                                    
					                     	                                                                                
				if ( S_AXI_INTR_pendData[0] != 1'b0) begin                                                              
					$display("ERROR: Interrupt not cleared at bit0");                                                     
					$display("PTGEN_TEST: FAILED!");                                                                      
					$stop;                                                                                                  
				end	else begin                                                                                              
					$display ("PASS: Interrupt test successful");                                                         
					$display("PTGEN_TEST: PASSED!");                                                                      
				end                                                                                                         
			end                                                                                                            
			$display("---------------------------------------------------------");
			$display("EXAMPLE TEST S_AXI_INTR: PTGEN_TEST_FINISHED!");
			$display("---------------------------------------------------------");
		end
	endtask

	// Create the test vectors
	initial begin
		// When performing debug enable all levels of INFO messages.
		wait(tb_ARESETn === 0) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);  

		dut.ultrasonic_control_v1_0_S00_AXI_inst.master_0.cdn_axi4_lite_master_bfm_inst.set_channel_level_info(1);

		// Create test data vectors
		S00_AXI_test_data_lite[0] = 32'h0101FFFF;
		S00_AXI_test_data_lite[1] = 32'habcd0001;
		S00_AXI_test_data_lite[2] = 32'hdead0011;
		S00_AXI_test_data_lite[3] = 32'hbeef0011;
	end

	// Drive the BFM
	initial begin
		// Wait for end of reset
		wait(tb_ARESETn === 0) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     

		S00_AXI_TEST();
		S_AXI_INTR_TEST();

	end

endmodule
