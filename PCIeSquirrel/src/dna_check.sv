`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module dna_check(
    input clk,
    input [56:0] expected_dna,
    output reg match
);
    
    reg running;
    reg [6:0] current_bit; // 0 - 63
    wire expected_dna_bit = expected_dna[56 - current_bit];
    wire dna_bit;
    
    reg dna_shift;
    reg dna_read;
    
    reg first;
    
    initial begin
        match <= 0;
        dna_shift <= 0;
        dna_read <= 0;
        current_bit <= 0;
        first <= 1;
        running <= 1;
    end
 
    DNA_PORT #(
        .SIM_DNA_VALUE  (57'h028340E18D8C85C)
    ) dna (
        .DOUT(dna_bit),
        .CLK(clk),
        .DIN(0), // Rollover
        .READ(dna_read),
        .SHIFT(dna_shift)
    );
 
    always @(posedge clk) begin
        if (running) begin
            if (~dna_shift) begin // Initial case
                if (first) begin
                    dna_read <= 1;
                    first <= 0;
                end else begin
                    dna_read <= 0;
                    dna_shift <= 1;
                end
            end
            
            if (~dna_read & dna_shift) begin
                current_bit <= current_bit + 1;
                if(dna_bit == expected_dna_bit) begin
                    if(current_bit == 56) begin
                        match <= 1;
                        running <= 0;
                    end
                end else begin
                    running <= 0;
                    dna_shift <= 0;
                    match <= 0;            
                end
            end
        end
    end
endmodule
