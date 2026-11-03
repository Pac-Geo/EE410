
PBL 10: Four-Bit Full-Adder with Tri-State Buer
Design a 4-bit adder that is connected to a tri-state buer, as depicted in the
block diagram shown in Figure 6.18. The input signals, a and b, are both
4 bits wide, resulting in a 5-bit output signal, c. To control the functionality
of the tri-state buer, an enable signal labeled as en is required. When the
enable signal evaluates to FALSE (or binary zero), the output of the tri-state
buer will be in a high-impedance state, denoted as high-Z, indicating an
open circuit. When the enable signal evaluates to TURE (or binary one), the
output will be assigned as the adder's output

Sysnthesys analysis View
<img width="654" height="375" alt="Screenshot 2026-11-03 at 11 00 43 AM" src="https://github.com/user-attachments/assets/47fed1b2-47e6-4b38-aa0e-19ea92155993" />

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

RTL View
<img width="747" height="210" alt="Screenshot 2026-11-03 at 11 30 20 AM" src="https://github.com/user-attachments/assets/11a7cfb4-9eb2-4f4d-a046-5d69af099816" />


