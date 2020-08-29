// *** FAST ADDER *** //
// Performs the operation out_o = a_i + b_i
// cin_i and cout_o are one-bit carry in and carry out signals respectively

module adder # (
    parameter width = 32
)
(
    input wire clk_i,
    input wire cin_i,
    input wire [width-1:0] a_i, b_i,
    output reg [width-1:0] out_o,
    output reg cout_o
);

localparam num_adders = width/8; // Number of 8-bit adders to be instantiated

wire carry_int [num_adders+1]; // Internal carry chain
assign carry_int[0] = cin_i;
assign cout_o = carry_int[num_adders];

genvar i;
for (i = 0; i < num_adders; i++) begin
    adder_pipeline # (
        .length (i),
        .num_adders (num_adders)
    )
    adder_pipeline_inst (
        .clk_i (clk_i),
        .a_i (a_i[i*8+7:i*8]), 
        .b_i (b_i[i*8+7:i*8]),
        .cin_i (carry_int[i]),
        .out_o (out_o[i*8+7:i*8]),
        .cout_o (carry_int[i+1])
    );
end
endmodule

// 8-bit adder with integrated, parameterised pipelining
module adder_pipeline # (
    parameter length = 1,
    parameter num_adders = 2
)
(
    input wire clk_i,
    input wire [7:0] a_i, b_i,
    input wire cin_i,
    output reg [7:0] out_o,
    output wire cout_o
);

wire cout_int; // Internal carry between adder cout and carry pipeline input
wire [7:0] a_int,
           b_int,
           out_int;
           
// A input pipeline stages, depends on position of adder in chain         
pipeline # (
    .width (8),
    .length (length)
)
pipeline_a_int (
    .clk_i (clk_i),
    .in_i (a_i),
    .out_o (a_int)
);
// B input pipeline stages, depends on position of adder in chain
pipeline # (
    .width (8),
    .length (length)
)
pipeline_b_int (
    .clk_i (clk_i),
    .in_i (b_i),
    .out_o (b_int)
);
// Instance of 8-bit adder
adder_8bit adder_inst1 (
    .clk_i (clk_i),
    .a_i (a_int),
    .b_i (b_int),
    .cin_i (cin_i),
    .out_o (out_int),
    .cout_o (cout_o)
);
// Output pipeline stages, depends on position of adder in chain
pipeline # (
    .width (8),
    .length (num_adders-length-1)
)
pipeline_out (
    .clk_i (clk_i),
    .in_i (out_int),
    .out_o (out_o)
);
endmodule

// Customisable width and length pipeline stage
module pipeline # (
    parameter width = 8,
    parameter length = 1
)
(
    input wire clk_i,
    input wire [width-1:0] in_i,
    output reg [width-1:0] out_o
);

wire [width-1:0] pipeline_int [length+1];
assign pipeline_int[0] = in_i;
assign out_o = pipeline_int[length];

genvar i;
for (i = 0; i < length; i++) begin
    pipeline_single # (
        .width (width)
    )
    pipeline_inst (
        .clk_i (clk_i),
        .in_i (pipeline_int[i]),
        .out_o (pipeline_int[i+1])
    );
end
endmodule

// Single, customisable width pipeline stage
module pipeline_single # (
    parameter width = 8
)
(
	input wire clk_i,
    input wire [width-1:0] in_i,
    output reg [width-1:0] out_o
);

always_ff @ (posedge clk_i) begin
    out_o <= in_i;
end
endmodule

// 8-bit adder
module adder_8bit (
    input wire clk_i,
    input wire [7:0] a_i, b_i,
    input wire cin_i,
    output reg [7:0] out_o,
    output reg cout_o
);

wire [8:0] out_full;
assign out_full = a_i + b_i + cin_i;

always_ff @ (posedge clk_i) begin
    out_o <= out_full[7:0];
    cout_o <= out_full[8];
end
endmodule
