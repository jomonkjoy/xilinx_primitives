// Arbitration of Multiple clients for a SP-BRAM
module sp_bram_arbiter #(
    parameter ADDR_WIDTH = 8,
    parameter READ_WIDTH = 32,
    parameter WRITE_WIDTH = 32,
    parameter WE_WIDTH = ((WRITE_WIDTH+7)/8),
    parameter READ_LATENCY = 2,
    parameter N = 4
) (
    // SRAM Interface
    input  logic        [READ_WIDTH-1:0]   sram_do,
    output logic        [ADDR_WIDTH-1:0]   sram_addr,
    output logic        [WRITE_WIDTH-1:0]  sram_di,
    output logic        [WE_WIDTH-1:0]     sram_we,
    output logic                           sram_en,
    // Client interface
    output logic [N-1:0]                   client_busy,
    output logic [N-1:0][READ_WIDTH-1:0]   client_do,
    output logic [N-1:0]                   client_dvld,
    input  logic [N-1:0][ADDR_WIDTH-1:0]   client_addr,
    input  logic [N-1:0][WRITE_WIDTH-1:0]  client_di,
    input  logic [N-1:0][WE_WIDTH-1:0]     client_we,
    input  logic [N-1:0]                   client_en,
    // Clock & reset
    input  logic                            clk,
    input  logic                            rst_n
);
    
    localparam FIFO_DEPTH = 8;

    logic [N-1:0]           arb_req;
    logic [N-1:0]           arb_grant_oh;
    logic [$clog2(N)-1:0]   arb_grant_idx;
    logic                   arb_grant_vld;

    logic                   fifo_wr_en;
    logic [$clog2(N):0]     fifo_wr_data;
    logic                   fifo_rd_en;
    logic [$clog2(N):0]     fifo_rd_data;
    logic                   fifo_full;
    logic                   fifo_empty;
    logic                   fifo_prog_full;
    logic                   fifo_prog_empty;
    logic [3:0]             fifo_count;

    scheduler_rr_arbiter #(
        .N  (N)
    ) u_rr_arbiter (
        .clk        (clk),
        .rst_n      (rst_n),
        .req        (arb_req),          // Request signals
        .grant_oh   (arb_grant_oh),     // Grant signals (one-hot encoded)
        .grant_idx  (arb_grant_idx),    // Grant signals (binary encoded)
        .grant_vld  (arb_grant_vld)
    );

    assign arb_req[N-1:0] = client_en[N-1:0];
    assign client_busy[N-1:0] = ~arb_grant_oh[N-1:0];
    assign fifo_wr_en = arb_grant_vld;
    assign fifo_wr_data = {(|client_we),arb_grant_idx};
    assign fifo_rd_en = fifo_prog_full;
    
    shallow_fifo_sync #(
        .DATA_WIDTH            ($clog2(N)+1),
        .FIFO_DEPTH            (8),
        .PROG_FULL_THRESH      (READ_LATENCY),
        .PROG_EMPTY_THRESH     (1),
        .COUNT_WIDTH           (4)
    ) u_shallow_fifo_sync (
        .clk        (clk),
        .rst_n      (rst_n),
        .wr_en      (fifo_wr_en),
        .wr_data    (fifo_wr_data),
        .rd_en      (fifo_rd_en),
        .rd_data    (fifo_rd_data),
        .full       (fifo_full),
        .empty      (fifo_empty),
        .prog_full  (fifo_prog_full),
        .prog_empty (fifo_prog_empty),
        .count      (fifo_count)
    );

    // Output Multiplexer
    always_comb begin
        sram_addr   = client_addr[arb_grant_idx];
        sram_di     = client_di[arb_grant_idx];
        sram_we     = client_we[arb_grant_idx];
        sram_en     = arb_grant_vld;
    end

    // Read data demultiplexer
    always_comb begin
        client_do = '{default:'0};
        client_dvld = '0;
        for (int i=0; i<N; i++) begin
            if (fifo_rd_en & fifo_rd_data[$clog2(N)-1:0] == i[$clog2(N)-1:0]) begin
                client_do[i] = sram_do;
                client_dvld[i] = ~fifo_rd_data[$clog2(N)]; // Qualifier is WE
            end
        end
    end

endmodule