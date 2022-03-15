`include "define.tmp.h"
`include "l15.tmp.h"

module mor1kx_l15_arbiter
(
  input clk,
  input rst,

  // icache
  input        icache_transducer_l15_val,
  input [4:0]  icache_transducer_l15_rqtype,
  input        icache_transducer_l15_nc,
  input [2:0]  icache_transducer_l15_size,
  input [1:0]  icache_transducer_l15_l1rplway,
  input [39:0] icache_transducer_l15_address,

  output        icache_l15_transducer_header_ack,
  output        icache_l15_transducer_ack,
  output        icache_l15_transducer_val,
  output [3:0]  icache_l15_transducer_returntype,
  output [1:0]  icache_l15_transducer_error,
  output        icache_l15_transducer_noncacheable,
  output [63:0] icache_l15_transducer_data_0,
  output [63:0] icache_l15_transducer_data_1,
  output [63:0] icache_l15_transducer_data_2,
  output [63:0] icache_l15_transducer_data_3,

  input        icache_transducer_l15_req_ack,

  // dcache
  input        dcache_transducer_l15_val,
  input [4:0]  dcache_transducer_l15_rqtype,
  input [3:0]  dcache_transducer_l15_amo_op,
  input [63:0] dcache_transducer_l15_data,
  input [63:0] dcache_transducer_l15_data_next_entry,
  input [2:0]  dcache_transducer_l15_size,
  input        dcache_transducer_l15_nc,
  input [1:0]  dcache_transducer_l15_l1rplway,
  input [39:0] dcache_transducer_l15_address,

  output        dcache_l15_transducer_header_ack,
  output        dcache_l15_transducer_ack,
  output        dcache_l15_transducer_val,
  output [3:0]  dcache_l15_transducer_returntype,
  output [1:0]  dcache_l15_transducer_error,
  output        dcache_l15_transducer_noncacheable,
  output [63:0] dcache_l15_transducer_data_0,
  output [63:0] dcache_l15_transducer_data_1,
  output [63:0] dcache_l15_transducer_data_2,
  output [63:0] dcache_l15_transducer_data_3,


  input        dcache_transducer_l15_req_ack,

  // l15
  input        l15_transducer_header_ack,
  input        l15_transducer_ack,
  input        l15_transducer_val,
  input [3:0]  l15_transducer_returntype,
  input [1:0]  l15_transducer_error,
  input        l15_transducer_noncacheable,
  input [63:0] l15_transducer_data_0,
  input [63:0] l15_transducer_data_1,
  input [63:0] l15_transducer_data_2,
  input [63:0] l15_transducer_data_3,

  output        transducer_l15_val,
  output [4:0]  transducer_l15_rqtype,
  output [3:0]  transducer_l15_amo_op,
  output        transducer_l15_nc,
  output [2:0]  transducer_l15_size,
  output [1:0]  transducer_l15_l1rplway,
  output [39:0] transducer_l15_address,
  output [63:0] transducer_l15_data,
  output [63:0] transducer_l15_data_next_entry,

  output        transducer_l15_req_ack
);

  reg arb_idx = 0; // 0 for icache, 1 for dcache
  reg ongoing_req = 0;

  always @(posedge clk) begin
    if(!ongoing_req) begin
      // no requests ongoing
      if(dcache_transducer_l15_val) begin
        // prioritize dcache request
        arb_idx <= 1;
        ongoing_req <= 1;
      end else if(icache_transducer_l15_val) begin
        arb_idx <= 0;
        ongoing_req <= 1;
      end
    end

    if(l15_transducer_val & ongoing_req) begin
      ongoing_req <= 0;
    end
  end

  assign transducer_l15_val = (arb_idx) ? dcache_transducer_l15_val : icache_transducer_l15_val;
  assign transducer_l15_rqtype = (arb_idx) ? dcache_transducer_l15_rqtype : icache_transducer_l15_rqtype;
  assign transducer_l15_nc = (arb_idx) ? dcache_transducer_l15_nc : icache_transducer_l15_nc;
  assign transducer_l15_size = (arb_idx) ? dcache_transducer_l15_size : icache_transducer_l15_size;
  assign transducer_l15_l1rplway = (arb_idx) ? dcache_transducer_l15_l1rplway : icache_transducer_l15_l1rplway;
  assign transducer_l15_address = (arb_idx) ? dcache_transducer_l15_address : icache_transducer_l15_address;
  assign transducer_l15_req_ack = (arb_idx) ? dcache_transducer_l15_req_ack : icache_transducer_l15_req_ack;
  assign transducer_l15_amo_op = dcache_transducer_l15_amo_op;
  //TODO endianness?
  assign transducer_l15_data = dcache_transducer_l15_data;
  assign transducer_l15_data_next_entry = dcache_transducer_l15_data_next_entry;

  assign icache_l15_transducer_ack = l15_transducer_ack & (arb_idx == 0);
  assign icache_l15_transducer_header_ack = l15_transducer_header_ack & (arb_idx == 0);
  assign icache_l15_transducer_val = l15_transducer_val & (arb_idx == 0);

  assign dcache_l15_transducer_ack = l15_transducer_ack & (arb_idx == 1);
  assign dcache_l15_transducer_header_ack = l15_transducer_header_ack & (arb_idx == 1);
  assign dcache_l15_transducer_val = l15_transducer_val & (arb_idx == 1);

  assign icache_l15_transducer_returntype   = l15_transducer_returntype;
  assign icache_l15_transducer_error        = l15_transducer_error;
  assign icache_l15_transducer_noncacheable = l15_transducer_noncacheable;
  assign icache_l15_transducer_data_0       = l15_transducer_data_0;
  assign icache_l15_transducer_data_1       = l15_transducer_data_1;
  assign icache_l15_transducer_data_2       = l15_transducer_data_2;
  assign icache_l15_transducer_data_3       = l15_transducer_data_3;

  assign dcache_l15_transducer_returntype   = l15_transducer_returntype;
  assign dcache_l15_transducer_error        = l15_transducer_error;
  assign dcache_l15_transducer_noncacheable = l15_transducer_noncacheable;
  assign dcache_l15_transducer_data_0       = l15_transducer_data_0;
  assign dcache_l15_transducer_data_1       = l15_transducer_data_1;
  assign dcache_l15_transducer_data_2       = l15_transducer_data_2;
  assign dcache_l15_transducer_data_3       = l15_transducer_data_3;

endmodule
