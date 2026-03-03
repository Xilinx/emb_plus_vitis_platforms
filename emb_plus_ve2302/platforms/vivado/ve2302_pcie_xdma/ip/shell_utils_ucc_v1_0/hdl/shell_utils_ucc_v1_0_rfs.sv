// Copyright (C) 2023 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT

`timescale 1 ps / 1 ps

module shell_utils_ucc_v1_0_0_frequency_counter #
(
    parameter integer REF_CLK_FREQ_HZ=100000000,
    parameter integer TEST_CLK_0_TYPE=1,
    parameter integer TEST_CLK_1_TYPE=0,
    parameter integer TEST_CLK_2_TYPE=0,
    parameter integer TEST_CLK_3_TYPE=0
) (
    input   aclk,
    input   aresetn,
    input   user_rst,
    output  done_ref,
    output  [31:0] ref_clk_cntr,
    output  [31:0] test_clk_cntr_synced_0,
    output  [31:0] test_clk_cntr_synced_1,
    output  [31:0] test_clk_cntr_synced_2,
    output  [31:0] test_clk_cntr_synced_3,
    output  [15:0] clock_config,

    input test_clk0,
    input test_clk1,
    input test_clk2,
    input test_clk3
);

  localparam NUM_CLKS = 4;
  localparam CFG_LEN = 4;
  localparam [(CFG_LEN*NUM_CLKS)-1:0] CLK_CONFIG = {TEST_CLK_3_TYPE[3:0], TEST_CLK_2_TYPE[3:0], TEST_CLK_1_TYPE[3:0], TEST_CLK_0_TYPE[3:0]};
  localparam REF_CNTR_SIZE = $clog2(REF_CLK_FREQ_HZ + 1);
  localparam TEST_CNTR_SIZE = (REF_CNTR_SIZE >= 25) ? 32 : (REF_CNTR_SIZE + 7);

  wire [NUM_CLKS-1:0] test_clk;

  wire rst_cnt_c;
  (* KEEP = "TRUE" *) reg rst_cnt_ref            = 1'b0;
  (* KEEP = "TRUE" *) reg [NUM_CLKS-1:0] rst_cnt = {NUM_CLKS{1'b0}};
  wire [NUM_CLKS-1:0] rst_cnt_synced;
  wire done_c;
  reg done_ref_i               = 1'b0;
  (* KEEP = "TRUE" *) reg [NUM_CLKS-1:0] done    = 1'b0;
  wire [NUM_CLKS-1:0] done_synced;
  reg [REF_CNTR_SIZE-1:0] ref_clk_cntr_i = {REF_CNTR_SIZE{1'b0}};
  reg  [TEST_CNTR_SIZE-1:0] test_clk_cntr[NUM_CLKS-1:0];
  wire [TEST_CNTR_SIZE-1:0] test_clk_cntr_synced_i[NUM_CLKS-1:0];

  assign test_clk = {test_clk3, test_clk2, test_clk1, test_clk0};
  assign done_ref = done_ref_i;
  assign ref_clk_cntr = ref_clk_cntr_i;
  assign test_clk_cntr_synced_0 = (&test_clk_cntr_synced_i[0]) ? {32{1'b1}} : test_clk_cntr_synced_i[0];
  assign test_clk_cntr_synced_1 = (&test_clk_cntr_synced_i[1]) ? {32{1'b1}} : test_clk_cntr_synced_i[1];
  assign test_clk_cntr_synced_2 = (&test_clk_cntr_synced_i[2]) ? {32{1'b1}} : test_clk_cntr_synced_i[2];
  assign test_clk_cntr_synced_3 = (&test_clk_cntr_synced_i[3]) ? {32{1'b1}} : test_clk_cntr_synced_i[3];
  assign clock_config = CLK_CONFIG;

  genvar i;
  generate for (i=0; i<NUM_CLKS; i=i+1)
  begin : CLKS
      if (CLK_CONFIG[((i+1)*CFG_LEN)-1:i*CFG_LEN] != 0)
      begin

          xpm_cdc_async_rst #(
              .DEST_SYNC_FF(3),    // DECIMAL; range: 2-10
              .INIT_SYNC_FF(0),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
              .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
          ) cdc_rst_cn0 (
              .dest_arst(rst_cnt_synced[i]),
              .dest_clk(test_clk[i]),   // 1-bit input: Destination clock.
              .src_arst(rst_cnt[i])    // 1-bit input: Source asynchronous reset signal.
          );

          xpm_cdc_array_single #(
            .DEST_SYNC_FF   (3), // integer; range: 2-10
            .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
            .SRC_INPUT_REG  (0), // integer; 0=do not register input, 1=register input
            .WIDTH          (1)  // integer; range: 1-1024
          ) cdc_done (
            .src_clk  (aclk),  // optional; required when SRC_INPUT_REG = 1
            .src_in   (done[i]),
            .dest_clk (test_clk[i]),
            .dest_out (done_synced[i])
          );

          xpm_cdc_array_single #(
            .DEST_SYNC_FF   (2), // integer; range: 2-10
            .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
            .SRC_INPUT_REG  (0), // integer; 0=do not register input, 1=register input
            .WIDTH          (TEST_CNTR_SIZE)  // integer; range: 1-1024
          ) cdc_test_clk0_cntr (
            .src_clk  (test_clk[i]),  // optional; required when SRC_INPUT_REG = 1
            .src_in   (test_clk_cntr[i]),
            .dest_clk (aclk),
            .dest_out (test_clk_cntr_synced_i[i])
          );

          always @ (posedge test_clk[i] or posedge rst_cnt_synced[i]) begin
              if (rst_cnt_synced[i])
                  test_clk_cntr[i] <= 0;
              else begin
          		if(~done_synced[i])
                      test_clk_cntr[i] <= test_clk_cntr[i] + 1;
          	end
          end

      end
      else
          assign test_clk_cntr_synced_i[i] = {TEST_CNTR_SIZE{1'b1}};
  end
  endgenerate

  always @(posedge aclk) begin
      rst_cnt_ref <= rst_cnt_c;
      rst_cnt     <= {NUM_CLKS{rst_cnt_c}};
  end

  assign rst_cnt_c = ~aresetn | user_rst;
  assign done_c = ref_clk_cntr_i == (REF_CLK_FREQ_HZ - 1);

  //Ref clock counter logic
  always @(posedge aclk) begin
  	if(rst_cnt_ref) begin
  		ref_clk_cntr_i <= 0;
          done_ref_i     <= 1'b0;
          done         <= {NUM_CLKS{1'b0}};
  	end
  	else begin
  		if(~done_ref) begin
              ref_clk_cntr_i <= ref_clk_cntr_i+1;
              done_ref_i     <= done_c;
              done         <= {NUM_CLKS{done_c}};
          end
  	end
  end

endmodule


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

`timescale 1 ps / 1 ps

module shell_utils_ucc_v1_0_0_aclk_kernel
  #(
    parameter integer C_EXT_TOG_ENABLE = 1
   ) (
    clk_in,
    rst_in,
    clk_in_locked,
    aclk_kernel,
    aclk_kernel_cont,
    aclk_ext_tog_kernel,
    clock_program_done,
    ext_tog_ctrl_kernel_enable,
    ext_tog_ctrl_kernel_in,
    ext_tog_ctrl_kernel_out,
    ext_tog_ctrl_kernel_enable_sw,
    gapping_demand_toggle,
    power_down_in,
    power_down_out,
    rst_async,
    requested_gapping_demand_rate,
    shutdown_request_latch);
  input clk_in;
  input rst_in;
  input clk_in_locked;
  output aclk_kernel;
  output aclk_kernel_cont;
  output aclk_ext_tog_kernel;
  input clock_program_done;
  input ext_tog_ctrl_kernel_enable;
  input ext_tog_ctrl_kernel_in;
  output ext_tog_ctrl_kernel_out;
  input ext_tog_ctrl_kernel_enable_sw;
  input gapping_demand_toggle;
  input power_down_in;
  output power_down_out;
  output rst_async;
  input [7:0] requested_gapping_demand_rate;
  input shutdown_request_latch;

  shell_utils_ucc_v1_0_0_clock_throttling
      #(
        .CLK_SLOW_DIV(1),
        .SYNTH_SIZE(8),
        .IS_VERSAL(1'b1),
        .SIM_DEVICE("VERSAL_AI_CORE"),
        .EXT_TOG_ENABLE(C_EXT_TOG_ENABLE)
       ) clock_throttling_aclk_kernel_00 (
        .Clk_In(clk_in),
        .Clk_Out(aclk_kernel),
        .Clk_Out_Cont(aclk_kernel_cont),
        .Clk_Out_Cont_Int(aclk_ext_tog_kernel),
        .Clk_Out_Div(),
        .Ext_Tog_En(ext_tog_ctrl_kernel_enable),
        .Ext_Tog_En_SW(ext_tog_ctrl_kernel_enable_sw),
        .Ext_Tog_In(ext_tog_ctrl_kernel_in),
        .Ext_Tog_Out(ext_tog_ctrl_kernel_out),
        .Locked(clk_in_locked),
        .Rate_In(requested_gapping_demand_rate),
        .Rate_Upd_Tog(gapping_demand_toggle),
        .Rst_Async(rst_async),
        .Rst_In(rst_in),
        .Shutdown_Latch(shutdown_request_latch),
        .Startup_Done(clock_program_done),
        .power_down_in(power_down_in),
        .power_down_out(power_down_out));
endmodule

module shell_utils_ucc_v1_0_0_top
  #(
    parameter integer C_NUM_CLOCKS = 2,
    parameter integer C_FREQ_CNT_REF_CLK_HZ = 33333,
    parameter integer C_EXT_TOG_ENABLE = 1
   ) (
    aclk_ctrl,
    aclk_freerun,
    aclk_pcie,
    aresetn_ctrl,
    aclk_kernel_00,
    aclk_kernel_01,
    aclk_kernel_02,
    aclk_kernel_03,
    aclk_kernel_04,
    aclk_kernel_05,
    aclk_kernel_cont_00,
    aclk_kernel_cont_01,
    aclk_kernel_cont_02,
    aclk_kernel_cont_03,
    aclk_kernel_cont_04,
    aclk_kernel_cont_05,
    aclk_ext_tog_kernel_00,
    aclk_ext_tog_kernel_01,
    aclk_ext_tog_kernel_02,
    aclk_ext_tog_kernel_03,
    aclk_ext_tog_kernel_04,
    aclk_ext_tog_kernel_05,
    clk_in_kernel_00,
    clk_in_kernel_01,
    clk_in_kernel_02,
    clk_in_kernel_03,
    clk_in_kernel_04,
    clk_in_kernel_05,
    clk_kernel_00_locked,
    clk_kernel_01_locked,
    clk_kernel_02_locked,
    clk_kernel_03_locked,
    clk_kernel_04_locked,
    clk_kernel_05_locked,
    ext_tog_ctrl_kernel_00_enable,
    ext_tog_ctrl_kernel_01_enable,
    ext_tog_ctrl_kernel_02_enable,
    ext_tog_ctrl_kernel_03_enable,
    ext_tog_ctrl_kernel_04_enable,
    ext_tog_ctrl_kernel_05_enable,
    ext_tog_ctrl_kernel_00_in,
    ext_tog_ctrl_kernel_01_in,
    ext_tog_ctrl_kernel_02_in,
    ext_tog_ctrl_kernel_03_in,
    ext_tog_ctrl_kernel_04_in,
    ext_tog_ctrl_kernel_05_in,
    ext_tog_ctrl_kernel_00_out,
    ext_tog_ctrl_kernel_01_out,
    ext_tog_ctrl_kernel_02_out,
    ext_tog_ctrl_kernel_03_out,
    ext_tog_ctrl_kernel_04_out,
    ext_tog_ctrl_kernel_05_out,
    rst_async_kernel_00,
    rst_async_kernel_01,
    rst_async_kernel_02,
    rst_async_kernel_03,
    rst_async_kernel_04,
    rst_async_kernel_05,
    power_down,
    shutdown_clocks,
    s_axi_ctrl_mgmt_araddr,
    s_axi_ctrl_mgmt_arready,
    s_axi_ctrl_mgmt_arvalid,
    s_axi_ctrl_mgmt_awaddr,
    s_axi_ctrl_mgmt_awready,
    s_axi_ctrl_mgmt_awvalid,
    s_axi_ctrl_mgmt_bready,
    s_axi_ctrl_mgmt_bresp,
    s_axi_ctrl_mgmt_bvalid,
    s_axi_ctrl_mgmt_rdata,
    s_axi_ctrl_mgmt_rready,
    s_axi_ctrl_mgmt_rresp,
    s_axi_ctrl_mgmt_rvalid,
    s_axi_ctrl_mgmt_wdata,
    s_axi_ctrl_mgmt_wready,
    s_axi_ctrl_mgmt_wstrb,
    s_axi_ctrl_mgmt_wvalid);

  input aclk_ctrl;
  input aclk_freerun;
  input aclk_pcie;
  input aresetn_ctrl;
  output aclk_kernel_00;
  output aclk_kernel_01;
  output aclk_kernel_02;
  output aclk_kernel_03;
  output aclk_kernel_04;
  output aclk_kernel_05;
  output aclk_kernel_cont_00;
  output aclk_kernel_cont_01;
  output aclk_kernel_cont_02;
  output aclk_kernel_cont_03;
  output aclk_kernel_cont_04;
  output aclk_kernel_cont_05;
  output aclk_ext_tog_kernel_00;
  output aclk_ext_tog_kernel_01;
  output aclk_ext_tog_kernel_02;
  output aclk_ext_tog_kernel_03;
  output aclk_ext_tog_kernel_04;
  output aclk_ext_tog_kernel_05;
  input clk_in_kernel_00;
  input clk_in_kernel_01;
  input clk_in_kernel_02;
  input clk_in_kernel_03;
  input clk_in_kernel_04;
  input clk_in_kernel_05;
  input clk_kernel_00_locked;
  input clk_kernel_01_locked;
  input clk_kernel_02_locked;
  input clk_kernel_03_locked;
  input clk_kernel_04_locked;
  input clk_kernel_05_locked;
  input ext_tog_ctrl_kernel_00_enable;
  input ext_tog_ctrl_kernel_01_enable;
  input ext_tog_ctrl_kernel_02_enable;
  input ext_tog_ctrl_kernel_03_enable;
  input ext_tog_ctrl_kernel_04_enable;
  input ext_tog_ctrl_kernel_05_enable;
  input ext_tog_ctrl_kernel_00_in;
  input ext_tog_ctrl_kernel_01_in;
  input ext_tog_ctrl_kernel_02_in;
  input ext_tog_ctrl_kernel_03_in;
  input ext_tog_ctrl_kernel_04_in;
  input ext_tog_ctrl_kernel_05_in;
  output ext_tog_ctrl_kernel_00_out;
  output ext_tog_ctrl_kernel_01_out;
  output ext_tog_ctrl_kernel_02_out;
  output ext_tog_ctrl_kernel_03_out;
  output ext_tog_ctrl_kernel_04_out;
  output ext_tog_ctrl_kernel_05_out;
  output rst_async_kernel_00;
  output rst_async_kernel_01;
  output rst_async_kernel_02;
  output rst_async_kernel_03;
  output rst_async_kernel_04;
  output rst_async_kernel_05;
  output power_down;
  input shutdown_clocks;
  input [31:0]s_axi_ctrl_mgmt_araddr;
  output s_axi_ctrl_mgmt_arready;
  input s_axi_ctrl_mgmt_arvalid;
  input [31:0]s_axi_ctrl_mgmt_awaddr;
  output s_axi_ctrl_mgmt_awready;
  input s_axi_ctrl_mgmt_awvalid;
  input s_axi_ctrl_mgmt_bready;
  output [1:0]s_axi_ctrl_mgmt_bresp;
  output s_axi_ctrl_mgmt_bvalid;
  output [31:0]s_axi_ctrl_mgmt_rdata;
  input s_axi_ctrl_mgmt_rready;
  output [1:0]s_axi_ctrl_mgmt_rresp;
  output s_axi_ctrl_mgmt_rvalid;
  input [31:0]s_axi_ctrl_mgmt_wdata;
  output s_axi_ctrl_mgmt_wready;
  input [3:0]s_axi_ctrl_mgmt_wstrb;
  input s_axi_ctrl_mgmt_wvalid;

  logic request_latch;
  logic shutdown_latch;
  logic [7:0] gapping_demand = 8'hFF;
  logic gapping_demand_toggle = 1'b0;
  logic gapping_demand_pending = 1'b0;
  logic request_ack = 1'b0;
  logic throttling_enabled = 1'b0;
  logic ext_tog_ctrl_enable_sw = 1'b0;
  logic [13:0] clock_throttling_average;
  logic startup_done = 1'b0;
  logic [15:0] Request_SW = 0;
  logic user_rst_aclk = 1'b0;
  logic done_ref_aclk;
  logic [4:0] done_ref_aclk_d;
  logic user_rst_aclk_fr;
  logic done_ref_aclk_fr;
  logic [15:0] clock_config_aclk;
  logic [31:0] ref_cntr_aclk;
  logic [31:0] test_cntr0_aclk;
  logic [31:0] test_cntr1_aclk;
  logic [31:0] ref_cntr_aclk_fr;
  logic [31:0] test_cntr0_aclk_fr;
  logic [31:0] test_cntr1_aclk_fr;
  logic [6-1:0] aclk_kernel;
  logic [6-1:0] aclk_kernel_cont;
  logic [6-1:0] aclk_ext_tog_kernel;
  logic [6-1:0] clk_in_kernel;
  logic [6-1:0] clk_kernel_locked;
  logic [6-1:0] ext_tog_ctrl_kernel_enable;
  logic [6-1:0] ext_tog_ctrl_kernel_in;
  logic [6-1:0] ext_tog_ctrl_kernel_out;
  logic [6-1:0] rst_async_kernel;
  logic [C_NUM_CLOCKS-1:0] power_down_out_kernel;
  logic [C_NUM_CLOCKS-1:0] user_rst_kernel = 0;
  logic [C_NUM_CLOCKS-1:0] done_ref_kernel;
  logic [5*C_NUM_CLOCKS-1:0] done_ref_kernel_d = 0;
  logic [C_NUM_CLOCKS-1:0] user_rst_kernel_fr;
  logic [C_NUM_CLOCKS-1:0] done_ref_kernel_fr;
  logic [16*C_NUM_CLOCKS-1:0] clock_config_kernel;
  logic [32*C_NUM_CLOCKS-1:0] ref_cntr_kernel;
  logic [32*C_NUM_CLOCKS-1:0] test_cntr0_kernel;
  logic [32*C_NUM_CLOCKS-1:0] test_cntr1_kernel;
  logic [32*C_NUM_CLOCKS-1:0] ref_cntr_kernel_fr;
  logic [32*C_NUM_CLOCKS-1:0] test_cntr0_kernel_fr;
  logic [32*C_NUM_CLOCKS-1:0] test_cntr1_kernel_fr;
  logic user_rst_kernel_i;
  logic done_ref_kernel_i;
  logic [15:0] clock_config_kernel_i;
  logic [31:0] ref_cntr_kernel_i;
  logic [31:0] test_cntr0_kernel_i;
  logic [31:0] test_cntr1_kernel_i;
  logic [4:0] user_rst_d = 0;
  logic [4:0] cmd_stall = 0;
  logic aresetn_aclk_freerun;
  logic done_test_aclk = 1'b0;
  logic [C_NUM_CLOCKS-1:0] done_test_kernel = 0;
  genvar ki;

  logic        s_axi_ctrl_mgmt_arready_i = 1'b0;
  logic        s_axi_ctrl_mgmt_rvalid_i  = 1'b0;
  logic        s_axi_ctrl_mgmt_awready_i = 1'b0;
  logic        s_axi_ctrl_mgmt_bvalid_i  = 1'b0;
  logic [31:0] s_axi_ctrl_mgmt_rdata_i;

  assign s_axi_ctrl_mgmt_arready = s_axi_ctrl_mgmt_arready_i;
  assign s_axi_ctrl_mgmt_rvalid  = s_axi_ctrl_mgmt_rvalid_i;
  assign s_axi_ctrl_mgmt_rdata   = s_axi_ctrl_mgmt_rdata_i;
  assign s_axi_ctrl_mgmt_rresp   = 2'b0;
  assign s_axi_ctrl_mgmt_awready = s_axi_ctrl_mgmt_awready_i;
  assign s_axi_ctrl_mgmt_wready  = s_axi_ctrl_mgmt_awready_i;  // Both aw and w ready driven in common
  assign s_axi_ctrl_mgmt_bvalid  = s_axi_ctrl_mgmt_bvalid_i;
  assign s_axi_ctrl_mgmt_bresp   = 2'b0;

  assign user_rst_kernel_i = user_rst_kernel >> s_axi_ctrl_mgmt_araddr[14:12];
  assign done_ref_kernel_i = done_test_kernel >> s_axi_ctrl_mgmt_araddr[14:12];
  assign clock_config_kernel_i = clock_config_kernel >> (16 * s_axi_ctrl_mgmt_araddr[14:12]);
  assign ref_cntr_kernel_i = ref_cntr_kernel >> (32 * s_axi_ctrl_mgmt_araddr[14:12]);
  assign test_cntr0_kernel_i = test_cntr0_kernel >> (32 * s_axi_ctrl_mgmt_araddr[14:12]);
  assign test_cntr1_kernel_i = test_cntr1_kernel >> (32 * s_axi_ctrl_mgmt_araddr[14:12]);

  assign aclk_kernel_00 = aclk_kernel[0];
  assign aclk_kernel_01 = aclk_kernel[1];
  assign aclk_kernel_02 = aclk_kernel[2];
  assign aclk_kernel_03 = aclk_kernel[3];
  assign aclk_kernel_04 = aclk_kernel[4];
  assign aclk_kernel_05 = aclk_kernel[5];
  assign aclk_kernel_cont_00 = aclk_kernel_cont[0];
  assign aclk_kernel_cont_01 = aclk_kernel_cont[1];
  assign aclk_kernel_cont_02 = aclk_kernel_cont[2];
  assign aclk_kernel_cont_03 = aclk_kernel_cont[3];
  assign aclk_kernel_cont_04 = aclk_kernel_cont[4];
  assign aclk_kernel_cont_05 = aclk_kernel_cont[5];
  assign aclk_ext_tog_kernel_00 = aclk_ext_tog_kernel[0];
  assign aclk_ext_tog_kernel_01 = aclk_ext_tog_kernel[1];
  assign aclk_ext_tog_kernel_02 = aclk_ext_tog_kernel[2];
  assign aclk_ext_tog_kernel_03 = aclk_ext_tog_kernel[3];
  assign aclk_ext_tog_kernel_04 = aclk_ext_tog_kernel[4];
  assign aclk_ext_tog_kernel_05 = aclk_ext_tog_kernel[5];
  assign clk_in_kernel[0] = clk_in_kernel_00;
  assign clk_in_kernel[1] = clk_in_kernel_01;
  assign clk_in_kernel[2] = clk_in_kernel_02;
  assign clk_in_kernel[3] = clk_in_kernel_03;
  assign clk_in_kernel[4] = clk_in_kernel_04;
  assign clk_in_kernel[5] = clk_in_kernel_05;
  assign clk_kernel_locked[0] = clk_kernel_00_locked;
  assign clk_kernel_locked[1] = clk_kernel_01_locked;
  assign clk_kernel_locked[2] = clk_kernel_02_locked;
  assign clk_kernel_locked[3] = clk_kernel_03_locked;
  assign clk_kernel_locked[4] = clk_kernel_04_locked;
  assign clk_kernel_locked[5] = clk_kernel_05_locked;
  assign ext_tog_ctrl_kernel_enable[0] = ext_tog_ctrl_kernel_00_enable ;
  assign ext_tog_ctrl_kernel_enable[1] = ext_tog_ctrl_kernel_01_enable ;
  assign ext_tog_ctrl_kernel_enable[2] = ext_tog_ctrl_kernel_02_enable ;
  assign ext_tog_ctrl_kernel_enable[3] = ext_tog_ctrl_kernel_03_enable ;
  assign ext_tog_ctrl_kernel_enable[4] = ext_tog_ctrl_kernel_04_enable ;
  assign ext_tog_ctrl_kernel_enable[5] = ext_tog_ctrl_kernel_05_enable ;
  assign ext_tog_ctrl_kernel_in[0]     = ext_tog_ctrl_kernel_00_in     ;
  assign ext_tog_ctrl_kernel_in[1]     = ext_tog_ctrl_kernel_01_in     ;
  assign ext_tog_ctrl_kernel_in[2]     = ext_tog_ctrl_kernel_02_in     ;
  assign ext_tog_ctrl_kernel_in[3]     = ext_tog_ctrl_kernel_03_in     ;
  assign ext_tog_ctrl_kernel_in[4]     = ext_tog_ctrl_kernel_04_in     ;
  assign ext_tog_ctrl_kernel_in[5]     = ext_tog_ctrl_kernel_05_in     ;
  assign ext_tog_ctrl_kernel_00_out    = ext_tog_ctrl_kernel_out[0]    ;
  assign ext_tog_ctrl_kernel_01_out    = ext_tog_ctrl_kernel_out[1]    ;
  assign ext_tog_ctrl_kernel_02_out    = ext_tog_ctrl_kernel_out[2]    ;
  assign ext_tog_ctrl_kernel_03_out    = ext_tog_ctrl_kernel_out[3]    ;
  assign ext_tog_ctrl_kernel_04_out    = ext_tog_ctrl_kernel_out[4]    ;
  assign ext_tog_ctrl_kernel_05_out    = ext_tog_ctrl_kernel_out[5]    ;
  assign rst_async_kernel_00 = rst_async_kernel[0] ;
  assign rst_async_kernel_01 = rst_async_kernel[1] ;
  assign rst_async_kernel_02 = rst_async_kernel[2] ;
  assign rst_async_kernel_03 = rst_async_kernel[3] ;
  assign rst_async_kernel_04 = rst_async_kernel[4] ;
  assign rst_async_kernel_05 = rst_async_kernel[5] ;

  assign power_down = &power_down_out_kernel;

  // AXI-Lite Control Interface

  always @(posedge aclk_ctrl) begin
    if (~aresetn_ctrl) begin
      s_axi_ctrl_mgmt_arready_i <= 1'b0;
      s_axi_ctrl_mgmt_rvalid_i <= 1'b0;
    end else begin
      if (s_axi_ctrl_mgmt_rvalid_i) begin
        if (s_axi_ctrl_mgmt_rready) begin
          s_axi_ctrl_mgmt_rvalid_i <= 1'b0;
        end
      end else if (s_axi_ctrl_mgmt_arvalid) begin
        if (s_axi_ctrl_mgmt_arready_i) begin
          s_axi_ctrl_mgmt_arready_i <= 1'b0;
          s_axi_ctrl_mgmt_rvalid_i <= 1'b1;
        end else if (~|user_rst_d) begin
          s_axi_ctrl_mgmt_arready_i <= 1'b1;
        end
      end
    end
  end

  always @(posedge aclk_ctrl) begin
    if (s_axi_ctrl_mgmt_arvalid & ~s_axi_ctrl_mgmt_rvalid_i) begin
      casex (s_axi_ctrl_mgmt_araddr[15:0])
        16'b0000_0000_0000_00xx:  // Gapping demand control reg
          begin
            s_axi_ctrl_mgmt_rdata_i = {ext_tog_ctrl_enable_sw, 3'b0, throttling_enabled, 3'b0, request_ack, 8'b0, gapping_demand};
          end
        16'b0000_0000_0000_10xx:  // Gapping demand Status Reg
          begin
            s_axi_ctrl_mgmt_rdata_i = request_latch;
          end
        16'b0001_0000_0000_00xx:  // UCS Status Reg
          begin
            s_axi_ctrl_mgmt_rdata_i = {clock_throttling_average, 15'b0, shutdown_latch};
          end
        16'b0001_0000_0000_10xx:  // UCS Control Reg
          begin
            s_axi_ctrl_mgmt_rdata_i = {Request_SW, 3'b0, startup_done};
          end
        16'b0010_0000_0000_00xx:  // ACLK Frequency counter status Reg
          begin
            s_axi_ctrl_mgmt_rdata_i = {clock_config_aclk, 14'b0, done_test_aclk, user_rst_aclk};
          end
        16'b0010_0000_0000_01xx:  // ACLK Frequency Count Ref Clock Reg
          begin
            s_axi_ctrl_mgmt_rdata_i = ref_cntr_aclk;
          end
        16'b0010_0000_0001_00xx:  // ACLK Frequency Count Test0 Clock Reg
          begin
            s_axi_ctrl_mgmt_rdata_i = test_cntr0_aclk;
          end
        16'b0010_0000_0001_01xx:  // ACLK Frequency Count Test1 Clock Reg
          begin
            s_axi_ctrl_mgmt_rdata_i = test_cntr1_aclk;
          end
        16'b1xxx_0000_0000_00xx:  // Kernel Frequency counter status Reg
          begin
            if ({1'b0, s_axi_ctrl_mgmt_araddr[14:12]} <= {1'b0, C_NUM_CLOCKS[2:0]}) begin
              s_axi_ctrl_mgmt_rdata_i = {clock_config_kernel_i, 14'b0, done_ref_kernel_i, user_rst_kernel_i};
            end else begin
              s_axi_ctrl_mgmt_rdata_i <= 32'b0;
            end
          end
        16'b1xxx_0000_0000_01xx:  // Kernel Frequency Count Ref Clock Reg
          begin
            if ({1'b0, s_axi_ctrl_mgmt_araddr[14:12]} <= {1'b0, C_NUM_CLOCKS[2:0]}) begin
              s_axi_ctrl_mgmt_rdata_i = ref_cntr_kernel_i;
            end else begin
              s_axi_ctrl_mgmt_rdata_i <= 32'b0;
            end
          end
        16'b1xxx_0000_0001_00xx:  // Kernel Frequency Count Test0 Clock Reg
          begin
            if ({1'b0, s_axi_ctrl_mgmt_araddr[14:12]} <= {1'b0, C_NUM_CLOCKS[2:0]}) begin
              s_axi_ctrl_mgmt_rdata_i = test_cntr0_kernel_i;
            end else begin
              s_axi_ctrl_mgmt_rdata_i <= 32'b0;
            end
          end
        16'b1xxx_0000_0001_01xx:  // Kernel Frequency Count Test1 Clock Reg
          begin
            if ({1'b0, s_axi_ctrl_mgmt_araddr[14:12]} <= {1'b0, C_NUM_CLOCKS[2:0]}) begin
              s_axi_ctrl_mgmt_rdata_i = test_cntr1_kernel_i;
            end else begin
              s_axi_ctrl_mgmt_rdata_i <= 32'b0;
            end
          end
        default: s_axi_ctrl_mgmt_rdata_i <= 32'b0;
      endcase
    end
  end

  always @(posedge aclk_ctrl) begin
    if (~aresetn_ctrl) begin
      s_axi_ctrl_mgmt_awready_i <= 1'b0;
      s_axi_ctrl_mgmt_bvalid_i <= 1'b0;
      user_rst_aclk <= 1'b0;
      user_rst_kernel <= 0;
      user_rst_d <= 0;
      gapping_demand <= 8'hFF;
      gapping_demand_toggle <= 1'b0;
      gapping_demand_pending <= 1'b0;
      request_ack <= 1'b0;
      throttling_enabled <= 1'b0;
      ext_tog_ctrl_enable_sw <= 1'b0;
      startup_done <= 1'b0;
      Request_SW <= 0;
      cmd_stall <= 0;
    end else begin
      if (|cmd_stall) cmd_stall <= cmd_stall - 1;
      if (|user_rst_d) user_rst_d <= user_rst_d - 1;
      if (~user_rst_d[3]) begin
        user_rst_aclk <= 1'b0;
        user_rst_kernel <= 0;
      end

      if (s_axi_ctrl_mgmt_bvalid_i) begin
        if (s_axi_ctrl_mgmt_bready) begin
          s_axi_ctrl_mgmt_bvalid_i <= 1'b0;
          if (gapping_demand_pending) begin
            gapping_demand_toggle <= ~gapping_demand_toggle;
            gapping_demand_pending <= 1'b0;
          end
        end
      end else if (s_axi_ctrl_mgmt_awvalid & s_axi_ctrl_mgmt_wvalid) begin
        if (s_axi_ctrl_mgmt_awready_i) begin
          s_axi_ctrl_mgmt_awready_i <= 1'b0;
          s_axi_ctrl_mgmt_bvalid_i <= 1'b1;
        end else if (~|cmd_stall) begin
          cmd_stall <= 5'b11111;
          s_axi_ctrl_mgmt_awready_i <= 1'b1;
          casex (s_axi_ctrl_mgmt_awaddr[15:0])
            16'b0000_0000_0000_00xx: begin  // Gapping demand control reg
              gapping_demand <= s_axi_ctrl_mgmt_wdata[7:0] ;
              request_ack <= s_axi_ctrl_mgmt_wdata[16] ;
              throttling_enabled <= s_axi_ctrl_mgmt_wdata[20] ;
              ext_tog_ctrl_enable_sw <= s_axi_ctrl_mgmt_wdata[24] ;
              gapping_demand_pending <= 1'b1;
            end
            16'b0001_0000_0000_10xx: begin  // UCS Control Reg
              startup_done <= s_axi_ctrl_mgmt_wdata[0] ;
              Request_SW <= s_axi_ctrl_mgmt_wdata[19:4] ;
            end
            16'b0010_0000_0000_00xx: begin  // ACLK Frequency counter status Reg
              user_rst_aclk <= s_axi_ctrl_mgmt_wdata[0] ;
              user_rst_d  <= 5'b11111;
            end
            16'b1xxx_0000_0000_00xx: begin  // Kernel Frequency counter status Reg
              if ({1'b0, s_axi_ctrl_mgmt_awaddr[14:12]} <= {1'b0, C_NUM_CLOCKS[2:0]}) begin
                user_rst_kernel <= s_axi_ctrl_mgmt_wdata[0] << s_axi_ctrl_mgmt_awaddr[14:12];
              end
              user_rst_d  <= 5'b11111;
            end
          endcase
        end
      end
    end
  end

generate
  for (ki=0; ki<C_NUM_CLOCKS; ki=ki+1) begin
    shell_utils_ucc_v1_0_0_aclk_kernel #(
          .C_EXT_TOG_ENABLE(C_EXT_TOG_ENABLE)
         ) aclk_kernel_inst
         (
          .clk_in(clk_in_kernel[ki]),
          .rst_in(aresetn_ctrl),
          .clk_in_locked(clk_kernel_locked[ki]),
          .aclk_kernel(aclk_kernel[ki]),
          .aclk_kernel_cont(aclk_kernel_cont[ki]),
          .aclk_ext_tog_kernel(aclk_ext_tog_kernel[ki]),
          .clock_program_done(startup_done),
          .ext_tog_ctrl_kernel_enable_sw(ext_tog_ctrl_enable_sw),
          .ext_tog_ctrl_kernel_enable(ext_tog_ctrl_kernel_enable[ki]),
          .ext_tog_ctrl_kernel_in(ext_tog_ctrl_kernel_in[ki]),
          .ext_tog_ctrl_kernel_out(ext_tog_ctrl_kernel_out[ki]),
          .rst_async(rst_async_kernel[ki]),
          .gapping_demand_toggle(gapping_demand_toggle),
          .power_down_in(shutdown_latch),
          .power_down_out(power_down_out_kernel[ki]),
          .requested_gapping_demand_rate(gapping_demand),
          .shutdown_request_latch(request_latch));

    shell_utils_ucc_v1_0_0_frequency_counter #(
      .REF_CLK_FREQ_HZ(C_FREQ_CNT_REF_CLK_HZ),
      .TEST_CLK_0_TYPE(1),
      .TEST_CLK_1_TYPE(2),
      .TEST_CLK_2_TYPE(0),
      .TEST_CLK_3_TYPE(0)
      ) frequency_counter_kernel_inst
         (.aclk(aclk_freerun),
          .aresetn(aresetn_aclk_freerun),
          .user_rst(user_rst_kernel_fr[ki]),
          .done_ref(done_ref_kernel_fr[ki]),
          .clock_config(clock_config_kernel[16*ki +: 16]),
          .ref_clk_cntr(ref_cntr_kernel_fr[32*ki +: 32]),
          .test_clk_cntr_synced_0(test_cntr0_kernel_fr[32*ki +: 32]),
          .test_clk_cntr_synced_1(test_cntr1_kernel_fr[32*ki +: 32]),
          .test_clk_cntr_synced_2(),
          .test_clk_cntr_synced_3(),
          .test_clk0(aclk_kernel_cont[ki]),
          .test_clk1(aclk_kernel[ki]),
          .test_clk2(1'b0),
          .test_clk3(1'b0)
          );

    xpm_cdc_async_rst #(
        .DEST_SYNC_FF(3),    // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
    ) cdc_user_rst_kernel (
        .dest_arst(user_rst_kernel_fr[ki]),
        .dest_clk(aclk_freerun),   // 1-bit input: Destination clock.
        .src_arst(user_rst_kernel[ki])    // 1-bit input: Source asynchronous reset signal.
    );

    xpm_cdc_array_single #(
      .DEST_SYNC_FF   (3), // integer; range: 2-10
      .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG  (0), // integer; 0=do not register input, 1=register input
      .WIDTH          (97)  // integer; range: 1-1024
    ) cdc_freq_cntr_kernel (
      .src_clk  (1'b0),
      .src_in   ({done_ref_kernel_fr[ki], ref_cntr_kernel_fr[32*ki +: 32], test_cntr0_kernel_fr[32*ki +: 32], test_cntr1_kernel_fr[32*ki +: 32]}),
      .dest_clk (aclk_ctrl),
      .dest_out ({done_ref_kernel[ki], ref_cntr_kernel[32*ki +: 32], test_cntr0_kernel[32*ki +: 32], test_cntr1_kernel[32*ki +: 32]})
    );

    always @(posedge aclk_ctrl) begin
      if (~aresetn_ctrl) begin
        done_ref_kernel_d[ki*5 +: 5] <= 5'b0;
        done_test_kernel[ki] <= 1'b0;
      end else begin
        if (done_ref_kernel[ki]) begin
          if (&done_ref_kernel_d[ki*5 +: 5]) begin
            done_test_kernel[ki] <= 1'b1;
          end else begin
            done_ref_kernel_d[ki*5 +: 5] <= done_ref_kernel_d[ki*5 +: 5] + 1;
          end
        end else begin
          done_ref_kernel_d[ki*5 +: 5] <= 5'b0;
          done_test_kernel[ki] <= 1'b0;
        end
      end
    end

  end
endgenerate


  shell_utils_ucc_v1_0_0_frequency_counter #(
    .REF_CLK_FREQ_HZ(C_FREQ_CNT_REF_CLK_HZ),
    .TEST_CLK_0_TYPE(5),
    .TEST_CLK_1_TYPE(6),
    .TEST_CLK_2_TYPE(0),
    .TEST_CLK_3_TYPE(0)
    ) frequency_counter_aclk
       (.aclk(aclk_freerun),
        .aresetn(aresetn_aclk_freerun),
        .user_rst(user_rst_aclk_fr),
        .done_ref(done_ref_aclk_fr),
        .clock_config(clock_config_aclk),
        .ref_clk_cntr(ref_cntr_aclk_fr),
        .test_clk_cntr_synced_0(test_cntr0_aclk_fr),
        .test_clk_cntr_synced_1(test_cntr1_aclk_fr),
        .test_clk_cntr_synced_2(),
        .test_clk_cntr_synced_3(),
        .test_clk0(aclk_ctrl),
        .test_clk1(aclk_pcie),
        .test_clk2(1'b0),
        .test_clk3(1'b0)
        );

  xpm_cdc_async_rst #(
      .DEST_SYNC_FF(3),    // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
  ) cdc_user_rst_aclk (
      .dest_arst(user_rst_aclk_fr),
      .dest_clk(aclk_freerun),   // 1-bit input: Destination clock.
      .src_arst(user_rst_aclk)    // 1-bit input: Source asynchronous reset signal.
  );

  xpm_cdc_array_single #(
    .DEST_SYNC_FF   (2), // integer; range: 2-10
    .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG  (0), // integer; 0=do not register input, 1=register input
    .WIDTH          (97)  // integer; range: 1-1024
  ) cdc_freq_cntr_aclk (
    .src_clk  (1'b0),
    .src_in   ({done_ref_aclk_fr, ref_cntr_aclk_fr, test_cntr0_aclk_fr, test_cntr1_aclk_fr}),
    .dest_clk (aclk_ctrl),
    .dest_out ({done_ref_aclk, ref_cntr_aclk, test_cntr0_aclk, test_cntr1_aclk})
  );

  always @(posedge aclk_ctrl) begin
    if (~aresetn_ctrl) begin
      done_ref_aclk_d <= 5'b0;
      done_test_aclk <= 1'b0;
    end else begin
      if (done_ref_aclk) begin
        if (&done_ref_aclk_d) begin
          done_test_aclk <= 1'b1;
        end else begin
          done_ref_aclk_d <= done_ref_aclk_d + 1;
        end
      end else begin
        done_ref_aclk_d <= 5'b0;
        done_test_aclk <= 1'b0;
      end
    end
  end

  shell_utils_ucc_v1_0_0_shutdown_latch
    #(
        .C_ENABLE_SHUTDOWN_CLEARING(1)
      ) clock_shutdown_latch
       (.Clk(aclk_ctrl),
        .Request_Ack(request_ack),
        .Request_Gate_En(throttling_enabled),
        .Request_Latch(request_latch),
        .Request_SC(shutdown_clocks),
        .Request_SW(Request_SW),
        .Rst(aresetn_ctrl),
        .Shutdown_Latch(shutdown_latch));

  shell_utils_ucc_v1_0_0_throttling_avg
    #(
        .SAMPLE_WIDTH(8),
        .SAMPLE_SAT_VAL(128),
        .AVE_NUM_SAMPLES(50),
        .AVE_WIDTH(14),
        .RST_CNT_BITS(6)
     ) clock_throttling_avg
       (.Clk(aclk_ctrl),
        .Rate(gapping_demand),
        .Rate_Avg(clock_throttling_average),
        .Rate_Upd_Tog(gapping_demand_toggle),
        .Rst(aresetn_ctrl));

  xpm_cdc_async_rst #(
      .DEST_SYNC_FF(3),    // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .RST_ACTIVE_HIGH(0)  // DECIMAL; 0=active low reset, 1=active high reset
  ) psreset_aclk_freerun (
      .dest_arst(aresetn_aclk_freerun),
      .dest_clk(aclk_freerun),   // 1-bit input: Destination clock.
      .src_arst(aresetn_ctrl)    // 1-bit input: Source asynchronous reset signal.
  );

endmodule


