
/////////////////////////////////////////////////////////////////////
//  READ_WIDTH | BRAM_SIZE | READ Depth  | ADDR Width |            //
// WRITE_WIDTH |           | WRITE Depth |            |  WE Width  //
// ============|===========|=============|============|============//
//    37-72    |  "36Kb"   |      512    |    9-bit   |    8-bit   //
//    19-36    |  "36Kb"   |     1024    |   10-bit   |    4-bit   //
//    19-36    |  "18Kb"   |      512    |    9-bit   |    4-bit   //
//    10-18    |  "36Kb"   |     2048    |   11-bit   |    2-bit   //
//    10-18    |  "18Kb"   |     1024    |   10-bit   |    2-bit   //
//     5-9     |  "36Kb"   |     4096    |   12-bit   |    1-bit   //
//     5-9     |  "18Kb"   |     2048    |   11-bit   |    1-bit   //
//     3-4     |  "36Kb"   |     8192    |   13-bit   |    1-bit   //
//     3-4     |  "18Kb"   |     4096    |   12-bit   |    1-bit   //
//       2     |  "36Kb"   |    16384    |   14-bit   |    1-bit   //
//       2     |  "18Kb"   |     8192    |   13-bit   |    1-bit   //
//       1     |  "36Kb"   |    32768    |   15-bit   |    1-bit   //
//       1     |  "18Kb"   |    16384    |   14-bit   |    1-bit   //
/////////////////////////////////////////////////////////////////////

module xilinx_sp_bram 
import xilinx_primitive_pkg::*;
#(
   parameter BRAM_SIZE          = "18Kb", // Target BRAM, "18Kb" or "36Kb"
   parameter DEVICE             = "7SERIES", // Target Device: "7SERIES"
   parameter DO_REG             = 0, // Optional output register (0 or 1)
   parameter INIT               = 36'h000000000, // Initial values on output port
   parameter INIT_FILE          = "NONE",
   parameter WRITE_WIDTH        = 1, // Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
   parameter READ_WIDTH         = 1,  // Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
   parameter SRVAL              = 36'h000000000, // Set/Reset value for port output
   parameter WRITE_MODE         = "WRITE_FIRST" // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
) (
   output logic [READ_WIDTH-1:0]    DO,       // Output data, width defined by READ_WIDTH parameter
   input  logic [14:0]              ADDR,     // Input address, width defined by read/write port depth
   input  logic                     CLK,      // 1-bit input clock
   input  logic [WRITE_WIDTH-1:0]   DI,       // Input data port, width defined by WRITE_WIDTH parameter
   input  logic                     EN,       // 1-bit input RAM enable
   input  logic                     REGCE,    // 1-bit input output register enable
   input  logic                     RST,      // 1-bit input reset
   input  logic [7:0]               WE        // Input write enable, width defined by write port depth
);

generate;
    for (genvar i=0; i<N; ++i) begin
        xilinx_sp_bram_macro #(
            .BRAM_SIZE    (BRAM_SIZE  ), // Target BRAM, "18Kb" or "36Kb"
            .DEVICE       (DEVICE     ), // Target Device: "7SERIES"
            .DO_REG       (DO_REG     ), // Optional output register (0 or 1)
            .INIT         (INIT       ), // Initial values on output port
            .INIT_FILE    (INIT_FILE  ),
            .WRITE_WIDTH  (WRITE_WIDTH), // Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
            .READ_WIDTH   (READ_WIDTH ), // Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
            .SRVAL        (SRVAL      ), // Set/Reset value for port output
            .WRITE_MODE   (WRITE_MODE )  // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
        ) u_macro (
            .DO     (DO   ), // Output data, width defined by READ_WIDTH parameter
            .ADDR   (ADDR ), // Input address, width defined by read/write port depth
            .CLK    (CLK  ), // 1-bit input clock
            .DI     (DI   ), // Input data port, width defined by WRITE_WIDTH parameter
            .EN     (EN   ), // 1-bit input RAM enable
            .REGCE  (REGCE), // 1-bit input output register enable
            .RST    (RST  ), // 1-bit input reset
            .WE     (WE   )  // Input write enable, width defined by write port depth
        );
    end
endgenerate

endmodule
