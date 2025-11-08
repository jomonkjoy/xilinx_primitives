
module shallow_fifo_sync #(
    parameter DATA_WIDTH            = 8,
    parameter FIFO_DEPTH            = 32,
    parameter PROG_FULL_THRESH      = 8,
    parameter PROG_EMPTY_THRESH     = 8,
    parameter COUNT_WIDTH           = $clog2(FIFO_DEPTH)+1
)(
    input  logic                    clk,
    input  logic                    rst_n,
    // Write interface
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    // Read interface
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    // Status signals
    output logic                    full,
    output logic                    empty,
    output logic                    prog_full,
    output logic                    prog_empty,
    output logic [COUNT_WIDTH-1:0]  count
);

    // Address width for 32-deep FIFO
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);
    
    // Internal signals
    logic [ADDR_WIDTH-1:0]  wr_addr;
    logic [ADDR_WIDTH-1:0]  rd_addr;
    logic [COUNT_WIDTH-1:0] fifo_count;
    logic                   wren_internal;
    logic                   rden_internal;
    
    // Write enable generation (write only if not full and wr_en is asserted)
    assign wren_internal = wr_en & ~full;
    
    // Read enable generation (read only if not empty and rd_en is asserted)
    assign rden_internal = rd_en & ~empty;
    
    // Instantiate RAM32X1D for each bit of the data width
    xilinx_dp_distram #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) dp_distram_inst (
        .WCLK   (clk),
        .WE     (wren_internal),
        .A      (wr_addr),
        .D      (wr_data),
        .SPO    (),
        .DPRA   (rd_addr),
        .DPO    (rd_data)
    );
    
    // Write address pointer
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_addr <= '0;
        else if (wren_internal)
            wr_addr <= wr_addr + 1'b1;
    end
    
    // Read address pointer
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rd_addr <= '0;
        else if (rden_internal)
            rd_addr <= rd_addr + 1'b1;
    end
    
    // FIFO count logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            fifo_count <= '0;
        else begin
            case ({wren_internal, rden_internal})
                2'b10: fifo_count <= fifo_count + 1'b1;  // Write only
                2'b01: fifo_count <= fifo_count - 1'b1;  // Read only
                default: fifo_count <= fifo_count;        // Both or neither
            endcase
        end
    end
    
    // Status signals
    assign empty = (fifo_count == 0);
    assign full  = (fifo_count == FIFO_DEPTH);
    assign prog_empty = (fifo_count <= PROG_EMPTY_THRESH);
    assign prog_full  = (fifo_count >= (FIFO_DEPTH-PROG_FULL_THRESH));
    assign count = fifo_count;

endmodule
