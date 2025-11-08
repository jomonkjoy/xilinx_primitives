module xilinx_dp_distram #(
    parameter ADDR_WIDTH            = 6,
    parameter DATA_WIDTH            = 1
) (
    input  logic                    WCLK,
    input  logic                    WE,
    input  logic [ADDR_WIDTH-1:0]   A,
    input  logic [DATA_WIDTH-1:0]   D,
    output logic [DATA_WIDTH-1:0]   SPO,
    input  logic [ADDR_WIDTH-1:0]   DPRA,
    output logic [DATA_WIDTH-1:0]   DPO
);

RAM_DEPTH = (2**ADDR_WIDTH);

// RAM128X1D: 128-deep by 1-wide positive edge write, asynchronous read  (Mapped to two SliceM LUT6s)
//            dual-port distributed LUT RAM
//            7 Series
// Xilinx HDL Language Template, version 2025.1

generate if (RAM_DEPTH==128) begin
    for (genvar i=0; i<DATA_WIDTH; i++) begin
        RAM128X1D #(
            .INIT(128'h00000000000000000000000000000000)
        ) RAM128X1D_inst (
            .DPO(DPO[i]),   // Read port 1-bit output
            .SPO(SPO[i]),   // Read/write port 1-bit output
            .A(A),          // Read/write port 7-bit address input
            .D(D[i]),       // RAM data input
            .DPRA(DPRA),    // Read port 7-bit address input
            .WCLK(WCLK),    // Write clock input
            .WE(WE)         // Write enable input
        );
    end
end else if (RAM_DEPTH==64) begin
    for (genvar i=0; i<DATA_WIDTH; i++) begin
        RAM64X1D #(
            .INIT(64'h0000000000000000) // Initial contents of RAM
        ) RAM64X1D_inst (
            .DPO(DPO[i]),    // Read-only 1-bit data output
            .SPO(SPO[i]),    // Rw/ 1-bit data output
            .A0(A[0]),       // Rw/ address[0] input bit
            .A1(A[1]),       // Rw/ address[1] input bit
            .A2(A[2]),       // Rw/ address[2] input bit
            .A3(A[3]),       // Rw/ address[3] input bit
            .A4(A[4]),       // Rw/ address[4] input bit
            .A5(A[5]),       // Rw/ address[5] input bit
            .D(D[i]),        // Write 1-bit data input
            .DPRA0(DPRA[0]), // Read-only address[0] input bit
            .DPRA1(DPRA[1]), // Read-only address[1] input bit
            .DPRA2(DPRA[2]), // Read-only address[2] input bit
            .DPRA3(DPRA[3]), // Read-only address[3] input bit
            .DPRA4(DPRA[4]), // Read-only address[4] input bit
            .DPRA5(DPRA[5]), // Read-only address[5] input bit
            .WCLK(WCLK),     // Write clock input
            .WE(WE)          // Write enable input
        );
    end
end else begin
    for (genvar i=0; i<DATA_WIDTH; i++) begin
        RAM32X1D #(
            .INIT(32'h00000000) // Initial contents of RAM
        ) RAM32X1D_inst (
            .DPO(DPO[i]),    // Read-only 1-bit data output
            .SPO(SPO[i]),    // Rw/ 1-bit data output
            .A0(A[0]),       // Rw/ address[0] input bit
            .A1(A[1]),       // Rw/ address[1] input bit
            .A2(A[2]),       // Rw/ address[2] input bit
            .A3(A[3]),       // Rw/ address[3] input bit
            .A4(A[4]),       // Rw/ address[4] input bit
            .D(D[i]),        // Write 1-bit data input
            .DPRA0(DPRA[0]), // Read-only address[0] input bit
            .DPRA1(DPRA[1]), // Read-only address[1] input bit
            .DPRA2(DPRA[2]), // Read-only address[2] input bit
            .DPRA3(DPRA[3]), // Read-only address[3] input bit
            .DPRA4(DPRA[4]), // Read-only address[4] input bit
            .WCLK(WCLK),     // Write clock input
            .WE(WE)          // Write enable input
        );
    end
end endgenerate

// End of RAM128X1D_inst instantiation

endmodule