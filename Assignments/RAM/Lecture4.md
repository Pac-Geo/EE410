
PBL 10: Four-Bit Full-Adder with Tri-State Buffer
Design a 4-bit adder that is connected to a tri-state buffer, as depicted in the block diagram shown in Figure 6.18. The input signals, a and b, are both 4 bits wide, resulting in a 5-bit output signal, c.

To control the functionality of the tri-state buffer, an enable signal labeled en is required:
- When en = 0 (FALSE), the output of the tri-state buffer is in a high-impedance state (high-Z), indicating an open circuit.
- When en = 1 (TRUE), the output is assigned the adder's result.
<img width="276" height="104" alt="Screenshot 2026-11-03 at 12 30 28 PM" src="https://github.com/user-attachments/assets/c48cf6b4-fcbc-4986-96cf-8a499d2b199a" />

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
  
<img width="167" height="72" alt="Screenshot 2026-11-03 at 12 31 15 PM" src="https://github.com/user-attachments/assets/5f9c671b-f51e-4e7a-99b0-a81a290c950e" />

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
<img width="730" height="373" alt="Screenshot 2026-11-03 at 12 40 10 PM" src="https://github.com/user-attachments/assets/d89f9f7e-a0ea-4237-8ae3-5c8f7e5aead3" />
.
<img width="630" height="374" alt="Screenshot 2026-11-03 at 12 32 03 PM" src="https://github.com/user-attachments/assets/dcb8b05c-3fc9-46bf-860f-6e085d06dfaa" />


PBL 12: Four-Bit Full-Adder with Register
Design a 4-bit adder that is connected to a register, as depicted in the block diagram shown in Figure 6.20. The input signals, a and b, are both 4 bits wide, resulting in a 5-bit output signal, c.

The register requires two control signals:
- clk: Clock signal.
- rst: Asynchronous reset signal to reset the register output to hexadecimal 5'h0.

<img width="166" height="72" alt="Screenshot 2026-11-03 at 12 35 13 PM" src="https://github.com/user-attachments/assets/9f04f9d8-8617-4f5e-9964-ea80190182e1" />

Figure 6.20 — Block Diagram of 4-bit Adder with Register.

```verilog
module pbl12 (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire clk,
    input wire rst,
    output reg [4:0] c
);

wire [4:0] sum;

assign sum = {1'b0, a} + {1'b0, b};

always @(posedge clk or negedge rst) begin
    if (!rst)
        c <= 5'h0;
    else
        c <= sum;
end

endmodule
```
<img width="748" height="254" alt="Screenshot 2026-11-03 at 1 06 09 PM" src="https://github.com/user-attachments/assets/d607f1e7-6bf8-4960-8627-524296e5d090" />

<img width="641" height="425" alt="image" src="https://github.com/user-attachments/assets/4b1c1725-4603-480a-93c2-4b8f7afe0493" />

NOTE: In Running Synthesis
Timing warnings: Vivado doesn't have a clock constraint (create_clock). This matters for hardware timing analysis, but it doesn't prevent us from checking the assignment's logic.

Simulation error: Vivado cannot access simulate.log because another process is using it. This is a file-locking problem, not a Verilog error.



PBL 13: Counter 0–9
Design a counter that counts clock cycles from hexadecimal 4'h0 to 4'h9, as specified in Figure 6.21(a). The counter has the following input/output connections, as summarized in Table 6.3. It operates based on an asynchronous reset and is triggered by the rising clock edge. When the counter reaches its maximum value of 4'h9, it restarts from 4'h0 in the next counting loop. The output of the counter is a 4-bit value, accommodating hexadecimal values ranging from 4'h0 to 4'h9.

<img width="437" height="128" alt="Screenshot 2026-11-03 at 1 13 14 PM" src="https://github.com/user-attachments/assets/8b6822ae-591d-47ed-9a08-155a742c9c48" />
.

<img width="388" height="228" alt="Screenshot 2026-11-03 at 1 13 40 PM" src="https://github.com/user-attachments/assets/0f817596-59fd-483f-afc9-e0bb943dd5fa" />

Figure 6.21 — Design Specification of Counter for 10 Cycles.
- Figure 6.21(b) illustrates the timing diagram, showing the counter progressing from 4'h0 to 4'h9.
- Figure 6.21(c) depicts a comparator and multiplexer for returning the counter to 4'h0 after reaching 4'h9.
- The comparator checks whether cnt == 4'h9. If TRUE, the multiplexer selects 4'h0; otherwise it selects cnt + 4'h1.

Figure 6.21(b) illustrates the timing diagram of the counter, showcasin its behavior from hexadecimal 4'h0 to 4'h9. To handle the initialization of the counter when it reaches hexadecimal 4'h9, the utilization of a comparator and a multiplexer is required. Figure 6.21(c) presents a block diagram depicting these components. The comparator compares the counter output with the hexadecimal value 4'h9. When the counter reaches 4'h9, the comparator output evaluates to TRUE This triggers the multiplexer to switch its channels. If the comparator output is TRUE, the multiplexer selects the input signal representing 4'h0, causing the counter to reset back to hexadecimal 4'h0. On the other hand, if the comparator output is FALSE, the multiplexer selects the input signal representing the current counter value plus hexadecimal 4'h1, incrementing the counter by one during each clock cycle.

```veriog

module pbl13 (
    input wire clk,
    input wire rst,
    input wire en,
    output reg [3:0] cnt
);

always @(posedge clk or negedge rst) begin
    if (!rst)
        cnt <= 4'h0;
    else if (en) begin
        if (cnt == 4'h9)
            cnt <= 4'h0;
        else
            cnt <= cnt + 4'h1;
    end
end

endmodule
```
<img width="773" height="251" alt="Screenshot 2026-11-03 at 1 29 19 PM" src="https://github.com/user-attachments/assets/a63f2f81-37ff-494a-a5ff-4f714139b8df" />


<img width="825" height="218" alt="Screenshot 2026-11-03 at 1 28 34 PM" src="https://github.com/user-attachments/assets/70de7dd4-eb3e-45e8-b910-cd7040344f14" />


PBL 14: Timer 0–9
Design a timer that counts from hexadecimal 4'h0 to 4'h9 with a unit of 0.1 microseconds (µs). The sequential circuit utilizes an asynchronous reset and is triggered by the rising clock edge.

Hint from the source: With a clock frequency of 100 MHz, each clock cycle lasts 10 nanoseconds (ns). To achieve a unit of 0.1 µs, use 10 clock cycles per timer unit.

<img width="441" height="124" alt="Screenshot 2026-11-03 at 1 38 15 PM" src="https://github.com/user-attachments/assets/114c2457-5d71-4a78-a5d3-0b118079e595" />

<img width="429" height="271" alt="Screenshot 2026-11-03 at 1 41 02 PM" src="https://github.com/user-attachments/assets/7afcb4f7-2879-405f-b120-94aadb8d62c6" />

Figure 6.22 — Design Specification of Timer for 10 × 0.1 µs.
- Figure 6.22(a) describes a two-level design. A first-level counter measures groups of 10 clock cycles; a second-level timer advances tim by 4'h1 for each group.
- Figure 6.22(b) shows tim incrementing every 10 clock cycles. After the 100th clock cycle, both cnt and tim restart at 4'h0.
- Figure 6.22(c) shows comparators checking whether cnt == 4'h9 and tim == 4'h9; their outputs are combined to determine when the complete timer sequence restarts.

```verilog
module pbl14 (
    input wire clk,
    input wire rst,
    input wire en,
    output reg [3:0] tim
);

reg [3:0] cnt;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        cnt <= 4'h0;
        tim <= 4'h0;
    end
    else if (en) begin
        if (cnt == 4'h9) begin
            cnt <= 4'h0;

            if (tim == 4'h9)
                tim <= 4'h0;
            else
                tim <= tim + 4'h1;
        end
        else
            cnt <= cnt + 4'h1;
    end
end

endmodule
```
<img width="773" height="203" alt="Screenshot 2026-11-03 at 1 39 54 PM" src="https://github.com/user-attachments/assets/e5eef544-7a82-4cdc-b889-cad65cad1418" />

<img width="827" height="165" alt="Screenshot 2026-11-03 at 1 40 15 PM" src="https://github.com/user-attachments/assets/5e7b6827-9f85-4631-9d55-3b4ae4c317cc" />


PBL 15: Timing Interface
Design a timing interface as depicted in the timing diagram shown in Figure 6.23. The output signal, sig, is initially set to binary zero. It transitions to binary one during the intervals 0–0.3 µs and 0.6–0.9 µs. Between 0.4 µs and 0.5 µs, it is zero. After 0.9 µs, the signal returns to zero.

<img width="394" height="129" alt="image" src="https://github.com/user-attachments/assets/a6d42900-bd6f-4663-bd3d-d8523f56e2f2" />

<img width="294" height="100" alt="image" src="https://github.com/user-attachments/assets/77572c08-e9ec-4f6a-ad6b-00edde439473" />


 <img width="451" height="253" alt="Screenshot 2026-11-03 at 1 55 39 PM" src="https://github.com/user-attachments/assets/0f855326-29db-4335-862c-b7ca82a94bea" />

- Figure 6.24 shows the timing interface's block diagram, using the timer from Figure 6.22.
- The timer output is compared against hexadecimal 4'h3, 4'h4, and 4'h9.
- Set sig = 1'b1 when (tim > 4'h4 AND tim < 4'h9), OR when (tim < 4'h3).
- The specified output logic can therefore be implemented using comparisons, an AND gate, and an OR gate.
Figures 6.23 and
6.24 — Timing Diagram and Block Diagram of Timing Interface.

```verilog
module pbl15 (
    input wire clk,
    input wire rst,
    input wire en,
    output wire sig
);

reg [3:0] cnt;
reg [3:0] tim;

// Timer: 100 MHz clock, 0.1 us per timer unit
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        cnt <= 4'h0;
        tim <= 4'h0;
    end
    else if (en) begin
        if (cnt == 4'h9) begin
            cnt <= 4'h0;

            if (tim == 4'h9)
                tim <= 4'h0;
            else
                tim <= tim + 4'h1;
        end
        else
            cnt <= cnt + 4'h1;
    end
end

// Timing interface output
assign sig = rst && en &&
             ((tim <= 4'h3) || (tim >= 4'h6));

endmodule

```
<img width="783" height="173" alt="image" src="https://github.com/user-attachments/assets/7e5f56eb-306a-4b78-bb43-c111a532afe9" />

<img width="832" height="193" alt="image" src="https://github.com/user-attachments/assets/42cfc08b-dbcf-4dd8-951a-62cb6f4d5efc" />


PBL 16: Timing Controller
Design a circuit composed of a datapath and a timing controller, as specified in Figure 6.25(a). The datapath consists of three 8-bit binary components: an adder (ADD) followed by two multipliers (MUL1 and MUL2) in series.

Assume that each binary component takes one clock cycle from its input to its output. The final result g is produced after three processing clock cycles once inputs a–`d` are provided.

A counter-based timing controller coordinates the operations. The enable input en activates the counter, and the finish indicator fi signals that data processing is complete.

Hint from the source: The addition and multiplication operations may be described in Verilog using + and *. Assume there are no overflow situations. Three 8-bit registers are needed between the ADD–MUL1–MUL2 stages to store intermediate results and isolate the datapath stages.

<img width="466" height="254" alt="Screenshot 2026-11-03 at 2 29 33 PM" src="https://github.com/user-attachments/assets/8550aa52-f291-4cd4-ae43-32dfbc2914fb" />


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



<img width="787" height="222" alt="image" src="https://github.com/user-attachments/assets/12cfcd0f-05a2-485b-acb5-f3867bee4c59" />

