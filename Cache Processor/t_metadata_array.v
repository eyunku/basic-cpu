`include "metadata_array.v"
`include "dff.v" 

module t_metadata_array ();
    reg clk, rst, WriteEnable, Enable;
    reg [6:0] Din;
    wire [6:0] Dout;
    wire CacheHit, lru_sig, way;

    MBlock dut (
        .clk(clk),
        .rst(rst),
        .Din(Din),
        .WriteEnable(WriteEnable),
        .Enable(Enable),
        .Dout(Dout),
        .CacheHit(CacheHit),
        .lru_sig(lru_sig),
        .way(way)
    ); 

    initial begin
        $dumpfile("t_metadata_array.vcd");
        $dumpvars(0, t_metadata_array);

        clk = 0; rst = 1; Enable = 0; #20
        rst = 0; #20
        
        #20; $display("Dout=%b (z), CacheHit=%b (0), lru_sig=%b (z), way=%b (z)", Dout, CacheHit, lru_sig, way);
        Enable = 1;

        // read, no valid data
        Din = 7'b1001010;
        WriteEnable = 0;
        #20; $display("Dout=%b (z), CacheHit=%b (0), lru_sig=%b (0), way=%b (z)", Dout, CacheHit, lru_sig, way);

        // write first tag
        Din = 7'b1001010;
        WriteEnable = 1;
        #20; $display("Dout=%b (z), CacheHit=%b (1, hit after write), lru_sig=%b (0), way=%b (0)", Dout, CacheHit, lru_sig, way);

        // read first tag
        Din = 7'b1001010;
        WriteEnable = 0;
        #20; $display("Dout=%b (1001010), CacheHit=%b (1), lru_sig=%b (1), way=%b (0)", Dout, CacheHit, lru_sig, way);

        // write second tag
        Din = 7'b1000011;
        WriteEnable = 1;
        #20; $display("Dout=%b (z), CacheHit=%b (1, hit after write), lru_sig=%b (1), way=%b (1)", Dout, CacheHit, lru_sig, way);

        // read second tag
        Din = 7'b1000011;
        WriteEnable = 0;
        #20; $display("Dout=%b (1000011), CacheHit=%b (1), lru_sig=%b (0), way=%b (1)", Dout, CacheHit, lru_sig, way);

        // write first tag, again
        Din = 7'b1001010;
        WriteEnable = 1;
        #20; $display("Dout=%b (z), CacheHit=%b (1), lru_sig=%b (0), way=%b (0)", Dout, CacheHit, lru_sig, way);

        // read first tag, again
        Din = 7'b1001010;
        WriteEnable = 0;
        #20; $display("Dout=%b (1001010), CacheHit=%b (1), lru_sig=%b (1), way=%b (0)", Dout, CacheHit, lru_sig, way);

        // write second tag, again
        Din = 7'b1000011;
        WriteEnable = 1;
        #20; $display("Dout=%b (z), CacheHit=%b (1), lru_sig=%b (1), way=%b (1)", Dout, CacheHit, lru_sig, way);
        $stop;
        $finish;
    end
  
    always begin
        #10;
        clk = ~clk;
    end

endmodule
