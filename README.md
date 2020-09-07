
# Verilog FastAdder
High speed, customisable width adder core written in SystemVerilog

# Using the Core
The file `adder.sv` contains all the modules required to use the FastAdder core. The top-level module is named adder and has a single customisation parameter, `width` that is used to control the width (in bits) of the adder; and has the following ports:

| Port | Direction | Width | Description |
|---|---|---|---|
| clk_i | in | 1 | Clock input |
| cin_i | in | 1 | Carry input |
| a_i | in | `width` | A input to add function |
| b_i | in | `width` | B input to add function |
| out_o | out | `width` | Output of add function |
| cout_o | out | 1 | Carry output |

## Instantiating Core
### Verilog
```verilog
adder # (
    .width (16)
)
adder_inst (
    .clk_i (clk),
    .cin_i (cin),
    .a_i (a), 
    .b_i (b),
    .out_o (out),
    .cout_o (cout)
);
```
### VHDL
```vhdl
adder_inst : adder
generic map (
    width => 16
)
port map (
    clk_i => clk,
    cin_i => cin,
    a_i => a,
    b_i => b,
    out_o => out,
    cout_o => cout
)
```
# QoR Results
Performance was the most important aspect of this design, hence the pipelined architecture, and therefore is the QoR metric that is focused on the most.

QoR data has been gathered through the use of static timing analysis in Xilinx Vivado 2019.2 following synthesis. The Xilinx Zynq XC7Z020CLG400-1 device was used as a target for synthesis. The FPGA fabric of this device is based on the architecture of an Artix device.

Comparisons are made to the Xilinx Adder/Subtractor IP core, both this and the FastAdder are functionally identical with identical latencies. 
## Performance
FastAdder is able to perform up to 50% faster than functionally identical configuration of the Xilinx Adder.
| Width | FastAdder | Xilinx Adder |
|---|---|---|
| 16-bits | 450 MHz | 390 MHz |
| 32-bits | 450 MHz | 300 MHz |
| 64-bits | 450 MHz | 300 MHz |

## Resource Utilisation
FastAdder uses slightly more resources than the Xilinx Adder, however, this is expected, given the significant performance increase.
| Width | FastAdder | Xilinx Adder |
|---|---|---|
| 16-bits | 16 LUT, 42 FF | 16 LUT, 33 FF |
| 32-bits | 40 LUT, 8 LUTRAM, 164 FF | 33 LUT, 99 FF |
| 64-bits | 168 LUT, 104, LUTRAM, 350 FF | 123 LUT, 247 FF |

# Future Development
- Add sutract feature
- Add variants with support for more than two adder inputs
