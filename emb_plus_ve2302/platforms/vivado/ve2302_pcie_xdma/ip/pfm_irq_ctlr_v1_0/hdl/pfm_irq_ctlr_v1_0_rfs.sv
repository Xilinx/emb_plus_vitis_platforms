// Copyright (C) 2023 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT

interface pfm_irq_ctlr_v1_0_0_axi_if #(
  parameter int C_DATA_WIDTH = 32,
  parameter int C_ADDR_WIDTH = 32
);

// --------------------------------------------------------
// AXI4-Lite Interface Signals
// --------------------------------------------------------

// Write Address Channel
logic [C_ADDR_WIDTH-1:0]      awaddr;
logic                         awvalid;
logic                         awready;

// Write Data Channel
logic [C_DATA_WIDTH-1:0]      wdata;
logic [(C_DATA_WIDTH/8)-1:0]  wstrb;
logic                         wvalid;
logic                         wready;

// Write Response Channel
logic                         bvalid;
logic                         bready;
logic [1:0]                   bresp;

// Read Address Channel
logic [C_ADDR_WIDTH-1:0]      araddr;
logic                         arvalid;
logic                         arready;

// Read Data Channel
logic [C_DATA_WIDTH-1:0]      rdata;
logic [1:0]                   rresp;
logic                         rvalid;
logic                         rready;

// --------------------------------------------------------
// AXI4-Lite Manager Interface
// --------------------------------------------------------
modport man (
  output awaddr,
  output awvalid,
  input  awready,
  output wdata,
  output wstrb,
  output wvalid,
  input  wready,
  input  bvalid,
  input  bresp,
  output bready,
  output araddr,
  output arvalid,
  input  arready,
  input  rdata,
  input  rresp,
  input  rvalid,
  output rready
);

// --------------------------------------------------------
// AXI4-Lite Subordinate Interface
// --------------------------------------------------------
modport sub (
  input  awaddr,
  input  awvalid,
  output awready,
  input  wdata,
  input  wstrb,
  input  wvalid,
  output wready,
  output bvalid,
  output bresp,
  input  bready,
  input  araddr,
  input  arvalid,
  output arready,
  output rdata,
  output rresp,
  output rvalid,
  input  rready
);

// --------------------------------------------------------
// AXI4-Lite Monitor Interface
// --------------------------------------------------------
modport mon (
  input awaddr,
  input awvalid,
  input awready,
  input wdata,
  input wstrb,
  input wvalid,
  input wready,
  input bvalid,
  input bresp,
  input bready,
  input araddr,
  input arvalid,
  input arready,
  input rdata,
  input rresp,
  input rvalid,
  input rready
);

endinterface : pfm_irq_ctlr_v1_0_0_axi_if

// (c) Copyright 2022, Advanced Micro Devices, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////

interface pfm_irq_ctlr_v1_0_0_reg_if #(
  parameter int C_DATA_WIDTH = 32,
  parameter int C_ADDR_WIDTH = 32
);

// --------------------------------------------------------
// Register Read Interface
// --------------------------------------------------------

logic                         reg_rd_valid;
logic [C_ADDR_WIDTH-1:0]      reg_rd_addr;
logic                         reg_rd_done;
logic [1:0]                   reg_rd_resp;
logic [C_DATA_WIDTH-1:0]      reg_rd_data;

// --------------------------------------------------------
// Register Write Interface
// --------------------------------------------------------

logic                         reg_wr_valid;
logic [C_ADDR_WIDTH-1:0]      reg_wr_addr;
logic [(C_DATA_WIDTH/8)-1:0]  reg_wr_be;
logic [C_DATA_WIDTH-1:0]      reg_wr_data;
logic                         reg_wr_done;
logic [1:0]                   reg_wr_resp;

// --------------------------------------------------------
// Register Manager Interface
// --------------------------------------------------------
modport man (
  output reg_rd_valid,
  output reg_rd_addr,
  input  reg_rd_done,
  input  reg_rd_resp,
  input  reg_rd_data,
  output reg_wr_valid,
  output reg_wr_addr,
  output reg_wr_be,
  output reg_wr_data,
  input  reg_wr_done,
  input  reg_wr_resp
);

// --------------------------------------------------------
// Register Subordinate Interface
// --------------------------------------------------------
modport sub (
  input  reg_rd_valid,
  input  reg_rd_addr,
  output reg_rd_done,
  output reg_rd_resp,
  output reg_rd_data,
  input  reg_wr_valid,
  input  reg_wr_addr,
  input  reg_wr_be,
  input  reg_wr_data,
  output reg_wr_done,
  output reg_wr_resp
);

endinterface : pfm_irq_ctlr_v1_0_0_reg_if

// (c) Copyright 2022, Advanced Micro Devices, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////

module pfm_irq_ctlr_v1_0_0_axi_reg #(
  parameter int C_DATA_WIDTH       = 32,  // Data width
  parameter int C_ADDR_WIDTH       = 32   // Address width
) (
  // AXI4-Lite Subordinate Interface
  pfm_irq_ctlr_v1_0_0_axi_if.sub          axi_if,

  // Clock/Reset
  input  logic                          clk,
  input  logic                          resetn,

  // Register Read Interface
  output logic                          reg_rd_valid_o,
  output logic [C_ADDR_WIDTH-1:0]       reg_rd_addr_o,
  input  logic                          reg_rd_done_i,
  input  logic [1:0]                    reg_rd_resp_i,
  input  logic [C_DATA_WIDTH-1:0]       reg_rd_data_i,

  // Register Write Interface
  output logic                          reg_wr_valid_o,
  output logic [C_ADDR_WIDTH-1:0]       reg_wr_addr_o,
  output logic [(C_DATA_WIDTH/8)-1:0]   reg_wr_be_o,
  output logic [C_DATA_WIDTH-1:0]       reg_wr_data_o,
  input  logic                          reg_wr_done_i,
  input  logic [1:0]                    reg_wr_resp_i
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// Parameters
// --------------------------------------------------------

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
logic wr_rdy  = '0;
logic wr_wait = '0;
logic rd_wait = '0;

// ========================================================

// AXI Write
always_ff @(posedge clk) begin
  if (!resetn) begin
    wr_rdy         <= '0;
    wr_wait        <= '0;
    reg_wr_valid_o <= '0;
    reg_wr_addr_o  <= '0;
    reg_wr_be_o    <= '0;
    reg_wr_data_o  <= '0;
    axi_if.bvalid  <= '0;
    axi_if.bresp   <= '0;
  end else begin
    // Defaults
    wr_rdy         <= '0;
    wr_wait        <= wr_wait;
    reg_wr_valid_o <= '0;
    reg_wr_addr_o  <= reg_wr_addr_o;
    reg_wr_be_o    <= reg_wr_be_o;
    reg_wr_data_o  <= reg_wr_data_o;
    axi_if.bvalid  <= '0;
    axi_if.bresp   <= '0;

    if (!wr_wait && !wr_rdy && axi_if.awvalid && axi_if.wvalid) begin
      wr_rdy         <= 1'b1;
      wr_wait        <= 1'b1;
      reg_wr_valid_o <= 1'b1;
      reg_wr_addr_o  <= axi_if.awaddr;
      reg_wr_be_o    <= axi_if.wstrb;
      reg_wr_data_o  <= axi_if.wdata;
    end else if (|reg_wr_done_i) begin
      axi_if.bvalid  <= 1'b1;
      axi_if.bresp   <= reg_wr_resp_i;
      reg_wr_addr_o  <= '0;
      reg_wr_be_o    <= '0;
      reg_wr_data_o  <= '0;
    end else if (axi_if.bvalid) begin
      if (!axi_if.bready) begin
        axi_if.bvalid <= axi_if.bvalid;
        axi_if.bresp  <= axi_if.bresp;
      end else begin
        wr_wait       <= 1'b0;
      end
    end
  end
end
assign axi_if.awready = wr_rdy;
assign axi_if.wready  = wr_rdy;

// AXI Read
always_ff @(posedge clk) begin
  if (!resetn) begin
    axi_if.arready  <= '0;
    rd_wait         <= '0;
    reg_rd_valid_o  <= '0;
    reg_rd_addr_o   <= '0;
    axi_if.rvalid   <= '0;
    axi_if.rresp    <= '0;
    axi_if.rdata    <= '0;
  end else begin
    // Defaults
    axi_if.arready  <= '0;
    rd_wait         <= rd_wait;
    reg_rd_valid_o  <= '0;
    reg_rd_addr_o   <= '0;
    axi_if.rvalid   <= '0;
    axi_if.rresp    <= '0;
    axi_if.rdata    <= '0;
    if (!rd_wait && !axi_if.arready && axi_if.arvalid) begin
      axi_if.arready  <= 1'b1;
      rd_wait         <= 1'b1;
      reg_rd_valid_o  <= 1'b1;
      reg_rd_addr_o   <= axi_if.araddr;
    end else if (|reg_rd_done_i) begin
      axi_if.rvalid   <= 1'b1;
      axi_if.rresp    <= reg_rd_resp_i;
      axi_if.rdata    <= reg_rd_data_i;
    end else if (axi_if.rvalid) begin
      if (!axi_if.rready) begin
        axi_if.rvalid  <= axi_if.rvalid;
        axi_if.rresp   <= axi_if.rresp;
        axi_if.rdata   <= axi_if.rdata;
      end else begin
        rd_wait        <= 1'b0;
      end
    end
  end
end

endmodule : pfm_irq_ctlr_v1_0_0_axi_reg

// (c) Copyright 2022, Advanced Micro Devices, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////

module pfm_irq_ctlr_v1_0_0_axi #(
  parameter int C_ADDR_WIDTH   = 32,  // Address width of AXI and Reg interfaces
  parameter int C_DATA_WIDTH   = 32   // Data width of AXI and Reg interfaces
) (
  // AXI4-Lite Subordinate and Register Space Manager Interfaces
  pfm_irq_ctlr_v1_0_0_axi_if.sub                           axi_if,
  pfm_irq_ctlr_v1_0_0_reg_if.man                           reg_if,

  // Clock/Reset
  input  logic                                           clk,
  input  logic                                           resetn
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// Parameters
// --------------------------------------------------------

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------

logic                             reg_rd_valid;
logic [C_ADDR_WIDTH-1:0]          reg_rd_addr;
logic                             reg_rd_done;
logic [1:0]                       reg_rd_resp;
logic [C_DATA_WIDTH-1:0]          reg_rd_data;
logic                             reg_wr_valid;
logic [C_ADDR_WIDTH-1:0]          reg_wr_addr;
logic [(C_DATA_WIDTH/8)-1:0]      reg_wr_be;
logic [C_DATA_WIDTH-1:0]          reg_wr_data;
logic                             reg_wr_done;
logic [1:0]                       reg_wr_resp;

// ========================================================

// --------------------------------------------------------
// AXI Register Interface Module Instantiation

pfm_irq_ctlr_v1_0_0_axi_reg #(
  .C_ADDR_WIDTH(C_ADDR_WIDTH),
  .C_DATA_WIDTH(C_DATA_WIDTH)
) axi_reg_inst (
  .axi_if(axi_if),
  .clk(clk),
  .resetn(resetn),
  .reg_rd_valid_o(reg_rd_valid),
  .reg_rd_addr_o(reg_rd_addr),
  .reg_rd_done_i(reg_rd_done),
  .reg_rd_resp_i(reg_rd_resp),
  .reg_rd_data_i(reg_rd_data),
  .reg_wr_valid_o(reg_wr_valid),
  .reg_wr_addr_o(reg_wr_addr),
  .reg_wr_be_o(reg_wr_be),
  .reg_wr_data_o(reg_wr_data),
  .reg_wr_done_i(reg_wr_done),
  .reg_wr_resp_i(reg_wr_resp)
);

// --------------------------------------------------------
// Register Interface assignments

assign reg_if.reg_rd_valid      = reg_rd_valid;
assign reg_if.reg_rd_addr       = reg_rd_addr;
assign reg_rd_done              = reg_if.reg_rd_done;
assign reg_rd_resp              = reg_if.reg_rd_resp;
assign reg_rd_data              = reg_if.reg_rd_data;

assign reg_if.reg_wr_valid      = reg_wr_valid;
assign reg_if.reg_wr_addr       = reg_wr_addr;
assign reg_if.reg_wr_be         = reg_wr_be;
assign reg_if.reg_wr_data       = reg_wr_data;
assign reg_wr_done              = reg_if.reg_wr_done;
assign reg_wr_resp              = reg_if.reg_wr_resp;


endmodule : pfm_irq_ctlr_v1_0_0_axi

// (c) Copyright 2022, Advanced Micro Devices, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////

module pfm_irq_ctlr_v1_0_0_irq_ctlr #(
  parameter integer                     C_MAX_PF_LENGTH   = 32,
  parameter integer                     C_NUM_OF_PFS      = 4,     // C_NUM_OF_PFS = {1,...,4}
  parameter integer                     C_NUM_OF_IRQ_PF0  = 32,    // C_NUM_OF_IRQ_PF0 = {1,...,32}
  parameter integer                     C_NUM_OF_IRQ_PF1  = 32,    // C_NUM_OF_IRQ_PF1 = {0,...,32}
  parameter integer                     C_NUM_OF_IRQ_PF2  = 32,    // C_NUM_OF_IRQ_PF2 = {0,...,32}
  parameter integer                     C_NUM_OF_IRQ_PF3  = 32,    // C_NUM_OF_IRQ_PF3 = {0,...,32}
  parameter integer                     C_CPM_TYPE        = 1,     // CPM4(0) or CPM5(1)
  parameter logic [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF0 = 'b0,   // Edge trigger for interrupts of PF0 - either rising (0) or falling (1)
  parameter logic [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF1 = 'b0,   // Edge trigger for interrupts of PF1 - either rising (0) or falling (1)
  parameter logic [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF2 = 'b0,   // Edge trigger for interrupts of PF2 - either rising (0) or falling (1)
  parameter logic [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF3 = 'b0    // Edge trigger for interrupts of PF3 - either rising (0) or falling (1)
)(
  input                                                 clk,
  input                                                 resetn,
  input  logic [C_NUM_OF_IRQ_PF0-1:0]                   irq_in_0,
  input  logic [C_NUM_OF_IRQ_PF1-1:0]                   irq_in_1,
  input  logic [C_NUM_OF_IRQ_PF2-1:0]                   irq_in_2,
  input  logic [C_NUM_OF_IRQ_PF3-1:0]                   irq_in_3,
  output logic                                          irq_vld,
  output logic [4:0]                                    irq_vec,
  output logic [((C_CPM_TYPE==1) ? 12 : 7):0]           irq_fnc,         // CPM5 has 13 bits, CPM4 has 8 bits length of MSI-X message function
  input                                                 irq_ack,
  input                                                 irq_fail,
  input  logic [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] irq_req_stim,
  output logic [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] irq_pend         // pending interrupts noted for read registers on the register space
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// Parameters
// --------------------------------------------------------
// localparam [C_NUM_OF_PFS*C_MAX_PF_LENGTH-1:0]       PF_WIDTH     = {C_NUM_OF_IRQ_PF3[C_MAX_PF_LENGTH-1:0], C_NUM_OF_IRQ_PF2[C_MAX_PF_LENGTH-1:0], C_NUM_OF_IRQ_PF1[C_MAX_PF_LENGTH-1:0], C_NUM_OF_IRQ_PF0[C_MAX_PF_LENGTH-1:0]};
localparam [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] EDGE_SELECT  = {C_EDGE_SELECT_PF3, C_EDGE_SELECT_PF2, C_EDGE_SELECT_PF1, C_EDGE_SELECT_PF0};
localparam [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] PF_WIDTH     = {C_NUM_OF_IRQ_PF0, C_NUM_OF_IRQ_PF1, C_NUM_OF_IRQ_PF2, C_NUM_OF_IRQ_PF3};

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
logic [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] irq_in_cdc;       // defined as fixed sized CDC output signal for the input interrupts
logic [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] irq_in_int;       // defined as fixed sized internal interrupt that can copy varying sizes of input interrupts
logic [C_NUM_OF_PFS-1:0] [5:0]                 msg_num;          // defined as 1 valid bit MSB, 5 MSI-X vector bits - array defined by the number of PFs
logic [$clog2(C_NUM_OF_PFS)-1:0]               srv_que;
logic [C_NUM_OF_PFS-1:0]                       srv_req;
logic [C_NUM_OF_PFS-1:0]                       srv_done;
logic [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] irq_req_stim_i;

// Input interrupts are assigned to fixed sized internal logic to easily modify generate-for for CDC and PF Handler modules
assign irq_in_int[0] = irq_in_0;
assign irq_in_int[1] = irq_in_1;
assign irq_in_int[2] = irq_in_2;
assign irq_in_int[3] = irq_in_3;

assign irq_req_stim_i = irq_req_stim;

// Setting the MSI-X message parallel to the PF Interrupt Handlers
assign irq_vld = msg_num[srv_que][5];
assign irq_vec = msg_num[srv_que][4:0];
assign irq_fnc = ((msg_num[srv_que][5]) ? srv_que : 'b0);

// Generate-for loop creates CDC and PF Handler modules only for limited number of PFs by the user parameter
generate
  for (genvar mn = 0; mn < C_NUM_OF_PFS; mn++) begin : pf_irq_hndlr
    xpm_cdc_array_single #(
      .DEST_SYNC_FF   (3),                                        // integer; range: 2-10
      .SIM_ASSERT_CHK (0),                                        // integer; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG  (0),                                        // integer; 0=do not register input, 1=register input
      .WIDTH          (PF_WIDTH[mn])   // integer; range: 1-1024
    ) xpm_cdc_array_single_inst (
      .src_clk  (1'b0),
      .src_in   (irq_in_int[mn]),
      .dest_clk (clk),
      .dest_out (irq_in_cdc[mn])
    );
    pfm_irq_ctlr_v1_0_0_pf_irq_hnd #(
      .C_MAX_PF_LENGTH(C_MAX_PF_LENGTH),
      .C_NUM_OF_IRQ_PFN (PF_WIDTH[mn]),
      .C_EDGE_SELECT(EDGE_SELECT[mn])
    ) pf_irq_hnd_inst (
      .clk         (clk),
      .resetn      (resetn),
      .irq_in      (irq_in_cdc[mn]),
      .irq_ack     (irq_ack),
      .irq_fail    (irq_fail),
      .srv_req     (srv_req[mn]),
      .srv_done    (srv_done[mn]),
      .msg_num     (msg_num[mn]),
      .irq_req_stim(irq_req_stim_i[mn]),
      .irq_pend    (irq_pend[mn])
    );
  end
endgenerate

// PF Interrupt Handlers move on by order. Each designates MSI-X messages and receives acknowledges for interrupts
always_ff @(posedge clk) begin
  if(!resetn) begin
    srv_que    <= 'b0;
    srv_req    <= 'b0;
  end else begin
    // srv_req is an array with each index indicating a PF, which initiates PF specific scheduler
    srv_req[srv_que] <= 1'b1;
    // srv_done is a clock cycle pulse indicating the end of the scheduler cycle
    if (srv_done[srv_que] == 1'b1) begin
      srv_req <= 'b0;
      if (srv_que == C_NUM_OF_PFS - 1) srv_que <= 'b0;
      else srv_que <= srv_que + 1;
    end
  end
end

endmodule : pfm_irq_ctlr_v1_0_0_irq_ctlr

// (c) Copyright 2022, Advanced Micro Devices, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////

module pfm_irq_ctlr_v1_0_0_pf_irq_hnd #(
  parameter integer                     C_MAX_PF_LENGTH  = 32,
  parameter integer                     C_NUM_OF_IRQ_PFN = 32,
  parameter logic [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT    = 'b0
)(
  input  logic                             clk,
  input  logic                             resetn,
  input  logic [C_NUM_OF_IRQ_PFN-1:0]      irq_in,
  input  logic                             irq_ack,
  input  logic                             irq_fail,
  input  logic                             srv_req,
  output logic                             srv_done,
  output logic [5:0]                       msg_num,
  input  logic [C_MAX_PF_LENGTH-1:0]       irq_req_stim,
  output logic [C_NUM_OF_IRQ_PFN-1:0]      irq_pend
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// Parameters
// --------------------------------------------------------

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
logic [$clog2(C_NUM_OF_IRQ_PFN):0]    sort_cnt;
logic [C_NUM_OF_IRQ_PFN-1:0]          irq_in_d;
logic [C_NUM_OF_IRQ_PFN-1:0]          irq_req;
logic                                 srv_req_d;
logic [1:0]                           state;

assign irq_pend = irq_req;

always_ff @(posedge clk) begin
  if(!resetn) begin
    irq_req         <= {C_NUM_OF_IRQ_PFN{1'b0}};
    irq_in_d        <= {C_NUM_OF_IRQ_PFN{1'b0}};
    sort_cnt        <= C_NUM_OF_IRQ_PFN;
    msg_num         <= 5'b0;
    state           <= 2'b00;
    srv_done        <= 1'b0;
    srv_req_d       <= 1'b0;
  end else begin
    irq_in_d <= irq_in;
    for (integer i = 0; i < C_NUM_OF_IRQ_PFN; i++) begin
      if (C_EDGE_SELECT[i]) begin
        // detects the falling edge on incoming interrupts all in parallel and notes as request
        if (!irq_in[i] & irq_in_d[i]) irq_req[i] <= 1'b1;
      end else begin
        // detects the rising edge on incoming interrupts all in parallel and notes as request
        if (irq_in[i] & !irq_in_d[i]) irq_req[i] <= 1'b1;
      end
      if (irq_req_stim[i]) irq_req[i] <= 1'b1;
    end

    srv_done     <= 1'b0;
    srv_req_d    <= srv_req;
    case (state)
      2'b00: begin
        if ((srv_req_d == 1'b0) & (srv_req == 1'b1)) state <= 2'b01;
      end
      2'b01: begin
        msg_num <= 5'b0;
        for (integer i = 0; i < C_NUM_OF_IRQ_PFN; i++) begin : pf_irq
          // if top module allows round robin scheduler work -
          // logic below notes which interrupt is going to be
          // prioritized for this specific PF
          if ((irq_req[i] == 1'b1) & (i < sort_cnt)) begin
            msg_num[4:0]     <= i;           // respective interrupt index, along with valid
            msg_num[5]       <= 1'b1;
            sort_cnt         <= sort_cnt - 1;
          end
        end
        state      <= 2'b10;
      end
      2'b10: begin
        if (msg_num == 5'b0) begin
          srv_done     <= 1'b1;
          sort_cnt     <= C_NUM_OF_IRQ_PFN;
          state        <= 2'b00;
        end

        if (irq_ack || irq_fail) begin
          msg_num               <= 5'b0;
          irq_req[msg_num[4:0]] <= 1'b0;
          state                 <= 2'b01;
          if (~|sort_cnt) begin
            srv_done     <= 1'b1;
            sort_cnt     <= C_NUM_OF_IRQ_PFN;
            state        <= 2'b00;
          end
        end
      end

      default : begin
        msg_num           <= 5'b0;
        srv_done          <= 1'b0;
        sort_cnt          <= C_NUM_OF_IRQ_PFN;
        state             <= 2'b00;
      end
    endcase
  end
end

endmodule : pfm_irq_ctlr_v1_0_0_pf_irq_hnd

// (c) Copyright 2022, Advanced Micro Devices, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////

module pfm_irq_ctlr_v1_0_0_regs #(
  parameter integer C_NUM_OF_PFS    = 4,   // C_NUM_OF_PFS = {1,...,4}
  parameter integer C_MAX_PF_LENGTH = 32,
  parameter integer C_CPM_TYPE      = 1
)(
  // Register Interface
  pfm_irq_ctlr_v1_0_0_reg_if.sub                          reg_if,

  // Clock/Reset
  input  logic                                          clk,
  input  logic                                          resetn,

  // Interrupt Related Connections
  input  logic                                          irq_ack,
  input  logic                                          irq_fail,
  output logic [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] irq_req_stim,
  input  logic [((C_CPM_TYPE==1) ? 12 : 7):0]           irq_fnc,
  input  logic [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] irq_pend
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// Parameters
// --------------------------------------------------------

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
logic [C_NUM_OF_PFS-1:0] irq_fail_cnt_clr;                  // Clear bit asserted upon the arrival of W1C on IRQ Fail Counter
logic [C_NUM_OF_PFS-1:0] [15:0] irq_fail_cnt;               // Failure counter to be incremented upon arriving of failure signal from CPM
logic irq_fail_d;
logic [C_NUM_OF_PFS-1:0] irq_ack_cnt_clr;                   // Clear bit asserted upon the arrival of W1C on IRQ Ack Counter
logic [C_NUM_OF_PFS-1:0] [15:0] irq_ack_cnt;                // Acknowledge counter to be incremented upon arriving of acknowledge signal from CPM
logic irq_ack_d;
logic [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] irq_req_stim_o;

assign irq_req_stim = irq_req_stim_o;
// ========================================================

// Interupt Failure Counter
always_ff @(posedge clk) begin
  if (!resetn) begin
    irq_fail_cnt  <= '0;
    irq_fail_d    <= '0;
  end else begin
    irq_fail_d <= irq_fail;
    if (irq_fail & !irq_fail_d) irq_fail_cnt[irq_fnc] <= irq_fail_cnt[irq_fnc] + 1;
    if (irq_fail_cnt_clr[0])    irq_fail_cnt[0]       <= '0;
    if (irq_fail_cnt_clr[1])    irq_fail_cnt[1]       <= '0;
    if (irq_fail_cnt_clr[2])    irq_fail_cnt[2]       <= '0;
    if (irq_fail_cnt_clr[3])    irq_fail_cnt[3]       <= '0;
  end
end

// ========================================================

// Interupt Acknowledge Counter
always_ff @(posedge clk) begin
  if (!resetn) begin
    irq_ack_cnt  <= '0;
    irq_ack_d    <= '0;
  end else begin
    irq_ack_d <= irq_ack;
    if (irq_ack & !irq_ack_d) irq_ack_cnt[irq_fnc] <= irq_ack_cnt[irq_fnc] + 1;
    if (irq_ack_cnt_clr[0])    irq_ack_cnt[0]      <= '0;
    if (irq_ack_cnt_clr[1])    irq_ack_cnt[1]      <= '0;
    if (irq_ack_cnt_clr[2])    irq_ack_cnt[2]      <= '0;
    if (irq_ack_cnt_clr[3])    irq_ack_cnt[3]      <= '0;
  end
end

// ========================================================

// Register Space - Write
always_ff @(posedge clk) begin
  if (!resetn) begin
    reg_if.reg_wr_done <= '0;
    irq_fail_cnt_clr   <= 'b0;
    irq_ack_cnt_clr    <= 'b0;
    irq_req_stim_o     <= 'b0;
  end else begin
    // Defaults
    reg_if.reg_wr_done <= '0;
    irq_fail_cnt_clr   <= 'b0;
    irq_ack_cnt_clr    <= 'b0;
    irq_req_stim_o     <= 'b0;
    if (reg_if.reg_wr_valid) begin
        case (reg_if.reg_wr_addr[9:0]) inside
          10'b0100000000: // IRQ_FAIL_CNT_PF0 W1C
            if (reg_if.reg_wr_data == 'b1) irq_fail_cnt_clr[0] <= 'b1;
          10'b0100000100: // IRQ_FAIL_CNT_PF1 W1C
            if (reg_if.reg_wr_data == 'b1) irq_fail_cnt_clr[1] <= 'b1;
          10'b0100001000: // IRQ_FAIL_CNT_PF2 W1C
            if (reg_if.reg_wr_data == 'b1) irq_fail_cnt_clr[2] <= 'b1;
          10'b0100001100: // IRQ_FAIL_CNT_PF3 W1C
            if (reg_if.reg_wr_data == 'b1) irq_fail_cnt_clr[3] <= 'b1;
          10'b1000000000: // IRQ_ACK_CNT_PF0 W1C
            if (reg_if.reg_wr_data == 'b1) irq_ack_cnt_clr[0] <= 'b1;
          10'b1000000100: // IRQ_ACK_CNT_PF1 W1C
            if (reg_if.reg_wr_data == 'b1) irq_ack_cnt_clr[1] <= 'b1;
          10'b1000001000: // IRQ_ACK_CNT_PF2 W1C
            if (reg_if.reg_wr_data == 'b1) irq_ack_cnt_clr[2] <= 'b1;
          10'b1000001100: // IRQ_ACK_CNT_PF3 W1C
            if (reg_if.reg_wr_data == 'b1) irq_ack_cnt_clr[3] <= 'b1;
          10'b1100000000: // IRQ_STIM_PF0 WO
            irq_req_stim_o[0] <= reg_if.reg_wr_data;
          10'b1100000100: // IRQ_STIM_PF1 WO
            irq_req_stim_o[1] <= reg_if.reg_wr_data;
          10'b1100001000: // IRQ_STIM_PF2 WO
            irq_req_stim_o[2] <= reg_if.reg_wr_data;
          10'b1100001100: // IRQ_STIM_PF3 WO
            irq_req_stim_o[3] <= reg_if.reg_wr_data;
          default: begin
            irq_fail_cnt_clr <= 'b0;
            irq_ack_cnt_clr  <= 'b0;
            irq_req_stim_o   <= 'b0;
          end
        endcase
      // Signal write done
      reg_if.reg_wr_done <= 1'b1;
    end
  end
end

// Always respond with OKAY to writes
assign reg_if.reg_wr_resp = '0;

// ========================================================

// Register Space - Read
always_ff @(posedge clk) begin
  //Defaults
  reg_if.reg_rd_data <= '0;
  reg_if.reg_rd_done <= '0;

  if (reg_if.reg_rd_valid) begin
    case (reg_if.reg_rd_addr[9:0]) inside
      10'b0000000000: // IRQ_PF0_STATUS
        reg_if.reg_rd_data           <= irq_pend[0];
      10'b0000000100: // IRQ_PF1_STATUS
        reg_if.reg_rd_data           <= irq_pend[1];
      10'b0000001000: // IRQ_PF2_STATUS
        reg_if.reg_rd_data           <= irq_pend[2];
      10'b0000001100: // IRQ_PF3_STATUS
        reg_if.reg_rd_data           <= irq_pend[3];
      10'b0100000000: // IRQ_FAIL_CNT_PF0
        reg_if.reg_rd_data           <= irq_fail_cnt[0];
      10'b0100000100: // IRQ_FAIL_CNT_PF1
        reg_if.reg_rd_data           <= irq_fail_cnt[1];
      10'b0100001000: // IRQ_FAIL_CNT_PF2
        reg_if.reg_rd_data           <= irq_fail_cnt[2];
      10'b0100001100: // IRQ_FAIL_CNT_PF3
        reg_if.reg_rd_data           <= irq_fail_cnt[3];
      10'b1000000000: // IRQ_ACK_CNT_PF0
        reg_if.reg_rd_data           <= irq_ack_cnt[0];
      10'b1000000100: // IRQ_ACK_CNT_PF1
        reg_if.reg_rd_data           <= irq_ack_cnt[1];
      10'b1000001000: // IRQ_ACK_CNT_PF2
        reg_if.reg_rd_data           <= irq_ack_cnt[2];
      10'b1000001100: // IRQ_ACK_CNT_PF3
        reg_if.reg_rd_data           <= irq_ack_cnt[3];
      default:
        reg_if.reg_rd_data           <= '0;
    endcase
    // Signal read done
    reg_if.reg_rd_done <= 1'b1;
  end
end

// Always respond with OKAY to reads
assign reg_if.reg_rd_resp = '0;

// ========================================================

endmodule : pfm_irq_ctlr_v1_0_0_regs

// (c) Copyright 2022, Advanced Micro Devices, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////

module pfm_irq_ctlr_v1_0_0_top #(
	parameter integer                     C_MAX_PF_LENGTH   = 32,
	parameter integer                     C_ADDR_WIDTH      = 10,
	parameter integer                     C_NUM_OF_PFS      = 4,
	parameter integer                     C_NUM_OF_IRQ_PF0  = 32,
	parameter integer                     C_NUM_OF_IRQ_PF1  = 32,
	parameter integer                     C_NUM_OF_IRQ_PF2  = 32,
	parameter integer                     C_NUM_OF_IRQ_PF3  = 32,
	parameter integer                     C_CPM_TYPE        = 1,
	parameter integer                     C_AXI_CTRL_EN     = 1,
  parameter logic [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF0 = 'b0,
  parameter logic [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF1 = 'b0,
  parameter logic [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF2 = 'b0,
  parameter logic [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF3 = 'b0
) (
  // Clock Ports
  input  logic                                  clk,

  // Reset Ports
  input  logic                                  resetn,

  // AXI Interface Ports
  input  logic [C_ADDR_WIDTH-1:0]               axi_awaddr,
  input  logic                                  axi_awvalid,
  output logic                                  axi_awready,
  input  logic [32-1:0]                         axi_wdata,
  input  logic [4-1:0]                          axi_wstrb,
  input  logic                                  axi_wvalid,
  output logic                                  axi_wready,
  output logic [2-1:0]                          axi_bresp,
  output logic                                  axi_bvalid,
  input  logic                                  axi_bready,
  input  logic [C_ADDR_WIDTH-1:0]               axi_araddr,
  input  logic                                  axi_arvalid,
  output logic                                  axi_arready,
  output logic [32-1:0]                         axi_rdata,
  output logic [2-1:0]                          axi_rresp,
  output logic                                  axi_rvalid,
  input  logic                                  axi_rready,

  // Interrupt Ports
  input  logic [C_NUM_OF_IRQ_PF0-1:0]           irq_in_0,
  input  logic [C_NUM_OF_IRQ_PF1-1:0]           irq_in_1,
  input  logic [C_NUM_OF_IRQ_PF2-1:0]           irq_in_2,
  input  logic [C_NUM_OF_IRQ_PF3-1:0]           irq_in_3,
  input  logic                                  irq_ack,
  input  logic                                  irq_fail,
  output logic                                  irq_vld,
  output logic [4:0]                            irq_vec,
  output logic [((C_CPM_TYPE==1) ? 12 : 7):0]   irq_fnc
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// Parameters
// --------------------------------------------------------

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
logic [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] irq_pend;     // pending interrupts noted for read registers on the register space
logic [C_NUM_OF_PFS-1:0] [C_MAX_PF_LENGTH-1:0] irq_req_stim; // stimulus signal for interrupts received from register space
logic [((C_CPM_TYPE==1) ? 12 : 7):0]           irq_fnc_o;    // selected PF index

assign irq_fnc = irq_fnc_o;
// ========================================================

// AXI4-Lite Interface Instantiation
pfm_irq_ctlr_v1_0_0_axi_if #(.C_ADDR_WIDTH(C_ADDR_WIDTH)) axi_if();

// AXI-Lite Interface/port connections
assign axi_if.awaddr      = axi_awaddr;
assign axi_if.awvalid     = axi_awvalid;
assign axi_awready        = axi_if.awready;
assign axi_if.wdata       = axi_wdata;
assign axi_if.wstrb       = axi_wstrb;
assign axi_if.wvalid      = axi_wvalid;
assign axi_wready         = axi_if.wready;
assign axi_bresp          = axi_if.bresp;
assign axi_bvalid         = axi_if.bvalid;
assign axi_if.bready      = axi_bready;
assign axi_if.araddr      = axi_araddr;
assign axi_if.arvalid     = axi_arvalid;
assign axi_arready        = axi_if.arready;
assign axi_rdata          = axi_if.rdata;
assign axi_rresp          = axi_if.rresp;
assign axi_rvalid         = axi_if.rvalid;
assign axi_if.rready      = axi_rready;

// ========================================================

// Register Interface Instantiation
pfm_irq_ctlr_v1_0_0_reg_if #(.C_ADDR_WIDTH(C_ADDR_WIDTH)) reg_if();

// ========================================================

generate
  if (C_AXI_CTRL_EN) begin : axi_blk

    // AXI Module Instantiation
    pfm_irq_ctlr_v1_0_0_axi #(
      .C_ADDR_WIDTH(C_ADDR_WIDTH)
    ) axi_inst (
      .axi_if,
      .reg_if,
      .clk,
      .resetn
    );

    // ========================================================

    // Platform Interrupt Controller Registers Module Instantiation
    pfm_irq_ctlr_v1_0_0_regs #(
      .C_NUM_OF_PFS(C_NUM_OF_PFS),
      .C_MAX_PF_LENGTH(C_MAX_PF_LENGTH),
      .C_CPM_TYPE(C_CPM_TYPE)
    ) reg_inst (
      .reg_if,
      .clk,
      .resetn,
      .irq_ack,
      .irq_fail,
      .irq_req_stim,
      .irq_fnc(irq_fnc_o),
      .irq_pend
    );

    // ========================================================

  end
endgenerate

// Interrupt Controller Module Instantiation
pfm_irq_ctlr_v1_0_0_irq_ctlr #(
  .C_MAX_PF_LENGTH(C_MAX_PF_LENGTH),
  .C_NUM_OF_PFS(C_NUM_OF_PFS),
  .C_NUM_OF_IRQ_PF0(C_NUM_OF_IRQ_PF0),
  .C_NUM_OF_IRQ_PF1(C_NUM_OF_IRQ_PF1),
  .C_NUM_OF_IRQ_PF2(C_NUM_OF_IRQ_PF2),
  .C_NUM_OF_IRQ_PF3(C_NUM_OF_IRQ_PF3),
  .C_CPM_TYPE(C_CPM_TYPE),
  .C_EDGE_SELECT_PF0(C_EDGE_SELECT_PF0),
  .C_EDGE_SELECT_PF1(C_EDGE_SELECT_PF1),
  .C_EDGE_SELECT_PF2(C_EDGE_SELECT_PF2),
  .C_EDGE_SELECT_PF3(C_EDGE_SELECT_PF3)
) irq_ctlr_inst (
  .clk,
  .resetn,
  .irq_in_0,
  .irq_in_1,
  .irq_in_2,
  .irq_in_3,
  .irq_vld,
  .irq_vec,
  .irq_fnc(irq_fnc_o),
  .irq_ack,
  .irq_fail,
  .irq_req_stim,
  .irq_pend
);

// ========================================================

endmodule : pfm_irq_ctlr_v1_0_0_top

// (c) Copyright 2022, Advanced Micro Devices, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module pfm_irq_ctlr_v1_0_0 #(
  parameter integer               C_MAX_PF_LENGTH   = 32,
	parameter integer               C_ADDR_WIDTH      = 10,
	parameter integer               C_NUM_OF_PFS      = 4,
	parameter integer               C_NUM_OF_IRQ_PF0  = 32,
	parameter integer               C_NUM_OF_IRQ_PF1  = 32,
	parameter integer               C_NUM_OF_IRQ_PF2  = 32,
	parameter integer               C_NUM_OF_IRQ_PF3  = 32,
  parameter [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF0 = 'b0,
  parameter [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF1 = 'b0,
  parameter [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF2 = 'b0,
  parameter [C_MAX_PF_LENGTH-1:0] C_EDGE_SELECT_PF3 = 'b0,
	parameter integer               C_CPM_TYPE        = 1,
	parameter integer               C_AXI_CTRL_EN     = 1
)	(
	// Clock Ports
  input  wire                                 aclk,

  // Reset Ports
  input  wire                                 aresetn,

  // AXI Interface Ports
  input  wire [C_ADDR_WIDTH-1:0]              s_axi_awaddr,
  input  wire                                 s_axi_awvalid,
  output wire                                 s_axi_awready,
  input  wire [31:0]                          s_axi_wdata,
  input  wire [3:0]                           s_axi_wstrb,
  input  wire                                 s_axi_wvalid,
  output wire                                 s_axi_wready,
  output wire [1:0]                           s_axi_bresp,
  output wire                                 s_axi_bvalid,
  input  wire                                 s_axi_bready,
  input  wire [C_ADDR_WIDTH-1:0]              s_axi_araddr,
  input  wire                                 s_axi_arvalid,
  output wire                                 s_axi_arready,
  output wire [31:0]                          s_axi_rdata,
  output wire [1:0]                           s_axi_rresp,
  output wire                                 s_axi_rvalid,
  input  wire                                 s_axi_rready,

  // Interrupt Ports
  input wire [C_NUM_OF_IRQ_PF0-1:0]           irq_in_0,
  input wire [C_NUM_OF_IRQ_PF1-1:0]           irq_in_1,
  input wire [C_NUM_OF_IRQ_PF2-1:0]           irq_in_2,
  input wire [C_NUM_OF_IRQ_PF3-1:0]           irq_in_3,
  input wire                                  irq_ack,
  input wire                                  irq_fail,
  output wire                                 irq_vld,
  output wire [4:0]                           irq_vec,
  output wire [((C_CPM_TYPE==1) ? 12 : 7):0]  irq_fnc
);

// --------------------------------------------------------
// PFM IRQ CTLR Top Level Instantiation
// --------------------------------------------------------
pfm_irq_ctlr_v1_0_0_top #(
.C_MAX_PF_LENGTH(C_MAX_PF_LENGTH),
.C_ADDR_WIDTH(C_ADDR_WIDTH),
.C_NUM_OF_PFS(C_NUM_OF_PFS),
.C_NUM_OF_IRQ_PF0(C_NUM_OF_IRQ_PF0),
.C_NUM_OF_IRQ_PF1(C_NUM_OF_IRQ_PF1),
.C_NUM_OF_IRQ_PF2(C_NUM_OF_IRQ_PF2),
.C_NUM_OF_IRQ_PF3(C_NUM_OF_IRQ_PF3),
.C_CPM_TYPE(C_CPM_TYPE),
.C_AXI_CTRL_EN(C_AXI_CTRL_EN),
.C_EDGE_SELECT_PF0(C_EDGE_SELECT_PF0),
.C_EDGE_SELECT_PF1(C_EDGE_SELECT_PF1),
.C_EDGE_SELECT_PF2(C_EDGE_SELECT_PF2),
.C_EDGE_SELECT_PF3(C_EDGE_SELECT_PF3)
) top_inst (
  // Clocks
  .clk(aclk),

  // Resets
  .resetn(aresetn),

  // AXI Interface
  .axi_awaddr(s_axi_awaddr),
  .axi_awvalid(s_axi_awvalid),
  .axi_awready(s_axi_awready),
  .axi_wdata(s_axi_wdata),
  .axi_wstrb(s_axi_wstrb),
  .axi_wvalid(s_axi_wvalid),
  .axi_wready(s_axi_wready),
  .axi_bresp(s_axi_bresp),
  .axi_bvalid(s_axi_bvalid),
  .axi_bready(s_axi_bready),
  .axi_araddr(s_axi_araddr),
  .axi_arvalid(s_axi_arvalid),
  .axi_arready(s_axi_arready),
  .axi_rdata(s_axi_rdata),
  .axi_rresp(s_axi_rresp),
  .axi_rvalid(s_axi_rvalid),
  .axi_rready(s_axi_rready),

  // Interrupt Ports
  .irq_in_0(irq_in_0),
  .irq_in_1(irq_in_1),
  .irq_in_2(irq_in_2),
  .irq_in_3(irq_in_3),
  .irq_ack(irq_ack),
  .irq_fail(irq_fail),
  .irq_vld(irq_vld),
  .irq_vec(irq_vec),
  .irq_fnc(irq_fnc)
);

endmodule

