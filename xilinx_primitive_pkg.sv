package xilinx_primitive_pkg; 

/////////////////////////////////////////////////////////////////
// Function to calculate FIFO depth based on DATA_WIDTH and FIFO_SIZE
/////////////////////////////////////////////////////////////////
function automatic integer get_fifo_depth(input integer data_width, input string fifo_size);
    integer depth;
    integer N;
    
    // Multiplication factor based on FIFO size
    N = (fifo_size == "36Kb") ? 2 : 1;
    
    // Base depth calculation
    if (data_width > 32 && data_width <= 64) begin
        if (fifo_size != "36Kb") begin
            $error("DATA_WIDTH=%0d not supported for FIFO_SIZE=18Kb (valid range: 1-36)", data_width);
            depth = 0;
        end
        else
            depth = 512;          // 36Kb only: 512
    end
    else if (data_width > 16 && data_width <= 32)
        depth = 512 * N;          // 36Kb: 1024, 18Kb: 512
    else if (data_width > 8 && data_width <= 16)
        depth = 1024 * N;         // 36Kb: 2048, 18Kb: 1024
    else if (data_width > 4 && data_width <= 8)
        depth = 2048 * N;         // 36Kb: 4096, 18Kb: 2048
    else if (data_width > 0 && data_width <= 4)
        depth = 4096 * N;         // 36Kb: 8192, 18Kb: 4096
    else begin
        $error("Invalid DATA_WIDTH=%0d for FIFO_SIZE=%s", data_width, fifo_size);
        depth = 0;
    end
    
    return depth;
endfunction

/////////////////////////////////////////////////////////////////
// Function to calculate SDP BRAM depth based on READ_WIDTH / WRITE_WIDTH and BRAM_SIZE
/////////////////////////////////////////////////////////////////
function automatic integer get_sdp_depth(input integer data_width, input string bram_size);
    integer depth;
    integer N;
    
    // Multiplication factor based on BRAM size
    N = (bram_size == "36Kb") ? 2 : 1;
    
    // Base depth calculation
    if (data_width > 32 && data_width <= 64) begin
        if (bram_size != "36Kb") begin
            $error("DATA_WIDTH=%0d not supported for BRAM_SIZE=18Kb (valid range: 1-36)", read_width);
            depth = 0;
        end
        else
            depth = 512;          // 36Kb only: 512
    end
    else if (data_width > 16 && data_width <= 32)
        depth = 512 * N;          // 36Kb: 1024, 18Kb: 512
    else if (data_width > 8 && data_width <= 16)
        depth = 1024 * N;         // 36Kb: 2048, 18Kb: 1024
    else if (data_width > 4 && data_width <= 8)
        depth = 2048 * N;         // 36Kb: 4096, 18Kb: 2048
    else if (data_width > 2 && data_width <= 4)
        depth = 4096 * N;         // 36Kb: 8192, 18Kb: 4096
    else if (data_width == 2)
        depth = 8192 * N;         // 36Kb: 16384, 18Kb: 8192
    else if (data_width == 1)
        depth = 16384 * N;        // 36Kb: 32768, 18Kb: 16384
    else begin
        $error("Invalid DATA_WIDTH=%0d for BRAM_SIZE=%s", data_width, bram_size);
        depth = 0;
    end
    
    return depth;
endfunction

/////////////////////////////////////////////////////////////////
// Function to calculate WE width based on DATA_WIDTH
/////////////////////////////////////////////////////////////////
function automatic integer get_sdp_we_width(input integer data_width);
    integer we_width;
    
    if (data_width > 32 && data_width <= 64)
        we_width = 8;
    else if (data_width > 16 && data_width <= 32)
        we_width = 4;
    else if (data_width > 8 && data_width <= 16)
        we_width = 2;
    else if (data_width > 0 && data_width <= 8)
        we_width = 1;
    else begin
        $error("Invalid DATA_WIDTH=%0d", data_width);
        we_width = 0;
    end
    
    return we_width;
endfunction

/////////////////////////////////////////////////////////////////
// Function to calculate BRAM depth based on DATA_WIDTH and BRAM_SIZE
/////////////////////////////////////////////////////////////////
function automatic integer get_tdp_bram_depth(input integer data_width, input string bram_size);
    integer depth;
    integer N;
    
    // Multiplication factor based on BRAM size
    N = (bram_size == "36Kb") ? 2 : 1;
    
    // Base depth calculation
    if (data_width > 16 && data_width <= 32) begin
        if (bram_size != "36Kb") begin
            $error("DATA_WIDTH=%0d not supported for BRAM_SIZE=18Kb (valid range: 1-18)", data_width);
            depth = 0;
        end
        else
            depth = 1024;         // 36Kb only: 1024
    end
    else if (data_width > 8 && data_width <= 16)
        depth = 1024 * N;         // 36Kb: 2048, 18Kb: 1024
    else if (data_width > 4 && data_width <= 8)
        depth = 2048 * N;         // 36Kb: 4096, 18Kb: 2048
    else if (data_width > 2 && data_width <= 4)
        depth = 4096 * N;         // 36Kb: 8192, 18Kb: 4096
    else if (data_width == 2)
        depth = 8192 * N;         // 36Kb: 16384, 18Kb: 8192
    else if (data_width == 1)
        depth = 16384 * N;        // 36Kb: 32768, 18Kb: 16384
    else begin
        $error("Invalid DATA_WIDTH=%0d for BRAM_SIZE=%s", data_width, bram_size);
        depth = 0;
    end
    
    return depth;
endfunction

/////////////////////////////////////////////////////////////////
// Function to calculate WE width based on DATA_WIDTH
/////////////////////////////////////////////////////////////////
function automatic integer get_tdp_we_width(input integer data_width);
    integer we_width;
    
    if (data_width > 16 && data_width <= 32)
        we_width = 4;
    else if (data_width > 8 && data_width <= 16)
        we_width = 2;
    else if (data_width > 0 && data_width <= 8)
        we_width = 1;
    else begin
        $error("Invalid DATA_WIDTH=%0d", data_width);
        we_width = 0;
    end
    
    return we_width;
endfunction

endpackage : xilinx_primitive_pkg