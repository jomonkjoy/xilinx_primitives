// Round-Robin Arbiter
// Provides fair arbitration among multiple requesters
// Grants access in a circular fashion to ensure no starvation

module scheduler_rr_arbiter #(
    parameter int N = 4
) (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [N-1:0]            req,         // Request signals
    output logic [N-1:0]            grant_oh,    // Grant signals (one-hot encoded)
    output logic [$clog2(N)-1:0]    grant_idx,   // Grant signals (binary encoded)
    output logic                    grant_vld
);

    // Internal signals
    logic [$clog2(N)-1:0] priority_ptr;  // Points to highest priority requester
    logic [N-1:0]         mask_req;      // Masked requests
    logic [N-1:0]         grant_masked_oh;  // Grant from masked arbitration
    logic [$clog2(N)-1:0] grant_masked_idx;  // Grant from masked arbitration
    logic [N-1:0]         grant_unmasked_oh;// Grant from unmasked arbitration
    logic [$clog2(N)-1:0] grant_unmasked_idx;// Grant from unmasked arbitration
    logic                 mask_has_req;  // At least one masked request exists
    
    // Priority pointer update logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            priority_ptr <= '0;
        end else if (|grant_oh) begin
            // Update priority pointer to next position after current grant
            priority_ptr <= get_next_ptr(grant_oh);
        end
    end
    
    // Create mask based on priority pointer
    // Mask gives higher priority to requesters at or above priority_ptr
    always_comb begin
        for (int i = 0; i < N; i++) begin
            mask_req[i] = req[i] && (i >= priority_ptr);
        end
    end
    
    // Check if any masked request exists
    assign mask_has_req = |mask_req;
    
    // Fixed priority arbiter for masked requests
    always_comb begin
        grant_masked_oh = '0;
        grant_masked_idx = '0;
        for (int i = 0; i < N; i++) begin
            if (mask_req[i]) begin
                grant_masked_oh[i] = 1'b1;
                grant_masked_idx = i[$clog2(N)-1:0];
                break;
            end
        end
    end
    
    // Fixed priority arbiter for all requests (used when no masked requests)
    always_comb begin
        grant_unmasked_oh = '0;
        grant_unmasked_idx = '0;
        for (int i = 0; i < N; i++) begin
            if (req[i]) begin
                grant_unmasked_oh[i] = 1'b1;
                grant_unmasked_idx = i[$clog2(N)-1:0];
                break;
            end
        end
    end
    
    // Final grant selection
    // Use masked grant if masked requests exist, otherwise use unmasked
    assign grant_oh  = mask_has_req ? grant_masked_oh : grant_unmasked_oh;
    assign grant_idx = mask_has_req ? grant_masked_idx : grant_unmasked_idx;
    assign grant_vld = (|req);
    
    // Function to calculate next priority pointer position
    function automatic [$clog2(N)-1:0] get_next_ptr(
        input logic [N-1:0] current_grant
    );
        for (int i = 0; i < N; i++) begin
            if (current_grant[i]) begin
                return (i + 1) % N;
            end
        end
        return 0;
    endfunction

endmodule