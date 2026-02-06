// Copyright (C) 2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT

interface cmd_queue_v2_0_0_axi_if #(
  parameter int C_DATA_WIDTH = 32,
  parameter int C_ADDR_WIDTH = 32
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

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

endinterface : cmd_queue_v2_0_0_axi_if


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

interface cmd_queue_v2_0_0_reg_if #(
  parameter int C_DATA_WIDTH = 32,
  parameter int C_ADDR_WIDTH = 32
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

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

endinterface : cmd_queue_v2_0_0_reg_if


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

module cmd_queue_v2_0_0_axi_reg #(
  parameter int C_DATA_WIDTH       = 32,  // Data width
  parameter int C_ADDR_WIDTH       = 32   // Address width
) (
  // AXI4-Lite Subordinate Interface
  cmd_queue_v2_0_0_axi_if.sub             axi_if,

  // Clock/Reset
  input  logic                          aclk,
  input  logic                          aresetn,

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
logic wr_rdy;
logic wr_wait;
logic rd_wait;

// ========================================================

// AXI Write
always_ff @(posedge aclk) begin
  if (!aresetn) begin
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
    // coverage off -item c 1 -feccondrow 4
    if (!wr_wait && !wr_rdy && axi_if.awvalid && axi_if.wvalid) begin
    // coverage on
      wr_rdy         <= 1'b1;
      wr_wait        <= 1'b1;
      reg_wr_valid_o <= 1'b1;
      reg_wr_addr_o  <= axi_if.awaddr;
      reg_wr_be_o    <= axi_if.wstrb;
      reg_wr_data_o  <= axi_if.wdata;
    end else if (reg_wr_done_i) begin
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
always_ff @(posedge aclk) begin
  if (!aresetn) begin
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
    // coverage off -item c 1 -feccondrow 4
    if (!rd_wait && !axi_if.arready && axi_if.arvalid) begin
    // coverage on
      axi_if.arready  <= 1'b1;
      rd_wait         <= 1'b1;
      reg_rd_valid_o  <= 1'b1;
      reg_rd_addr_o   <= axi_if.araddr;
    end else if (reg_rd_done_i) begin
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

endmodule : cmd_queue_v2_0_0_axi_reg


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

module cmd_queue_v2_0_0_axi #(
  parameter int C_S00_ADDR_WIDTH   = 12,  // Address width of SQ AXI and Reg interfaces
  parameter int C_S01_ADDR_WIDTH   = 12,  // Address Width of CQ AXI and Reg interfaces
  parameter int C_S00_DATA_WIDTH   = 32,  // Data width of SQ AXI and Reg interfaces
  parameter int C_S01_DATA_WIDTH   = 32   // Data width of CQ AXI and Reg interfaces
) (
  // AXI4-Lite Subordinate Interface
  cmd_queue_v2_0_0_axi_if.sub         sq_axi_if,
  cmd_queue_v2_0_0_axi_if.sub         cq_axi_if,

  // Manager Register Interfaces
  cmd_queue_v2_0_0_reg_if.man         sq_reg_if,
  cmd_queue_v2_0_0_reg_if.man         cq_reg_if,

  // Clock/Reset
  input  logic                      aclk,
  input  logic                      aresetn
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

logic                             sq_reg_rd_valid;
logic [C_S00_ADDR_WIDTH-1:0]      sq_reg_rd_addr;
logic                             sq_reg_rd_done;
logic [1:0]                       sq_reg_rd_resp;
logic [C_S00_DATA_WIDTH-1:0]      sq_reg_rd_data;
logic                             sq_reg_wr_valid;
logic [C_S00_ADDR_WIDTH-1:0]      sq_reg_wr_addr;
logic [(C_S00_DATA_WIDTH/8)-1:0]  sq_reg_wr_be;
logic [C_S00_DATA_WIDTH-1:0]      sq_reg_wr_data;
logic                             sq_reg_wr_done;
logic [1:0]                       sq_reg_wr_resp;

logic                             cq_reg_rd_valid;
logic [C_S01_ADDR_WIDTH-1:0]      cq_reg_rd_addr;
logic                             cq_reg_rd_done;
logic [1:0]                       cq_reg_rd_resp;
logic [C_S01_DATA_WIDTH-1:0]      cq_reg_rd_data;
logic                             cq_reg_wr_valid;
logic [C_S01_ADDR_WIDTH-1:0]      cq_reg_wr_addr;
logic [(C_S01_DATA_WIDTH/8)-1:0]  cq_reg_wr_be;
logic [C_S01_DATA_WIDTH-1:0]      cq_reg_wr_data;
logic                             cq_reg_wr_done;
logic [1:0]                       cq_reg_wr_resp;

// ========================================================

// --------------------------------------------------------
// SQ AXI Register Interface Module Instantiation

cmd_queue_v2_0_0_axi_reg #(
  .C_ADDR_WIDTH(C_S00_ADDR_WIDTH),
  .C_DATA_WIDTH(C_S00_DATA_WIDTH)
) sq_axi_reg_inst (
  .axi_if(sq_axi_if),
  .aclk,
  .aresetn,
  .reg_rd_valid_o(sq_reg_rd_valid),
  .reg_rd_addr_o(sq_reg_rd_addr),
  .reg_rd_done_i(sq_reg_rd_done),
  .reg_rd_resp_i(sq_reg_rd_resp),
  .reg_rd_data_i(sq_reg_rd_data),
  .reg_wr_valid_o(sq_reg_wr_valid),
  .reg_wr_addr_o(sq_reg_wr_addr),
  .reg_wr_be_o(sq_reg_wr_be),
  .reg_wr_data_o(sq_reg_wr_data),
  .reg_wr_done_i(sq_reg_wr_done),
  .reg_wr_resp_i(sq_reg_wr_resp)
);

// --------------------------------------------------------
// CQ AXI Register Interface Module Instantiation

cmd_queue_v2_0_0_axi_reg #(
  .C_ADDR_WIDTH(C_S01_ADDR_WIDTH),
  .C_DATA_WIDTH(C_S01_DATA_WIDTH)
) cq_axi_reg_inst (
  .axi_if(cq_axi_if),
  .aclk,
  .aresetn,
  .reg_rd_valid_o(cq_reg_rd_valid),
  .reg_rd_addr_o(cq_reg_rd_addr),
  .reg_rd_done_i(cq_reg_rd_done),
  .reg_rd_resp_i(cq_reg_rd_resp),
  .reg_rd_data_i(cq_reg_rd_data),
  .reg_wr_valid_o(cq_reg_wr_valid),
  .reg_wr_addr_o(cq_reg_wr_addr),
  .reg_wr_be_o(cq_reg_wr_be),
  .reg_wr_data_o(cq_reg_wr_data),
  .reg_wr_done_i(cq_reg_wr_done),
  .reg_wr_resp_i(cq_reg_wr_resp)
);

// --------------------------------------------------------
// Register Interface assignments

// SQ Register Interface
assign sq_reg_if.reg_rd_valid   = sq_reg_rd_valid;
assign sq_reg_if.reg_rd_addr    = sq_reg_rd_addr;
assign sq_reg_rd_done           = sq_reg_if.reg_rd_done;
assign sq_reg_rd_resp           = sq_reg_if.reg_rd_resp;
assign sq_reg_rd_data           = sq_reg_if.reg_rd_data;

assign sq_reg_if.reg_wr_valid   = sq_reg_wr_valid;
assign sq_reg_if.reg_wr_addr    = sq_reg_wr_addr;
assign sq_reg_if.reg_wr_be      = sq_reg_wr_be;
assign sq_reg_if.reg_wr_data    = sq_reg_wr_data;
assign sq_reg_wr_done           = sq_reg_if.reg_wr_done;
assign sq_reg_wr_resp           = sq_reg_if.reg_wr_resp;

// CQ Register Interface
assign cq_reg_if.reg_rd_valid   = cq_reg_rd_valid;
assign cq_reg_if.reg_rd_addr    = cq_reg_rd_addr;
assign cq_reg_rd_done           = cq_reg_if.reg_rd_done;
assign cq_reg_rd_resp           = cq_reg_if.reg_rd_resp;
assign cq_reg_rd_data           = cq_reg_if.reg_rd_data;

assign cq_reg_if.reg_wr_valid   = cq_reg_wr_valid;
assign cq_reg_if.reg_wr_addr    = cq_reg_wr_addr;
assign cq_reg_if.reg_wr_be      = cq_reg_wr_be;
assign cq_reg_if.reg_wr_data    = cq_reg_wr_data;
assign cq_reg_wr_done           = cq_reg_if.reg_wr_done;
assign cq_reg_wr_resp           = cq_reg_if.reg_wr_resp;

endmodule : cmd_queue_v2_0_0_axi


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

module cmd_queue_v2_0_0_regs
(
  // Register Interface
  cmd_queue_v2_0_0_reg_if.sub         sq_reg_if,
  cmd_queue_v2_0_0_reg_if.sub         cq_reg_if,

  // Clock/Reset
  input  logic                      aclk,
  input  logic                      aresetn,

  // Interrupts
  output logic                      irq_sq,
  output logic                      irq_cq
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
localparam int  C_SQ_ADDR_WIDTH          = $bits(sq_reg_if.reg_wr_addr);
localparam int  C_CQ_ADDR_WIDTH          = $bits(cq_reg_if.reg_wr_addr);
localparam int  IRQ_SR_WIDTH             = 2;

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------

logic [31:0]              sq_tail_pntr;
logic                     sq_irq_tail_pntr;
logic                     sq_irq_tail_pntr_isr;
logic                     sq_irq_tail_pntr_clr;
logic                     sq_irq_reg;
logic                     sq_irq_reg_isr;
logic                     sq_irq_reg_clr;
logic                     sq_irq_en;
logic [IRQ_SR_WIDTH-1:0]  sq_irq_en_sr;
logic                     sq_irq_type;
logic                     sq_rst;
logic [31:0]              sq_mem_addr_lo;
logic [31:0]              sq_mem_addr_hi;

logic [31:0]              cq_tail_pntr;
logic                     cq_irq_tail_pntr;
logic                     cq_irq_tail_pntr_isr;
logic                     cq_irq_tail_pntr_clr;
logic                     cq_irq_reg;
logic                     cq_irq_reg_isr;
logic                     cq_irq_reg_clr;
logic                     cq_irq_en;
logic [IRQ_SR_WIDTH-1:0]  cq_irq_en_sr;
logic                     cq_irq_type;
logic                     cq_rst;
logic [31:0]              cq_mem_addr_lo;
logic [31:0]              cq_mem_addr_hi;

logic                     soft_rst;

// ========================================================

// Assert the soft reset when either SQ/CQ resets are set
assign soft_rst = sq_rst | cq_rst;

// ========================================================

// Interrupt Generation
always_ff @(posedge aclk) begin
  if (!aresetn) begin
    irq_sq                <= '0;
    sq_irq_en_sr          <= '0;
    sq_irq_reg_isr        <= '0;
    sq_irq_tail_pntr_isr  <= '0;
    irq_cq                <= '0;
    cq_irq_en_sr          <= '0;
    cq_irq_reg_isr        <= '0;
    cq_irq_tail_pntr_isr  <= '0;
  end else begin
    // Defaults
    irq_sq                <= '0;
    sq_irq_en_sr          <= {sq_irq_en_sr[IRQ_SR_WIDTH-2:0],1'b1};
    irq_cq                <= '0;
    cq_irq_en_sr          <= {cq_irq_en_sr[IRQ_SR_WIDTH-2:0],1'b1};

    // SQ Interrupt Generation

    // SQ Register Interrupt - Asserted when the Interrupt Register is written

    if ((sq_irq_reg_clr && sq_irq_type) || soft_rst) begin
      // Clear the register interrupt when the interrupt status register is read or on a soft reset
      sq_irq_reg_isr  <= '0;
      sq_irq_en_sr    <= '0;
    end

    if (sq_irq_type && sq_irq_reg) begin
      // Assert the SQ register interrupt when the interrupt register is written
      sq_irq_reg_isr  <= '1;
    end else if (!sq_irq_type) begin
      // If the interrupt type is configured for the tail pointer, then clear any pending register
      // interrupts that get asserted
      sq_irq_reg_isr  <= '0;
    end

    // SQ Tail Pointer Interrupt - Asserted when the Tail Pointer register is written

    if ((sq_irq_tail_pntr_clr && !sq_irq_type) || soft_rst) begin
      // Clear the register interrupt when the interrupt status register is read or on a soft reset
      sq_irq_tail_pntr_isr  <= '0;
      sq_irq_en_sr          <= '0;
    end

    if (!sq_irq_type && sq_irq_tail_pntr) begin
      // Assert the interrupt when the tail pointer register is written
      sq_irq_tail_pntr_isr  <= '1;
    end else if (sq_irq_type) begin
      // If the interrupt type is configured for register interrupt, then clear any pending tail
      // pointer interrupts that get asserted
      sq_irq_tail_pntr_isr  <= '0;
    end

    if (sq_irq_en) begin
      // Assert the SQ interrupt output when enabled and either the register or tail pointer
      // interrupts are set. The MSB of the shift register ensures that the interrupt de-asserts
      // in the event of a coincident interrupt set/clear that would prevent a new rising-edge
      irq_sq  <= (sq_irq_reg_isr | sq_irq_tail_pntr_isr) & sq_irq_en_sr[IRQ_SR_WIDTH-1];
    end

    // ========================================================

    // CQ Interrupt Generation

    // CQ Register Interrupt - Asserted when the Interrupt Register is written

    if ((cq_irq_reg_clr && cq_irq_type) || soft_rst) begin
      // Clear the register interrupt when the interrupt status register is read or on a soft reset
      cq_irq_reg_isr  <= '0;
      cq_irq_en_sr    <= '0;
    end

    if (cq_irq_type && cq_irq_reg) begin
      // Assert the CQ register interrupt when the interrupt register is written
      cq_irq_reg_isr  <= '1;
    end else if (!cq_irq_type) begin
      // If the interrupt type is configured for the tail pointer, then clear any pending register
      // interrupts that get asserted
      cq_irq_reg_isr  <= '0;
    end

    // CQ Tail Pointer Interrupt - Asserted when the Tail Pointer register is written

    if ((cq_irq_tail_pntr_clr && !cq_irq_type) || soft_rst) begin
      // Clear the register interrupt when the interrupt status register is read or on a soft reset
      cq_irq_tail_pntr_isr  <= '0;
      cq_irq_en_sr          <= '0;
    end

    if (!cq_irq_type && cq_irq_tail_pntr) begin
      // Assert the interrupt when the tail pointer register is written
      cq_irq_tail_pntr_isr  <= '1;
    end else if (cq_irq_type) begin
      // If the interrupt type is configured for register interrupt, then clear any pending tail
      // pointer interrupts that get asserted
      cq_irq_tail_pntr_isr  <= '0;
    end

    if (cq_irq_en) begin
      // Assert the CQ interrupt output when enabled and either the register or tail pointer
      // interrupts are set. The MSB of the shift register ensures that the interrupt de-asserts
      // in the event of a coincident interrupt set/clear that would prevent a new rising-edge
      irq_cq  <= (cq_irq_reg_isr | cq_irq_tail_pntr_isr) & cq_irq_en_sr[IRQ_SR_WIDTH-1];
    end
  end
end

// ========================================================

// Producer Register Interface - Write
always_ff @(posedge aclk) begin
  if (!aresetn) begin
    sq_tail_pntr            <= '0;
    sq_irq_tail_pntr        <= '0;
    sq_irq_reg              <= '0;
    sq_irq_en               <= '0;
    sq_irq_type             <= '0;
    sq_mem_addr_hi          <= '0;
    sq_mem_addr_lo          <= '0;
    sq_rst                  <= '0;
    sq_reg_if.reg_wr_done   <= '0;
  end else begin
    // Defaults
    sq_reg_if.reg_wr_done   <= '0;
    sq_rst                  <= '0;
    sq_irq_tail_pntr        <= '0;
    sq_irq_reg              <= '0;

    if (sq_reg_if.reg_wr_valid) begin
      // Exclude unused address space to prevent aliasing
      if (!(|sq_reg_if.reg_wr_addr[C_SQ_ADDR_WIDTH-1:9])) begin
        case (sq_reg_if.reg_wr_addr[8:0]) inside
          9'b0000000??: // SQ Tail Pointer - 0x000
            begin
              sq_tail_pntr      <= sq_reg_if.reg_wr_data;
              sq_irq_tail_pntr  <= '1;
            end
          9'b0000001??: // SQ IRQ Control - 0x004
            sq_irq_reg        <= sq_reg_if.reg_wr_data[0];
          9'b0000010??: // SQ Queue Memory Address Low - 0x008
            sq_mem_addr_lo    <= sq_reg_if.reg_wr_data;
          9'b0000011??: // SQ Reset IRQ Control - 0x00C
            begin
              sq_irq_en       <= sq_reg_if.reg_wr_data[0];
              sq_irq_type     <= sq_reg_if.reg_wr_data[1];
              sq_rst          <= sq_reg_if.reg_wr_data[31];
            end
          9'b0000100??: // SQ Queue Memory Address High - 0x010
            sq_mem_addr_hi    <= sq_reg_if.reg_wr_data;
        endcase
      end
      // Signal write done
      sq_reg_if.reg_wr_done <= 1'b1;
    end

    // Clear the registers on a soft reset
    if (soft_rst) begin
      sq_tail_pntr            <= '0;
      sq_irq_en               <= '0;
      sq_irq_type             <= '0;
      sq_mem_addr_hi          <= '0;
      sq_mem_addr_lo          <= '0;
    end
  end
end

// Always respond with OKAY to writes
assign sq_reg_if.reg_wr_resp = '0;

// ========================================================

// Producer Register Interface - Read
always_ff @(posedge aclk) begin
  //Defaults
  sq_reg_if.reg_rd_data <= '0;
  sq_reg_if.reg_rd_done <= '0;
  cq_irq_reg_clr        <= '0;
  cq_irq_tail_pntr_clr  <= '0;

  if (sq_reg_if.reg_rd_valid) begin
    // Exclude unused address space to prevent aliasing
    if (!(|sq_reg_if.reg_rd_addr[C_SQ_ADDR_WIDTH-1:9])) begin
      case (sq_reg_if.reg_rd_addr[8:0]) inside
        9'b0000000??: // SQ Tail Pointer - 0x000
          sq_reg_if.reg_rd_data           <= sq_tail_pntr;
        9'b0000001??: // SQ IRQ Control - 0x004
          sq_reg_if.reg_rd_data[1]        <= sq_irq_reg_isr | sq_irq_tail_pntr_isr;
        9'b0000010??: // SQ Queue Memory Address Low - 0x008
          sq_reg_if.reg_rd_data           <= sq_mem_addr_lo;
        9'b0000011??: // SQ Reset IRQ Control - 0x00C
          begin
            sq_reg_if.reg_rd_data[1]      <= sq_irq_type;
            sq_reg_if.reg_rd_data[0]      <= sq_irq_en;
          end
        9'b0000100??: // SQ Queue Memory Address High - 0x010
          sq_reg_if.reg_rd_data           <= sq_mem_addr_hi;
        9'b1000000??: // CQ Tail Pointer - 0x100
          begin
            sq_reg_if.reg_rd_data           <= cq_tail_pntr;
            cq_irq_tail_pntr_clr            <= '1;
          end
        9'b1000001??: // CQ IRQ Status - 0x104
          begin
            sq_reg_if.reg_rd_data[0]        <= cq_irq_reg_isr;
            cq_irq_reg_clr                  <= '1;
          end
        9'b1000010??: // CQ Queue Memory Address Low - 0x108
          sq_reg_if.reg_rd_data           <= cq_mem_addr_lo;
        9'b1000011??: // CQ Reset IRQ Control - 0x10C
          begin
            sq_reg_if.reg_rd_data[1]      <= cq_irq_type;
            sq_reg_if.reg_rd_data[0]      <= cq_irq_en;
          end
        9'b1000100??: // CQ Queue Memory Address High - 0x110
          sq_reg_if.reg_rd_data           <= cq_mem_addr_hi;
        default:
          sq_reg_if.reg_rd_data           <= '0;
      endcase
    end
    // Signal read done
    sq_reg_if.reg_rd_done <= 1'b1;
  end
end

// Always respond with OKAY to reads
assign sq_reg_if.reg_rd_resp = '0;

// ========================================================

// Consumer Register Interface - Write
always_ff @(posedge aclk) begin
  if (!aresetn) begin
    cq_tail_pntr            <= '0;
    cq_irq_tail_pntr        <= '0;
    cq_irq_reg              <= '0;
    cq_irq_en               <= '0;
    cq_irq_type             <= '0;
    cq_mem_addr_hi          <= '0;
    cq_mem_addr_lo          <= '0;
    cq_rst                  <= '0;
    cq_reg_if.reg_wr_done   <= '0;
  end else begin
    // Defaults
    cq_reg_if.reg_wr_done   <= '0;
    cq_rst                  <= '0;
    cq_irq_tail_pntr        <= '0;
    cq_irq_reg              <= '0;

    if (cq_reg_if.reg_wr_valid) begin
      // Exclude unused address space to prevent aliasing
      if (!(|cq_reg_if.reg_wr_addr[C_CQ_ADDR_WIDTH-1:9])) begin
        case (cq_reg_if.reg_wr_addr[8:0]) inside
          9'b0000000??: // CQ Tail Pointer - 0x000
            begin
              cq_tail_pntr      <= cq_reg_if.reg_wr_data;
              cq_irq_tail_pntr  <= '1;
            end
          9'b0000001??: // CQ IRQ Control - 0x004
            cq_irq_reg        <= cq_reg_if.reg_wr_data[0];
          9'b0000010??: // CQ Queue Memory Address Low - 0x008
            cq_mem_addr_lo    <= cq_reg_if.reg_wr_data;
          9'b0000011??: // CQ Reset IRQ Control - 0x00C
            begin
              cq_irq_en       <= cq_reg_if.reg_wr_data[0];
              cq_irq_type     <= cq_reg_if.reg_wr_data[1];
              cq_rst          <= cq_reg_if.reg_wr_data[31];
            end
          9'b0000100??: // CQ Queue Memory Address High - 0x010
            cq_mem_addr_hi    <= cq_reg_if.reg_wr_data;
        endcase
      end
      // Signal write done
      cq_reg_if.reg_wr_done <= 1'b1;
    end

    // Clear the registers on a soft reset
    if (soft_rst) begin
      cq_tail_pntr            <= '0;
      cq_irq_en               <= '0;
      cq_irq_type             <= '0;
      cq_mem_addr_hi          <= '0;
      cq_mem_addr_lo          <= '0;
    end
  end
end

// Always respond with OKAY to writes
assign cq_reg_if.reg_wr_resp = '0;

// ========================================================

// Consumer Register Interface - Read
always_ff @(posedge aclk) begin
  //Defaults
  cq_reg_if.reg_rd_data <= '0;
  cq_reg_if.reg_rd_done <= '0;
  sq_irq_reg_clr        <= '0;
  sq_irq_tail_pntr_clr  <= '0;

  if (cq_reg_if.reg_rd_valid) begin
    // Exclude unused address space to prevent aliasing
    if (!(|cq_reg_if.reg_rd_addr[C_CQ_ADDR_WIDTH-1:9])) begin
      case (cq_reg_if.reg_rd_addr[8:0]) inside
        9'b0000000??: // CQ Tail Pointer - 0x000
          cq_reg_if.reg_rd_data           <= cq_tail_pntr;
        9'b0000001??: // CQ IRQ Control - 0x004
          cq_reg_if.reg_rd_data[1]        <= cq_irq_reg_isr | cq_irq_tail_pntr_isr;
        9'b0000010??: // CQ Queue Memory Address Low - 0x008
          cq_reg_if.reg_rd_data           <= cq_mem_addr_lo;
        9'b0000011??: // CQ Reset IRQ Control - 0x00C
          begin
            cq_reg_if.reg_rd_data[1]      <= cq_irq_type;
            cq_reg_if.reg_rd_data[0]      <= cq_irq_en;
          end
        9'b0000100??: // CQ Queue Memory Address High - 0x010
          cq_reg_if.reg_rd_data           <= cq_mem_addr_hi;
        9'b1000000??: // SQ Tail Pointer - 0x100
          begin
            cq_reg_if.reg_rd_data         <= sq_tail_pntr;
            sq_irq_tail_pntr_clr          <= '1;
          end
        9'b1000001??: // SQ IRQ Status - 0x104
          begin
            cq_reg_if.reg_rd_data[0]      <= sq_irq_reg_isr;
            sq_irq_reg_clr                <= '1;
          end
        9'b1000010??: // SQ Queue Memory Address Low - 0x108
          cq_reg_if.reg_rd_data           <= sq_mem_addr_lo;
        9'b1000011??: // SQ Reset IRQ Control - 0x10C
          begin
            cq_reg_if.reg_rd_data[1]      <= sq_irq_type;
            cq_reg_if.reg_rd_data[0]      <= sq_irq_en;
          end
        9'b1000100??: // SQ Queue Memory Address High - 0x110
          cq_reg_if.reg_rd_data           <= sq_mem_addr_hi;
        default:
          cq_reg_if.reg_rd_data           <= '0;
      endcase
    end
    // Signal read done
    cq_reg_if.reg_rd_done <= 1'b1;
  end
end

// Always respond with OKAY to reads
assign cq_reg_if.reg_rd_resp = '0;

// ========================================================

endmodule : cmd_queue_v2_0_0_regs


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

module cmd_queue_v2_0_0_top #(
  parameter int C_S00_ADDR_WIDTH          = 12,
  parameter int C_S01_ADDR_WIDTH          = 12
) (
  // Clock Ports
  input  logic                         aclk,

  // Reset Ports
  input  logic                         aresetn,

  // S00_AXI Interface Ports
  input  logic [C_S00_ADDR_WIDTH-1:0]  s00_axi_awaddr,
  input  logic                         s00_axi_awvalid,
  output logic                         s00_axi_awready,
  input  logic [32-1:0]                s00_axi_wdata,
  input  logic [4-1:0]                 s00_axi_wstrb,
  input  logic                         s00_axi_wvalid,
  output logic                         s00_axi_wready,
  output logic [2-1:0]                 s00_axi_bresp,
  output logic                         s00_axi_bvalid,
  input  logic                         s00_axi_bready,
  input  logic [C_S00_ADDR_WIDTH-1:0]  s00_axi_araddr,
  input  logic                         s00_axi_arvalid,
  output logic                         s00_axi_arready,
  output logic [32-1:0]                s00_axi_rdata,
  output logic [2-1:0]                 s00_axi_rresp,
  output logic                         s00_axi_rvalid,
  input  logic                         s00_axi_rready,

  // S01_AXI Interface Ports
  input  logic [C_S01_ADDR_WIDTH-1:0]  s01_axi_awaddr,
  input  logic                         s01_axi_awvalid,
  output logic                         s01_axi_awready,
  input  logic [32-1:0]                s01_axi_wdata,
  input  logic [4-1:0]                 s01_axi_wstrb,
  input  logic                         s01_axi_wvalid,
  output logic                         s01_axi_wready,
  output logic [2-1:0]                 s01_axi_bresp,
  output logic                         s01_axi_bvalid,
  input  logic                         s01_axi_bready,
  input  logic [C_S01_ADDR_WIDTH-1:0]  s01_axi_araddr,
  input  logic                         s01_axi_arvalid,
  output logic                         s01_axi_arready,
  output logic [32-1:0]                s01_axi_rdata,
  output logic [2-1:0]                 s01_axi_rresp,
  output logic                         s01_axi_rvalid,
  input  logic                         s01_axi_rready,

  // Interrupt Ports
  output logic                         irq_sq,
  output logic                         irq_cq
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// Package Import
// --------------------------------------------------------

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

// ========================================================

// AXI4-Lite Interface Instantiations
cmd_queue_v2_0_0_axi_if #(.C_ADDR_WIDTH(C_S00_ADDR_WIDTH)) sq_axi_if();
cmd_queue_v2_0_0_axi_if #(.C_ADDR_WIDTH(C_S01_ADDR_WIDTH)) cq_axi_if();

// Producer (SQ) AXI-Lite Interface/port connections
assign sq_axi_if.awaddr   = s00_axi_awaddr;
assign sq_axi_if.awvalid  = s00_axi_awvalid;
assign s00_axi_awready    = sq_axi_if.awready;
assign sq_axi_if.wdata    = s00_axi_wdata;
assign sq_axi_if.wstrb    = s00_axi_wstrb;
assign sq_axi_if.wvalid   = s00_axi_wvalid;
assign s00_axi_wready     = sq_axi_if.wready;
assign s00_axi_bresp      = sq_axi_if.bresp;
assign s00_axi_bvalid     = sq_axi_if.bvalid;
assign sq_axi_if.bready   = s00_axi_bready;
assign sq_axi_if.araddr   = s00_axi_araddr;
assign sq_axi_if.arvalid  = s00_axi_arvalid;
assign s00_axi_arready    = sq_axi_if.arready;
assign s00_axi_rdata      = sq_axi_if.rdata;
assign s00_axi_rresp      = sq_axi_if.rresp;
assign s00_axi_rvalid     = sq_axi_if.rvalid;
assign sq_axi_if.rready   = s00_axi_rready;

// Consumer (CQ) AXI-Lite Interface/port connections
assign cq_axi_if.awaddr   = s01_axi_awaddr;
assign cq_axi_if.awvalid  = s01_axi_awvalid;
assign s01_axi_awready    = cq_axi_if.awready;
assign cq_axi_if.wdata    = s01_axi_wdata;
assign cq_axi_if.wstrb    = s01_axi_wstrb;
assign cq_axi_if.wvalid   = s01_axi_wvalid;
assign s01_axi_wready     = cq_axi_if.wready;
assign s01_axi_bresp      = cq_axi_if.bresp;
assign s01_axi_bvalid     = cq_axi_if.bvalid;
assign cq_axi_if.bready   = s01_axi_bready;
assign cq_axi_if.araddr   = s01_axi_araddr;
assign cq_axi_if.arvalid  = s01_axi_arvalid;
assign s01_axi_arready    = cq_axi_if.arready;
assign s01_axi_rdata      = cq_axi_if.rdata;
assign s01_axi_rresp      = cq_axi_if.rresp;
assign s01_axi_rvalid     = cq_axi_if.rvalid;
assign cq_axi_if.rready   = s01_axi_rready;

// ========================================================

// Register Interface Instantiations
cmd_queue_v2_0_0_reg_if #(.C_ADDR_WIDTH(C_S00_ADDR_WIDTH)) sq_reg_if();
cmd_queue_v2_0_0_reg_if #(.C_ADDR_WIDTH(C_S01_ADDR_WIDTH)) cq_reg_if();

// ========================================================

// AXI Module Instantiation
cmd_queue_v2_0_0_axi #(
  .C_S00_ADDR_WIDTH(C_S00_ADDR_WIDTH),
  .C_S01_ADDR_WIDTH(C_S01_ADDR_WIDTH)
) axi_inst (
  .sq_axi_if,
  .cq_axi_if,
  .sq_reg_if,
  .cq_reg_if,
  .aclk,
  .aresetn
);

// ========================================================

// Command Queue Registers Module Instantiation
cmd_queue_v2_0_0_regs top_reg_inst (
  .sq_reg_if,
  .cq_reg_if,
  .aclk,
  .aresetn,
  .irq_sq,
  .irq_cq
);

// ========================================================

endmodule : cmd_queue_v2_0_0_top

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

module cmd_queue_v2_0_0 #(
	parameter integer C_S00_ADDR_WIDTH          = 12,
 	parameter integer C_S01_ADDR_WIDTH          = 12,
  parameter         C_S00_AXI_BASEADDR        = 32'hFFFFFFFF,
  parameter         C_S00_AXI_HIGHADDR        = 32'h00000000,
  parameter         C_S01_AXI_BASEADDR        = 32'hFFFFFFFF,
  parameter         C_S01_AXI_HIGHADDR        = 32'h00000000
)	(
	// Clock Ports
  input  wire                         aclk,

  // Reset Ports
  input  wire                         aresetn,

  // S00_AXI Interface Ports
  input  wire [C_S00_ADDR_WIDTH-1:0]  s00_axi_awaddr,
  input  wire                         s00_axi_awvalid,
  output wire                         s00_axi_awready,
  input  wire [32-1:0]                s00_axi_wdata,
  input  wire [4-1:0]                 s00_axi_wstrb,
  input  wire                         s00_axi_wvalid,
  output wire                         s00_axi_wready,
  output wire [2-1:0]                 s00_axi_bresp,
  output wire                         s00_axi_bvalid,
  input  wire                         s00_axi_bready,
  input  wire [C_S00_ADDR_WIDTH-1:0]  s00_axi_araddr,
  input  wire                         s00_axi_arvalid,
  output wire                         s00_axi_arready,
  output wire [32-1:0]                s00_axi_rdata,
  output wire [2-1:0]                 s00_axi_rresp,
  output wire                         s00_axi_rvalid,
  input  wire                         s00_axi_rready,

  // S01_AXI Interface Ports
  input  wire [C_S01_ADDR_WIDTH-1:0]  s01_axi_awaddr,
  input  wire                         s01_axi_awvalid,
  output wire                         s01_axi_awready,
  input  wire [32-1:0]                s01_axi_wdata,
  input  wire [4-1:0]                 s01_axi_wstrb,
  input  wire                         s01_axi_wvalid,
  output wire                         s01_axi_wready,
  output wire [2-1:0]                 s01_axi_bresp,
  output wire                         s01_axi_bvalid,
  input  wire                         s01_axi_bready,
  input  wire [C_S01_ADDR_WIDTH-1:0]  s01_axi_araddr,
  input  wire                         s01_axi_arvalid,
  output wire                         s01_axi_arready,
  output wire [32-1:0]                s01_axi_rdata,
  output wire [2-1:0]                 s01_axi_rresp,
  output wire                         s01_axi_rvalid,
  input  wire                         s01_axi_rready,

  // Interrupt Ports
  output wire                         irq_sq,
  output wire                         irq_cq
);

// --------------------------------------------------------
// GCQ Top Level Instantiation
// --------------------------------------------------------
cmd_queue_v2_0_0_top #(
  .C_S00_ADDR_WIDTH(C_S00_ADDR_WIDTH),
	.C_S01_ADDR_WIDTH(C_S01_ADDR_WIDTH)
) cmd_queue_top_inst (
  // Clocks
  .aclk(aclk),

  // Resets
  .aresetn(aresetn),

  // S00_AXI Interface
  .s00_axi_awaddr(s00_axi_awaddr),
  .s00_axi_awvalid(s00_axi_awvalid),
  .s00_axi_awready(s00_axi_awready),
  .s00_axi_wdata(s00_axi_wdata),
  .s00_axi_wstrb(s00_axi_wstrb),
  .s00_axi_wvalid(s00_axi_wvalid),
  .s00_axi_wready(s00_axi_wready),
  .s00_axi_bresp(s00_axi_bresp),
  .s00_axi_bvalid(s00_axi_bvalid),
  .s00_axi_bready(s00_axi_bready),
  .s00_axi_araddr(s00_axi_araddr),
  .s00_axi_arvalid(s00_axi_arvalid),
  .s00_axi_arready(s00_axi_arready),
  .s00_axi_rdata(s00_axi_rdata),
  .s00_axi_rresp(s00_axi_rresp),
  .s00_axi_rvalid(s00_axi_rvalid),
  .s00_axi_rready(s00_axi_rready),

	// S01_AXI Interface
  .s01_axi_awaddr(s01_axi_awaddr),
  .s01_axi_awvalid(s01_axi_awvalid),
  .s01_axi_awready(s01_axi_awready),
  .s01_axi_wdata(s01_axi_wdata),
  .s01_axi_wstrb(s01_axi_wstrb),
  .s01_axi_wvalid(s01_axi_wvalid),
  .s01_axi_wready(s01_axi_wready),
  .s01_axi_bresp(s01_axi_bresp),
  .s01_axi_bvalid(s01_axi_bvalid),
  .s01_axi_bready(s01_axi_bready),
  .s01_axi_araddr(s01_axi_araddr),
  .s01_axi_arvalid(s01_axi_arvalid),
  .s01_axi_arready(s01_axi_arready),
  .s01_axi_rdata(s01_axi_rdata),
  .s01_axi_rresp(s01_axi_rresp),
  .s01_axi_rvalid(s01_axi_rvalid),
  .s01_axi_rready(s01_axi_rready),

  // Interrupts
  .irq_sq(irq_sq),
	.irq_cq(irq_cq)

);

endmodule


