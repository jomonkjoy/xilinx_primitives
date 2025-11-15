
/////////////////////////////////////////////////////////////////
// DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width //
// ===========|===========|============|=======================//
//   37-72    |  "36Kb"   |     512    |         9-bit         //
//   19-36    |  "36Kb"   |    1024    |        10-bit         //
//   19-36    |  "18Kb"   |     512    |         9-bit         //
//   10-18    |  "36Kb"   |    2048    |        11-bit         //
//   10-18    |  "18Kb"   |    1024    |        10-bit         //
//    5-9     |  "36Kb"   |    4096    |        12-bit         //
//    5-9     |  "18Kb"   |    2048    |        11-bit         //
//    1-4     |  "36Kb"   |    8192    |        13-bit         //
//    1-4     |  "18Kb"   |    4096    |        12-bit         //
/////////////////////////////////////////////////////////////////

module xilinx_fifo_sync 
import xilinx_primitive_pkg::*;
#(
   parameter DEVICE                 = "7SERIES", // Target Device: "7SERIES"
   parameter ALMOST_EMPTY_OFFSET    = 13'h0080, // Sets the almost empty threshold
   parameter ALMOST_FULL_OFFSET     = 13'h0080,  // Sets almost full threshold
   parameter DATA_WIDTH             = 4, // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
   parameter DO_REG                 = 0,     // Optional output register (0 or 1)
   parameter FIFO_SIZE              = "18Kb",  // Target BRAM: "18Kb" or "36Kb"
   parameter FIRST_WORD_FALL_THROUGH= "FALSE" // Sets the FIFO FWFT to "TRUE" or "FALSE"
) (
   output logic                  ALMOSTEMPTY, // 1-bit output almost empty
   output logic                  ALMOSTFULL,  // 1-bit output almost full
   output logic [DATA_WIDTH-1:0] DO,          // Output data, width defined by DATA_WIDTH parameter
   output logic                  EMPTY,       // 1-bit output empty
   output logic                  FULL,        // 1-bit output full
   output logic [12:0]           RDCOUNT,     // Output read count, width determined by FIFO depth
   output logic                  RDERR,       // 1-bit output read error
   output logic [12:0]           WRCOUNT,     // Output write count, width determined by FIFO depth
   output logic                  WRERR,       // 1-bit output write error
   input  logic                  CLK,         // 1-bit input clock
   input  logic [DATA_WIDTH-1:0] DI,          // Input data, width defined by DATA_WIDTH parameter
   input  logic                  RDEN,        // 1-bit input read enable
   input  logic                  RST,         // 1-bit input reset
   input  logic                  WREN         // 1-bit input write enable
);

generate;
    for (genvar i=0; i<N; ++i) begin
        xilinx_fifo_sync_macro #(
            .DEVICE                 (DEVICE                 ), // Target Device: "7SERIES"
            .ALMOST_EMPTY_OFFSET    (ALMOST_EMPTY_OFFSET    ), // Sets the almost empty threshold
            .ALMOST_FULL_OFFSET     (ALMOST_FULL_OFFSET     ), // Sets almost full threshold
            .DATA_WIDTH             (DATA_WIDTH             ), // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            .DO_REG                 (DO_REG                 ), // Optional output register (0 or 1)
            .FIFO_SIZE              (FIFO_SIZE              ), // Target BRAM: "18Kb" or "36Kb"
            .FIRST_WORD_FALL_THROUGH(FIRST_WORD_FALL_THROUGH)  // Sets the FIFO FWFT to "TRUE" or "FALSE"
        ) u_macro (
            .ALMOSTEMPTY  (ALMOSTEMPTY), // 1-bit output almost empty
            .ALMOSTFULL   (ALMOSTFULL ), // 1-bit output almost full
            .DO           (DO         ), // Output data, width defined by DATA_WIDTH parameter
            .EMPTY        (EMPTY      ), // 1-bit output empty
            .FULL         (FULL       ), // 1-bit output full
            .RDCOUNT      (RDCOUNT    ), // Output read count, width determined by FIFO depth
            .RDERR        (RDERR      ), // 1-bit output read error
            .WRCOUNT      (WRCOUNT    ), // Output write count, width determined by FIFO depth
            .WRERR        (WRERR      ), // 1-bit output write error
            .CLK          (CLK        ), // 1-bit input clock
            .DI           (DI         ), // Input data, width defined by DATA_WIDTH parameter
            .RDEN         (RDEN       ), // 1-bit input read enable
            .RST          (RST        ), // 1-bit input reset
            .WREN         (WREN       )  // 1-bit input write enable
        );
    end
endgenerate

endmodule
