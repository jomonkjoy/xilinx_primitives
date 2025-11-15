
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

localparam MACRO_SIZE = (DATA_WIDTH>32) ? "36Kb" : FIFO_SIZE;
localparam FIFO_DEPTH = get_fifo_depth(DATA_WIDTH,FIFO_SIZE);

generate if (MACRO_SIZE=="18Kb") begin

logic [31:0] DO_wire,DI_wire;
logic [3:0] DOP_wire,DIP_wire;

// Assign input data to wire (pad with zeros if needed)
assign DI_wire = {{(32-DATA_WIDTH){1'b0}}, DI};
assign DIP_wire = 4'b0;

// Extract output data from wire
assign DO = DO_wire[DATA_WIDTH-1:0];

// FIFO18E1: 18Kb FIFO (First-In-First-Out) Block RAM Memory
//           7 Series
// Xilinx HDL Language Template, version 2025.1

FIFO18E1 #(
   .ALMOST_EMPTY_OFFSET(ALMOST_EMPTY_OFFSET),    // Sets the almost empty threshold
   .ALMOST_FULL_OFFSET(ALMOST_FULL_OFFSET),     // Sets almost full threshold
   .DATA_WIDTH(DATA_WIDTH),                    // Sets data width to 4-36
   .DO_REG(1),                        // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
   .EN_SYN("FALSE"),                  // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
   .FIFO_MODE("FIFO18"),              // Sets mode to FIFO18 or FIFO18_36
   .FIRST_WORD_FALL_THROUGH(FIRST_WORD_FALL_THROUGH), // Sets the FIFO FWFT to FALSE, TRUE
   .INIT(36'h000000000),              // Initial values on output port
   .SIM_DEVICE("7SERIES"),            // Must be set to "7SERIES" for simulation behavior
   .SRVAL(36'h000000000)              // Set/Reset value for output port
)
FIFO18E1_inst (
   // Read Data: 32-bit (each) output: Read output data
   .DO(DO_wire),              // 32-bit output: Data output
   .DOP(DOP_wire),            // 4-bit output: Parity data output
   // Status: 1-bit (each) output: Flags and other FIFO status outputs
   .ALMOSTEMPTY(ALMOSTEMPTY), // 1-bit output: Almost empty flag
   .ALMOSTFULL(ALMOSTFULL),   // 1-bit output: Almost full flag
   .EMPTY(EMPTY),             // 1-bit output: Empty flag
   .FULL(FULL),               // 1-bit output: Full flag
   .RDCOUNT(RDCOUNT),         // 12-bit output: Read count
   .RDERR(RDERR),             // 1-bit output: Read error
   .WRCOUNT(WRCOUNT),         // 12-bit output: Write count
   .WRERR(WRERR),             // 1-bit output: Write error
   // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
   .RDCLK(RDCLK),             // 1-bit input: Read clock
   .RDEN(RDEN),               // 1-bit input: Read enable
   .REGCE(1),                 // 1-bit input: Clock enable
   .RST(RST),                 // 1-bit input: Asynchronous Reset
   .RSTREG(RST),              // 1-bit input: Output register set/reset
   // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
   .WRCLK(WRCLK),             // 1-bit input: Write clock
   .WREN(WREN),               // 1-bit input: Write enable
   // Write Data: 32-bit (each) input: Write input data
   .DI(DI_wire),              // 32-bit input: Data input
   .DIP(DIP_wire)             // 4-bit input: Parity input
);

// End of FIFO18E1_inst instantiation

end else begin

logic [63:0] DO_wire,DI_wire;
logic [7:0] DOP_wire,DIP_wire;
logic DBITERR, SBITERR;
logic [7:0] ECCPARITY;

// Assign input data to wire (pad with zeros if needed)
assign DI_wire = {{(64-DATA_WIDTH){1'b0}}, DI};
assign DIP_wire = 8'b0;

// Extract output data from wire
assign DO = DO_wire[DATA_WIDTH-1:0];

// FIFO36E1: 36Kb FIFO (First-In-First-Out) Block RAM Memory
//           7 Series
// Xilinx HDL Language Template, version 2025.1

FIFO36E1 #(
   .ALMOST_EMPTY_OFFSET(ALMOST_EMPTY_OFFSET),    // Sets the almost empty threshold
   .ALMOST_FULL_OFFSET(ALMOST_FULL_OFFSET),     // Sets almost full threshold
   .DATA_WIDTH(DATA_WIDTH),                    // Sets data width to 4-72
   .DO_REG(1),                        // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
   .EN_ECC_READ("FALSE"),             // Enable ECC decoder, FALSE, TRUE
   .EN_ECC_WRITE("FALSE"),            // Enable ECC encoder, FALSE, TRUE
   .EN_SYN("FALSE"),                  // Specifies FIFO as Asynchronous (FALSE) or Synchronous (TRUE)
   .FIFO_MODE("FIFO36"),              // Sets mode to "FIFO36" or "FIFO36_72"
   .FIRST_WORD_FALL_THROUGH(FIRST_WORD_FALL_THROUGH), // Sets the FIFO FWFT to FALSE, TRUE
   .INIT(72'h000000000000000000),     // Initial values on output port
   .SIM_DEVICE("7SERIES"),            // Must be set to "7SERIES" for simulation behavior
   .SRVAL(72'h000000000000000000)     // Set/Reset value for output port
)
FIFO36E1_inst (
   // ECC Signals: 1-bit (each) output: Error Correction Circuitry ports
   .DBITERR(DBITERR),             // 1-bit output: Double bit error status
   .ECCPARITY(ECCPARITY),         // 8-bit output: Generated error correction parity
   .SBITERR(SBITERR),             // 1-bit output: Single bit error status
   // Read Data: 64-bit (each) output: Read output data
   .DO(DO_wire),                  // 64-bit output: Data output
   .DOP(DOP_wire),                // 8-bit output: Parity data output
   // Status: 1-bit (each) output: Flags and other FIFO status outputs
   .ALMOSTEMPTY(ALMOSTEMPTY),     // 1-bit output: Almost empty flag
   .ALMOSTFULL(ALMOSTFULL),       // 1-bit output: Almost full flag
   .EMPTY(EMPTY),                 // 1-bit output: Empty flag
   .FULL(FULL),                   // 1-bit output: Full flag
   .RDCOUNT(RDCOUNT),             // 13-bit output: Read count
   .RDERR(RDERR),                 // 1-bit output: Read error
   .WRCOUNT(WRCOUNT),             // 13-bit output: Write count
   .WRERR(WRERR),                 // 1-bit output: Write error
   // ECC Signals: 1-bit (each) input: Error Correction Circuitry ports
   .INJECTDBITERR(0),             // 1-bit input: Inject a double bit error input
   .INJECTSBITERR(0),
   // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
   .RDCLK(RDCLK),                 // 1-bit input: Read clock
   .RDEN(RDEN),                   // 1-bit input: Read enable
   .REGCE(1),                     // 1-bit input: Clock enable
   .RST(RST),                     // 1-bit input: Reset
   .RSTREG(RST),                  // 1-bit input: Output register set/reset
   // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
   .WRCLK(WRCLK),                 // 1-bit input: Rising edge write clock.
   .WREN(WREN),                   // 1-bit input: Write enable
   // Write Data: 64-bit (each) input: Write input data
   .DI(DI_wire),                  // 64-bit input: Data input
   .DIP(DIP_wire)                 // 8-bit input: Parity input
);

// End of FIFO36E1_inst instantiation

end endgenerate

endmodule
