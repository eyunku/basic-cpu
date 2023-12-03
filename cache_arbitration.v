module cache_to_mem(
    input d_read, d_write, i_read,
    input [15:0] d_addr, i_addr,
    output d_valid, i_valid,
    output [15:0] d_data, i_data
);
    wire
    // mux logic here


    /** 
    * multi-cycle module here 
    **/
    memory4c main_mem (.data_out(), .data_in(), .addr(), .enable(), .wr(), .clk(), .rst(), .data_valid())
endmodule