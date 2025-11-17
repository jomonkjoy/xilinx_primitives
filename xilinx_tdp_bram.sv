
//////////////////////////////////////////////////////////////////////////
// DATA_WIDTH_A/B | BRAM_SIZE | RAM Depth | ADDRA/B Width | WEA/B Width //
// ===============|===========|===========|===============|=============//
//     19-36      |  "36Kb"   |    1024   |    10-bit     |    4-bit    //
//     10-18      |  "36Kb"   |    2048   |    11-bit     |    2-bit    //
//     10-18      |  "18Kb"   |    1024   |    10-bit     |    2-bit    //
//      5-9       |  "36Kb"   |    4096   |    12-bit     |    1-bit    //
//      5-9       |  "18Kb"   |    2048   |    11-bit     |    1-bit    //
//      3-4       |  "36Kb"   |    8192   |    13-bit     |    1-bit    //
//      3-4       |  "18Kb"   |    4096   |    12-bit     |    1-bit    //
//        2       |  "36Kb"   |   16384   |    14-bit     |    1-bit    //
//        2       |  "18Kb"   |    8192   |    13-bit     |    1-bit    //
//        1       |  "36Kb"   |   32768   |    15-bit     |    1-bit    //
//        1       |  "18Kb"   |   16384   |    14-bit     |    1-bit    //
//////////////////////////////////////////////////////////////////////////

module xilinx_tdp_bram 
import xilinx_primitive_pkg::*;
#(
   parameter BRAM_SIZE              = "18Kb", // Target BRAM: "18Kb" or "36Kb"
   parameter DEVICE                 = "7SERIES", // Target device: "7SERIES"
   parameter DOA_REG                = 0,        // Optional port A output register (0 or 1)
   parameter DOB_REG                = 0,        // Optional port B output register (0 or 1)
   parameter INIT_A                 = 36'h0000000,  // Initial values on port A output port
   parameter INIT_B                 = 36'h00000000, // Initial values on port B output port
   parameter INIT_FILE              = "NONE",
   parameter READ_WIDTH_A           = 1,   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
   parameter READ_WIDTH_B           = 1,   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
   parameter SIM_COLLISION_CHECK    = "ALL", // Collision check enable "ALL", "WARNING_ONLY",
                                            //   "GENERATE_X_ONLY" or "NONE"
   parameter SRVAL_A                = 36'h00000000, // Set/Reset value for port A output
   parameter SRVAL_B                = 36'h00000000, // Set/Reset value for port B output
   parameter WRITE_MODE_A           = "WRITE_FIRST", // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
   parameter WRITE_MODE_B           = "WRITE_FIRST", // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
   parameter WRITE_WIDTH_A          = 1, // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
   parameter WRITE_WIDTH_B          = 1, // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
   parameter WE_WIDTH_A             = ((WRITE_WIDTH_A+7)/8),
   parameter WE_WIDTH_B             = ((WRITE_WIDTH_B+7)/8)
) (
   output logic [READ_WIDTH_A-1:0]  DOA,       // Output port-A data, width defined by READ_WIDTH_A parameter
   output logic [READ_WIDTH_B-1:0]  DOB,       // Output port-B data, width defined by READ_WIDTH_B parameter
   input  logic [14:0]              ADDRA,     // Input port-A address, width defined by Port A depth
   input  logic [14:0]              ADDRB,     // Input port-B address, width defined by Port B depth
   input  logic                     CLKA,      // 1-bit input port-A clock
   input  logic                     CLKB,      // 1-bit input port-B clock
   input  logic [WRITE_WIDTH_A-1:0] DIA,       // Input port-A data, width defined by WRITE_WIDTH_A parameter
   input  logic [WRITE_WIDTH_B-1:0] DIB,       // Input port-B data, width defined by WRITE_WIDTH_B parameter
   input  logic                     ENA,       // 1-bit input port-A enable
   input  logic                     ENB,       // 1-bit input port-B enable
   input  logic                     REGCEA,    // 1-bit input port-A output register enable
   input  logic                     REGCEB,    // 1-bit input port-B output register enable
   input  logic                     RSTA,      // 1-bit input port-A reset
   input  logic                     RSTB,      // 1-bit input port-B reset
   input  logic [WE_WIDTH_A-1:0]    WEA,       // Input port-A write enable, width defined by Port A depth
   input  logic [WE_WIDTH_B-1:0]    WEB        // Input port-B write enable, width defined by Port B depth
);

localparam MAX_WIDTH = (WRITE_WIDTH_A > READ_WIDTH_A) ? WRITE_WIDTH_A : 
                       (READ_WIDTH_A > WRITE_WIDTH_B) ? READ_WIDTH_A :
                       (WRITE_WIDTH_B > READ_WIDTH_B) ? WRITE_WIDTH_B : READ_WIDTH_B;

localparam BANK_WIDTH = (BRAM_SIZE == "36Kb" && MAX_WIDTH > 18) ? 32 : 18;

// Calculate number of banks needed for each port
localparam BRAM_NUMBER_A = ((WRITE_WIDTH_A > READ_WIDTH_A ? WRITE_WIDTH_A : READ_WIDTH_A) + BANK_WIDTH - 1) / BANK_WIDTH;
localparam BRAM_NUMBER_B = ((WRITE_WIDTH_B > READ_WIDTH_B ? WRITE_WIDTH_B : READ_WIDTH_B) + BANK_WIDTH - 1) / BANK_WIDTH;
localparam BRAM_NUMBER = (BRAM_NUMBER_A > BRAM_NUMBER_B) ? BRAM_NUMBER_A : BRAM_NUMBER_B;

// Calculate actual per-bank widths
localparam BANK_RDA_W = ((READ_WIDTH_A + BRAM_NUMBER - 1) / BRAM_NUMBER);
localparam BANK_WRA_W = ((WRITE_WIDTH_A + BRAM_NUMBER - 1) / BRAM_NUMBER);
localparam BANK_WEA_W = ((BANK_WRA_W+7)/8);
localparam BANK_RDB_W = ((READ_WIDTH_B + BRAM_NUMBER - 1) / BRAM_NUMBER);
localparam BANK_WRB_W = ((WRITE_WIDTH_B + BRAM_NUMBER - 1) / BRAM_NUMBER);
localparam BANK_WEB_W = ((BANK_WRB_W+7)/8);

logic [BRAM_NUMBER * BANK_RDA_W-1:0] DOA_bank;       // Output port-A data, width defined by READ_WIDTH_A parameter
logic [BRAM_NUMBER * BANK_RDB_W-1:0] DOB_bank;       // Output port-B data, width defined by READ_WIDTH_B parameter
logic [BRAM_NUMBER * BANK_WRA_W-1:0] DIA_bank;       // Input port-A data, width defined by WRITE_WIDTH_A parameter
logic [BRAM_NUMBER * BANK_WRB_W-1:0] DIB_bank;       // Input port-B data, width defined by WRITE_WIDTH_B parameter
logic [BRAM_NUMBER * BANK_WEA_W-1:0] WEA_bank;       // Input port-A write enable, width defined by Port A depth
logic [BRAM_NUMBER * BANK_WEB_W-1:0] WEB_bank;       // Input port-B write enable, width defined by Port B depth

// Pad write data with zeros if needed
assign DIA_bank = (BRAM_NUMBER * BANK_WRA_W)'(DIA[WRITE_WIDTH_A-1:0]);
assign WEA_bank = (BRAM_NUMBER * BANK_WEA_W)'(WEA);
assign DIB_bank = (BRAM_NUMBER * BANK_WRB_W)'(DIB[WRITE_WIDTH_B-1:0]);
assign WEB_bank = (BRAM_NUMBER * BANK_WEB_W)'(WEB);

// Extract read data (trim padding)
assign DOA = DOA_bank[READ_WIDTH_A-1:0];
assign DOB = DOB_bank[READ_WIDTH_B-1:0];

generate;
    for (genvar i=0; i<BRAM_NUMBER; ++i) begin : gen_bank
        xilinx_tdp_bram_macro #(
            .BRAM_SIZE              (BRAM_SIZE          ), // Target BRAM: "18Kb" or "36Kb"
            .DEVICE                 (DEVICE             ), // Target device: "7SERIES"
            .DOA_REG                (DOA_REG            ), // Optional port A output register (0 or 1)
            .DOB_REG                (DOB_REG            ), // Optional port B output register (0 or 1)
            .INIT_A                 (INIT_A             ), // Initial values on port A output port
            .INIT_B                 (INIT_B             ), // Initial values on port B output port
            .INIT_FILE              (INIT_FILE          ),
            .READ_WIDTH_A           (BANK_RDA_W         ), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
            .READ_WIDTH_B           (BANK_RDB_W         ), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
            .SIM_COLLISION_CHECK    (SIM_COLLISION_CHECK), // Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE"
            .SRVAL_A                (SRVAL_A            ), // Set/Reset value for port A output
            .SRVAL_B                (SRVAL_B            ), // Set/Reset value for port B output
            .WRITE_MODE_A           (WRITE_MODE_A       ), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
            .WRITE_MODE_B           (WRITE_MODE_B       ), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
            .WRITE_WIDTH_A          (BANK_WRA_W         ), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
            .WRITE_WIDTH_B          (BANK_WRB_W         )  // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
        ) u_macro (
            .DOA    (DOA_bank[i*BANK_RDA_W +: BANK_RDA_W]   ), // Output port-A data, width defined by READ_WIDTH_A parameter
            .DOB    (DOB_bank[i*BANK_RDB_W +: BANK_RDB_W]   ), // Output port-B data, width defined by READ_WIDTH_B parameter
            .ADDRA  (ADDRA                                  ), // Input port-A address, width defined by Port A depth
            .ADDRB  (ADDRB                                  ), // Input port-B address, width defined by Port B depth
            .CLKA   (CLKA                                   ), // 1-bit input port-A clock
            .CLKB   (CLKB                                   ), // 1-bit input port-B clock
            .DIA    (DIA_bank[i*BANK_WRA_W +: BANK_WRA_W]   ), // Input port-A data, width defined by WRITE_WIDTH_A parameter
            .DIB    (DIB_bank[i*BANK_WRB_W +: BANK_WRB_W]   ), // Input port-B data, width defined by WRITE_WIDTH_B parameter
            .ENA    (ENA                                    ), // 1-bit input port-A enable
            .ENB    (ENB                                    ), // 1-bit input port-B enable
            .REGCEA (REGCEA                                 ), // 1-bit input port-A output register enable
            .REGCEB (REGCEB                                 ), // 1-bit input port-B output register enable
            .RSTA   (RSTA                                   ), // 1-bit input port-A reset
            .RSTB   (RSTB                                   ), // 1-bit input port-B reset
            .WEA    (WEA_bank[i*BANK_WEA_W +: BANK_WEA_W]   ), // Input port-A write enable, width defined by Port A depth
            .WEB    (WEB_bank[i*BANK_WEB_W +: BANK_WEB_W]   )  // Input port-B write enable, width defined by Port B depth
        );
    end
endgenerate

endmodule
