
///////////////////////////////////////////////////////////////////////
//  READ_WIDTH | BRAM_SIZE | READ Depth  | RDADDR Width |            //
// WRITE_WIDTH |           | WRITE Depth | WRADDR Width |  WE Width  //
// ============|===========|=============|==============|============//
//    37-72    |  "36Kb"   |      512    |     9-bit    |    8-bit   //
//    19-36    |  "36Kb"   |     1024    |    10-bit    |    4-bit   //
//    19-36    |  "18Kb"   |      512    |     9-bit    |    4-bit   //
//    10-18    |  "36Kb"   |     2048    |    11-bit    |    2-bit   //
//    10-18    |  "18Kb"   |     1024    |    10-bit    |    2-bit   //
//     5-9     |  "36Kb"   |     4096    |    12-bit    |    1-bit   //
//     5-9     |  "18Kb"   |     2048    |    11-bit    |    1-bit   //
//     3-4     |  "36Kb"   |     8192    |    13-bit    |    1-bit   //
//     3-4     |  "18Kb"   |     4096    |    12-bit    |    1-bit   //
//       2     |  "36Kb"   |    16384    |    14-bit    |    1-bit   //
//       2     |  "18Kb"   |     8192    |    13-bit    |    1-bit   //
//       1     |  "36Kb"   |    32768    |    15-bit    |    1-bit   //
//       1     |  "18Kb"   |    16384    |    14-bit    |    1-bit   //
///////////////////////////////////////////////////////////////////////

module xilinx_sdp_bram 
import xilinx_primitive_pkg::*;
#(
   parameter BRAM_SIZE              = "18Kb", // Target BRAM, "18Kb" or "36Kb"
   parameter DEVICE                 = "7SERIES", // Target device: "7SERIES"
   parameter WRITE_WIDTH            = 1,        // Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
   parameter READ_WIDTH             = 1,        // Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
   parameter DO_REG                 = 0,        // Optional output register (0 or 1)
   parameter INIT_FILE              = "NONE",
   parameter SIM_COLLISION_CHECK    = "ALL",    // Collision check enable "ALL", "WARNING_ONLY",
                                                //   "GENERATE_X_ONLY" or "NONE"
   parameter SRVAL                  = 72'h000000000000000000, // Set/Reset value for port output
   parameter INIT                   = 72'h000000000000000000,  // Initial values on output port
   parameter WRITE_MODE             = "WRITE_FIRST"  // Specify "READ_FIRST" for same clock or synchronous clocks
                                                    //   Specify "WRITE_FIRST for asynchronous clocks on ports
) (
   output logic [READ_WIDTH-1:0]    DO,         // Output read data port, width defined by READ_WIDTH parameter
   input  logic [WRITE_WIDTH-1:0]   DI,         // Input write data port, width defined by WRITE_WIDTH parameter
   input  logic [14:0]              RDADDR,     // Input read address, width defined by read port depth
   input  logic                     RDCLK,      // 1-bit input read clock
   input  logic                     RDEN,       // 1-bit input read port enable
   input  logic                     REGCE,      // 1-bit input read output register enable
   input  logic                     RST,        // 1-bit input reset
   input  logic [7:0]               WE,         // Input write enable, width defined by write port depth
   input  logic [14:0]              WRADDR,     // Input write address, width defined by write port depth
   input  logic                     WRCLK,      // 1-bit input write clock
   input  logic                     WREN        // 1-bit input write port enable
);

localparam MAX_WIDTH = (WRITE_WIDTH > READ_WIDTH) ? WRITE_WIDTH : READ_WIDTH;
localparam BANK_WIDTH = (BRAM_SIZE == "36Kb" && MAX_WIDTH > 36) ? 64 : 32;

// Calculate number of banks needed
localparam BRAM_NUMBER_RD = ((READ_WIDTH + BANK_WIDTH - 1) / BANK_WIDTH);
localparam BRAM_NUMBER_WR = ((WRITE_WIDTH + BANK_WIDTH - 1) / BANK_WIDTH);
localparam BRAM_NUMBER = (BRAM_NUMBER_RD > BRAM_NUMBER_WR) ? BRAM_NUMBER_RD : BRAM_NUMBER_WR;

logic [READ_WIDTH-1:0]    DO_bank;         // Output read data port, width defined by READ_WIDTH parameter
logic [WRITE_WIDTH-1:0]   DI_bank;         // Input write data port, width defined by WRITE_WIDTH parameter
logic [7:0]               WE_bank;         // Input write enable, width defined by write port depth

// Pad write data with zeros if needed
assign DI_bank = ()'(DI[WRITE_WIDTH-1:0]);
assign WE_bank = ()'(WE);

// Extract read data (trim padding)
assign DO = DO_bank[READ_WIDTH-1:0];

generate;
    for (genvar i=0; i<BRAM_NUMBER; ++i) begin : gen_bank
        xilinx_sdp_bram_macro #(
            .BRAM_SIZE              (BRAM_SIZE          ), // Target BRAM, "18Kb" or "36Kb"
            .DEVICE                 (DEVICE             ), // Target device: "7SERIES"
            .WRITE_WIDTH            (WRITE_WIDTH        ), // Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
            .READ_WIDTH             (READ_WIDTH         ), // Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
            .DO_REG                 (DO_REG             ), // Optional output register (0 or 1)
            .INIT_FILE              (INIT_FILE          ),
            .SIM_COLLISION_CHECK    (SIM_COLLISION_CHECK), // Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE"
            .SRVAL                  (SRVAL              ), // Set/Reset value for port output
            .INIT                   (INIT               ), // Initial values on output port
            .WRITE_MODE             (WRITE_MODE         )  // Specify "READ_FIRST" for same clock or synchronous clocks Specify "WRITE_FIRST for asynchronous clocks on ports
        ) u_macro (
            .DO       (DO_bank[i*BANK_WIDTH +: BANK_WIDTH]  ), // Output read data port, width defined by READ_WIDTH parameter
            .DI       (DI_bank[i*BANK_WIDTH +: BANK_WIDTH]  ), // Input write data port, width defined by WRITE_WIDTH parameter
            .RDADDR   (RDADDR                               ), // Input read address, width defined by read port depth
            .RDCLK    (RDCLK                                ), // 1-bit input read clock
            .RDEN     (RDEN                                 ), // 1-bit input read port enable
            .REGCE    (REGCE                                ), // 1-bit input read output register enable
            .RST      (RST                                  ), // 1-bit input reset
            .WE       (WE_bank[i*BANK_WIDTH +: BANK_WIDTH]  ), // Input write enable, width defined by write port depth
            .WRADDR   (WRADDR                               ), // Input write address, width defined by write port depth
            .WRCLK    (WRCLK                                ), // 1-bit input write clock
            .WREN     (WREN                                 )  // 1-bit input write port enable
            );
    end
endgenerate

endmodule
