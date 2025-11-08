module xilinx_spdistram_async #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 1
) (
    input  logic                    WCLK,
    input  logic                    WE,
    input  logic [ADDR_WIDTH-1:0]   A,
    input  logic [DATA_WIDTH-1:0]   D,
    output logic [DATA_WIDTH-1:0]   O
);

RAM_DEPTH = (2**ADDR_WIDTH);

// RAM256X1S: 256-deep by 1-wide positive edge write, asynchronous read  (Mapped to four SliceM LUT6s)
//            single-port distributed LUT RAM
//            7 Series
// Xilinx HDL Language Template, version 2025.1

generate if (RAM_DEPTH==256) begin
    for (genvar i=0; i<DATA_WIDTH; i++) begin
        RAM256X1S #(
            .INIT(256'h0000000000000000000000000000000000000000000000000000000000000000)
        ) RAM256X1S_inst (
            .O(O[i]),    // Read/write port 1-bit output
            .A(A),       // Read/write port 8-bit address input
            .WE(WE),     // Write enable input
            .WCLK(WCLK), // Write clock input
            .D(D[i])     // RAM data input
        );
    end
end else if (RAM_DEPTH==128) begin
    for (genvar i=0; i<DATA_WIDTH; i++) begin
        RAM128X1S #(
            .INIT(128'h00000000000000000000000000000000) // Initial contents of RAM
        ) RAM128X1S_inst (
            .O(O[i]),     // 1-bit data output
            .A0(A[0]),    // Address[0] input bit
            .A1(A[1]),    // Address[1] input bit
            .A2(A[2]),    // Address[2] input bit
            .A3(A[3]),    // Address[3] input bit
            .A4(A[4]),    // Address[4] input bit
            .A5(A[5]),    // Address[5] input bit
            .A6(A[6]),    // Address[6] input bit
            .D(D[i]),     // 1-bit data input
            .WCLK(WCLK),  // Write clock input
            .WE(WE)       // Write enable input
        );
    end
end else if (RAM_DEPTH==64) begin
    for (genvar i=0; i<DATA_WIDTH; i++) begin
        RAM64X1S #(
            .INIT(64'h0000000000000000) // Initial contents of RAM
        ) RAM64X1S_inst (
            .O(O[i]),     // 1-bit data output
            .A0(A[0]),    // Address[0] input bit
            .A1(A[1]),    // Address[1] input bit
            .A2(A[2]),    // Address[2] input bit
            .A3(A[3]),    // Address[3] input bit
            .A4(A[4]),    // Address[4] input bit
            .A5(A[5]),    // Address[5] input bit
            .D(D[i]),     // 1-bit data input
            .WCLK(WCLK),  // Write clock input
            .WE(WE)       // Write enable input
        );
    end
end else begin
    for (genvar i=0; i<DATA_WIDTH; i++) begin
        RAM32X1S #(
            .INIT(32'h00000000)  // Initial contents of RAM
        ) RAM32X1S_inst (
            .O(O[i]),    // RAM output
            .A0(A[0]),   // RAM address[0] input
            .A1(A[1]),   // RAM address[1] input
            .A2(A[2]),   // RAM address[2] input
            .A3(A[3]),   // RAM address[3] input
            .A4(A[4]),   // RAM address[4] input
            .D(D[i]),    // RAM data input
            .WCLK(WCLK), // Write clock input
            .WE(WE)      // Write enable input
        );
    end
end endgenerate

// End of RAM256X1S_inst instantiation

endmodule