
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

module xilinx_fifo_async 
import xilinx_primitive_pkg::*;
#(
   parameter ALMOST_EMPTY_OFFSET    = 13'h0080, // Sets the almost empty threshold
   parameter ALMOST_FULL_OFFSET     = 13'h0080,  // Sets almost full threshold
   parameter DATA_WIDTH             = 4,   // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
   parameter DEVICE                 = "7SERIES",  // Target device: "7SERIES"
   parameter FIFO_SIZE              = "18Kb", // Target BRAM: "18Kb" or "36Kb"
   parameter FIRST_WORD_FALL_THROUGH= "FALSE" // Sets the FIFO FWFT to "TRUE" or "FALSE"
) (
   output logic                     ALMOSTEMPTY, // 1-bit output almost empty
   output logic                     ALMOSTFULL,  // 1-bit output almost full
   output logic [DATA_WIDTH-1:0]    DO,          // Output data, width defined by DATA_WIDTH parameter
   output logic                     EMPTY,       // 1-bit output empty
   output logic                     FULL,        // 1-bit output full
   output logic [12:0]              RDCOUNT,     // Output read count, width determined by FIFO depth
   output logic                     RDERR,       // 1-bit output read error
   output logic [12:0]              WRCOUNT,     // Output write count, width determined by FIFO depth
   output logic                     WRERR,       // 1-bit output write error
   input  logic [DATA_WIDTH-1:0]    DI,          // Input data, width defined by DATA_WIDTH parameter
   input  logic                     RDCLK,       // 1-bit input read clock
   input  logic                     RDEN,        // 1-bit input read enable
   input  logic                     RST,         // 1-bit input reset
   input  logic                     WRCLK,       // 1-bit input write clock
   input  logic                     WREN         // 1-bit input write enable
);

localparam BANK_WIDTH = (FIFO_SIZE == "36Kb" && DATA_WIDTH > 36) ? 64 : 32;
localparam FIFO_NUMBER = ((DATA_WIDTH + BANK_WIDTH - 1) / BANK_WIDTH);

logic [FIFO_NUMBER-1:0]                 ALMOSTEMPTY_bank; // 1-bit output almost empty
logic [FIFO_NUMBER-1:0]                 ALMOSTFULL_bank;  // 1-bit output almost full
logic [FIFO_NUMBER * BANK_WIDTH-1:0]    DO_bank;          // Output data, width defined by DATA_WIDTH parameter
logic [FIFO_NUMBER-1:0]                 EMPTY_bank;       // 1-bit output empty
logic [FIFO_NUMBER-1:0]                 FULL_bank;        // 1-bit output full
logic [FIFO_NUMBER-1:0][12:0]           RDCOUNT_bank;     // Output read count, width determined by FIFO depth
logic [FIFO_NUMBER-1:0]                 RDERR_bank;       // 1-bit output read error
logic [FIFO_NUMBER-1:0][12:0]           WRCOUNT_bank;     // Output write count, width determined by FIFO depth
logic [FIFO_NUMBER-1:0]                 WRERR_bank;       // 1-bit output write error
logic [FIFO_NUMBER * BANK_WIDTH-1:0]    DI_bank;          // Input data, width defined by DATA_WIDTH parameter

// Pad input data with zeros if needed
assign DI_bank = (FIFO_NUMBER * BANK_WIDTH)'(DI[DATA_WIDTH-1:0]);

// Extract output data (trim padding)
assign DO = DO_bank[DATA_WIDTH-1:0];

// Aggregate status flags from all banks
assign ALMOSTEMPTY = ALMOSTEMPTY_bank[0];
assign ALMOSTFULL  = ALMOSTFULL_bank[0];
assign EMPTY       = EMPTY_bank[0];
assign FULL        = FULL_bank[0];
assign RDERR       = RDERR_bank[0];
assign WRERR       = WRERR_bank[0];
assign RDCOUNT     = RDCOUNT_bank[0];
assign WRCOUNT     = WRCOUNT_bank[0];

generate;
    for (genvar i=0; i<FIFO_NUMBER; ++i) begin : gen_bank
        xilinx_fifo_async_macro #(
            .ALMOST_EMPTY_OFFSET    (ALMOST_EMPTY_OFFSET    ), // Sets the almost empty threshold
            .ALMOST_FULL_OFFSET     (ALMOST_FULL_OFFSET     ), // Sets almost full threshold
            .DATA_WIDTH             (BANK_WIDTH             ), // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            .DEVICE                 (DEVICE                 ), // Target device: "7SERIES"
            .FIFO_SIZE              (FIFO_SIZE              ), // Target BRAM: "18Kb" or "36Kb"
            .FIRST_WORD_FALL_THROUGH(FIRST_WORD_FALL_THROUGH)  // Sets the FIFO FWFT to "TRUE" or "FALSE"
        ) u_macro (
            .ALMOSTEMPTY  (ALMOSTEMPTY_bank[i]                          ), // 1-bit output almost empty
            .ALMOSTFULL   (ALMOSTFULL_bank [i]                          ), // 1-bit output almost full
            .DO           (DO_bank         [i*BANK_WIDTH +: BANK_WIDTH] ), // Output data, width defined by DATA_WIDTH parameter
            .EMPTY        (EMPTY_bank      [i]                          ), // 1-bit output empty
            .FULL         (FULL_bank       [i]                          ), // 1-bit output full
            .RDCOUNT      (RDCOUNT_bank    [i]                          ), // Output read count, width determined by FIFO depth
            .RDERR        (RDERR_bank      [i]                          ), // 1-bit output read error
            .WRCOUNT      (WRCOUNT_bank    [i]                          ), // Output write count, width determined by FIFO depth
            .WRERR        (WRERR_bank      [i]                          ), // 1-bit output write error
            .DI           (DI_bank         [i*BANK_WIDTH +: BANK_WIDTH] ), // Input data, width defined by DATA_WIDTH parameter
            .RDCLK        (RDCLK                                        ), // 1-bit input read clock
            .RDEN         (RDEN                                         ), // 1-bit input read enable
            .RST          (RST                                          ), // 1-bit input reset
            .WRCLK        (WRCLK                                        ), // 1-bit input write clock
            .WREN         (WREN                                         )  // 1-bit input write enable
        );
    end
endgenerate

endmodule
