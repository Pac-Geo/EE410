
PBL 10: Four-Bit Full-Adder with Tri-State Buffer
Design a 4-bit adder that is connected to a tri-state buffer, as depicted in the block diagram shown in Figure 6.18. The input signals, a and b, are both 4 bits wide, resulting in a 5-bit output signal, c.

To control the functionality of the tri-state buffer, an enable signal labeled en is required:
- When en = 0 (FALSE), the output of the tri-state buffer is in a high-impedance state (high-Z), indicating an open circuit.
- When en = 1 (TRUE), the output is assigned the adder's result.

Sysnthesys analysis View
<img width="654" height="375" alt="Screenshot 2026-11-03 at 11 00 43 AM" src="https://github.com/user-attachments/assets/47fed1b2-47e6-4b38-aa0e-19ea92155993" />
```verilog
module pbl10 (

    input wire [3:0] a,
    
    input wire [3:0] b,
    
    input wire en,
    
    output wire [4:0] c
    
);

    wire [4:0] sum;
    
    assign sum = {1'b0, a} + {1'b0, b};
    
    assign c = en ? sum : 5'bzzzzz;
    
endmodule
```
RTL View
<img width="747" height="210" alt="Screenshot 2026-11-03 at 11 30 20 AM" src="https://github.com/user-attachments/assets/11a7cfb4-9eb2-4f4d-a046-5d69af099816" />

PBL 11: Four-Bit Full-Adder with Latch
Design a 4-bit adder that is connected to a latch, as depicted in the block diagram shown in Figure 6.19. The input signals, a and b, are both 4 bits wide, resulting in a 5-bit output signal, c.

The latch requires two control signals:
- en: Enable signal to activate the latch.
- rst: Asynchronous reset signal to reset the latch output to hexadecimal 5'h0.
Figure 6.19 — Block Diagram of 4-bit Adder with Latch.

```verilog
module pbl11 (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire en,
    input wire rst,
    output reg [4:0] c
);

wire [4:0] sum;

assign sum = {1'b0, a} + {1'b0, b};

always @(*) begin
    if (!rst)
        c = 5'h0;
    else if (en)
        c = sum;
end

endmodule
```










PBL 12: Four-Bit Full-Adder with Register
Design a 4-bit adder that is connected to a register, as depicted in the block diagram shown in Figure 6.20. The input signals, a and b, are both 4 bits wide, resulting in a 5-bit output signal, c.

The register requires two control signals:
- clk: Clock signal.
- rst: Asynchronous reset signal to reset the register output to hexadecimal 5'h0.
Figure 6.20 — Block Diagram of 4-bit Adder with Register.
PBL 13: Counter 0–9
Design a counter that counts clock cycles from hexadecimal 4'h0 to 4'h9, as specified in Figure 6.21(a). The counter operates based on an asynchronous reset and is triggered by the rising clock edge. When the counter reaches its maximum value of 4'h9, it restarts from 4'h0 in the next counting loop. The output cnt is a 4-bit value.

Table 6.3 — Counter 0–9 I/O Description
Name	Direction	Bit Width	Description
clk	Input	1	Clock, rising-edge trigger, 100 MHz
rst	Input	1	Asynchronous reset, active-low (0 valid)
en	Input	1	Enable signal, active-high (1 valid)
cnt	Output	4	Counter output


Additional design specifications:
- Figure 6.21(b) illustrates the timing diagram, showing the counter progressing from 4'h0 to 4'h9.
- Figure 6.21(c) depicts a comparator and multiplexer for returning the counter to 4'h0 after reaching 4'h9.
- The comparator checks whether cnt == 4'h9. If TRUE, the multiplexer selects 4'h0; otherwise it selects cnt + 4'h1.
Figure 6.21 — Design Specification of Counter for 10 Cycles.
PBL 14: Timer 0–9
Design a timer that counts from hexadecimal 4'h0 to 4'h9 with a unit of 0.1 microseconds (µs). The sequential circuit utilizes an asynchronous reset and is triggered by the rising clock edge.

Hint from the source: With a clock frequency of 100 MHz, each clock cycle lasts 10 nanoseconds (ns). To achieve a unit of 0.1 µs, use 10 clock cycles per timer unit.

Table 6.4 — Timer 0–9 I/O Description
Name	Direction	Bit Width	Description
clk	Input	1	Clock, rising-edge trigger, 100 MHz
rst	Input	1	Asynchronous reset, active-low (0 valid)
en	Input	1	Enable the timer from 0 to 9
tim	Output	4	Timer output


Additional design specifications:
- Figure 6.22(a) describes a two-level design. A first-level counter measures groups of 10 clock cycles; a second-level timer advances tim by 4'h1 for each group.
- Figure 6.22(b) shows tim incrementing every 10 clock cycles. After the 100th clock cycle, both cnt and tim restart at 4'h0.
- Figure 6.22(c) shows comparators checking whether cnt == 4'h9 and tim == 4'h9; their outputs are combined to determine when the complete timer sequence restarts.
Figure 6.22 — Design Specification of Timer for 10 × 0.1 µs.
PBL 15: Timing Interface
Design a timing interface as depicted in the timing diagram shown in Figure 6.23. The output signal, sig, is initially set to binary zero. It transitions to binary one during the intervals 0–0.3 µs and 0.6–0.9 µs. Between 0.4 µs and 0.5 µs, it is zero. After 0.9 µs, the signal returns to zero.

Table 6.5 — Timing Interface I/O Description
Name	Direction	Bit Width	Description
clk	Input	1	Clock, 100 MHz
rst	Input	1	Asynchronous reset, active-low (0 valid)
en	Input	1	Enable signal
sig	Output	1	Signal output


Additional design specifications:
- Figure 6.24 shows the timing interface's block diagram, using the timer from Figure 6.22.
- The timer output is compared against hexadecimal 4'h3, 4'h4, and 4'h9.
- Set sig = 1'b1 when (tim > 4'h4 AND tim < 4'h9), OR when (tim < 4'h3).
- The specified output logic can therefore be implemented using comparisons, an AND gate, and an OR gate.
Figures 6.23 and 6.24 — Timing Diagram and Block Diagram of Timing Interface.
PBL 16: Timing Controller
Design a circuit composed of a datapath and a timing controller, as specified in Figure 6.25(a). The datapath consists of three 8-bit binary components: an adder (ADD) followed by two multipliers (MUL1 and MUL2) in series.

Assume that each binary component takes one clock cycle from its input to its output. The final result g is produced after three processing clock cycles once inputs a–`d` are provided.

A counter-based timing controller coordinates the operations. The enable input en activates the counter, and the finish indicator fi signals that data processing is complete.

Hint from the source: The addition and multiplication operations may be described in Verilog using + and *. Assume there are no overflow situations. Three 8-bit registers are needed between the ADD–MUL1–MUL2 stages to store intermediate results and isolate the datapath stages.

Table 6.6 — Timing Controller I/O Description
Name	Direction	Bit Width	Description
clk	Input	1	Clock, 100 MHz
rst	Input	1	Asynchronous reset, active-low (0 valid)
en	Input	1	Enable signal
a–`d`	Input	8 each	Input data
g	Output	8	Output data
fi	Output	1	Finish indicator


Ready–valid and timing specifications:
- Use rdy1/`vld1` for the adder, rdy2/`vld2` for MUL1, and rdy3/`vld3` for MUL2.
- Clock cycle 1: Inputs a and b are ready (rdy1).
- Clock cycle 2: The adder output e becomes valid (vld1); inputs e and c are ready for MUL1 (rdy2).
- Clock cycle 3: MUL1 output f becomes valid (vld2); inputs f and d are ready for MUL2 (rdy3).
- Clock cycle 4: The final output g becomes valid (vld3); fi is asserted at the same time.
- A 2-bit counter may count from 2'd0 to 2'd3 and then restart at 2'b0.
- Set en low during the clock cycle in which fi is asserted to complete the enable–finish handshaking sequence.
Figure 6.25 — Design Specification of Timing Controller (Datapath and Timing Diagram).




