// Copyright (C) 2024 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT

// This implements an AXI register for the UUID on Embedded-Plus
// with one port read/write and one port read only.

`timescale 1 ns / 1 ps

module uuid_register #
(
    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH  = 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH  = 12

)
(
    // Users to add ports here


    // Global Clock Signal
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,

    //***************************************************
    // Read/Write port 0
    //***************************************************
    // Write address (issued by master, accepted by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S0_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
    input wire [2 : 0] S0_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
    input wire  S0_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
    output wire  S0_AXI_AWREADY,
    // Write data (issued by master, accepted by Slave)
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S0_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S0_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
        // data and strobes are available.
    input wire  S0_AXI_WVALID,
    // Write ready. This signal indicates that the slave
        // can accept the write data.
    output wire  S0_AXI_WREADY,
    // Write response. This signal indicates the status
        // of the write transaction.
    output wire [1 : 0] S0_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
    output wire  S0_AXI_BVALID,
    // Response ready. This signal indicates that the master
        // can accept a write response.
    input wire  S0_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S0_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
    input wire [2 : 0] S0_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
    input wire  S0_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
    output wire  S0_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S0_AXI_RDATA,
    // Read response. This signal indicates the status of the
        // read transfer.
    output wire [1 : 0] S0_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
        // signaling the required read data.
    output wire  S0_AXI_RVALID,
    // Read ready. This signal indicates that the master can
        // accept the read data and response information.
    input wire  S0_AXI_RREADY,

    //***************************************************
    // Read only port 1
    //***************************************************

    // Write address (issued by master, accepted by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S1_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
    input wire [2 : 0] S1_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
    input wire  S1_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
    output wire  S1_AXI_AWREADY,
    // Write data (issued by master, accepted by Slave)
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S1_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S1_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
        // data and strobes are available.
    input wire  S1_AXI_WVALID,
    // Write ready. This signal indicates that the slave
        // can accept the write data.
    output wire  S1_AXI_WREADY,
    // Write response. This signal indicates the status
        // of the write transaction.
    output wire [1 : 0] S1_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
    output wire  S1_AXI_BVALID,
    // Response ready. This signal indicates that the master
        // can accept a write response.
    input wire  S1_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S1_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
    input wire [2 : 0] S1_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
    input wire  S1_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
    output wire  S1_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S1_AXI_RDATA,
    // Read response. This signal indicates the status of the
        // read transfer.
    output wire [1 : 0] S1_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
        // signaling the required read data.
    output wire  S1_AXI_RVALID,
    // Read ready. This signal indicates that the master can
        // accept the read data and response information.
    input wire  S1_AXI_RREADY

);

  // AXI4LITE signals (R/W)
  reg [C_S_AXI_ADDR_WIDTH-1 : 0]  s00_axi_awaddr;
  reg   s00_axi_awready;
  reg   s00_axi_wready;
  reg [1 : 0]   s00_axi_bresp;
  reg   s00_axi_bvalid;
  reg [C_S_AXI_ADDR_WIDTH-1 : 0]  s00_axi_araddr;
  reg   s00_axi_arready;
  reg [C_S_AXI_DATA_WIDTH-1 : 0]  s00_axi_rdata;
  reg [1 : 0]   s00_axi_rresp;
  reg   s00_axi_rvalid;
  // AXI4LITE signals (Read only)
  reg [C_S_AXI_ADDR_WIDTH-1 : 0]  s01_axi_awaddr;
  reg   s01_axi_awready;
  reg   s01_axi_wready;
  reg [1 : 0]   s01_axi_bresp;
  reg   s01_axi_bvalid;
  reg [C_S_AXI_ADDR_WIDTH-1 : 0]  s01_axi_araddr;
  reg   s01_axi_arready;
  reg [C_S_AXI_DATA_WIDTH-1 : 0]  s01_axi_rdata;
  reg [1 : 0]   s01_axi_rresp;
  reg   s01_axi_rvalid;

  // Example-specific design signals
  // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  // ADDR_LSB is used for addressing 32/64 bit registers/memories
  // ADDR_LSB = 2 for 32 bits (n downto 2)
  // ADDR_LSB = 3 for 64 bits (n downto 3)
  localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
  localparam integer OPT_MEM_ADDR_BITS = 8;
  // Only Offset = 0 is supported

  //----------------------------------------------
  //-- Signals for user logic register space example
  //------------------------------------------------
  //-- Read/Write
  reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg0;  // UUID Register - Addr = 'h0


  reg [C_S_AXI_DATA_WIDTH-1:0] s00_reg_data_out;
  reg [C_S_AXI_DATA_WIDTH-1:0] s01_reg_data_out;

  wire  s00_slv_reg_rden;
  wire  s00_slv_reg_wren;
  wire  s01_slv_reg_rden;
  wire  s01_slv_reg_wren = 1'b0;

  integer  byte_index;
  reg  s00_aw_en = 1'b1;
  reg  s01_aw_en = 1'b1;

  // I/O Connections assignments

  assign S0_AXI_AWREADY  = s00_axi_awready;
  assign S0_AXI_WREADY = s00_axi_wready;
  assign S0_AXI_BRESP  = s00_axi_bresp;
  assign S0_AXI_BVALID = s00_axi_bvalid;
  assign S0_AXI_ARREADY  = s00_axi_arready;
  assign S0_AXI_RDATA  = s00_axi_rdata;
  assign S0_AXI_RRESP  = s00_axi_rresp;
  assign S0_AXI_RVALID = s00_axi_rvalid;

  assign S1_AXI_AWREADY  = s01_axi_awready;
  assign S1_AXI_WREADY = s01_axi_wready;
  assign S1_AXI_BRESP  = s01_axi_bresp;
  assign S1_AXI_BVALID = s01_axi_bvalid;
  assign S1_AXI_ARREADY  = s01_axi_arready;
  assign S1_AXI_RDATA  = s01_axi_rdata;
  assign S1_AXI_RRESP  = s01_axi_rresp;
  assign S1_AXI_RVALID = s01_axi_rvalid;

  // Implement s00_axi_awready generation
  // s00_axi_awready is asserted for one S_AXI_ACLK clock cycle when both
  // S0_AXI_AWVALID and S0_AXI_WVALID are asserted. s00_axi_awready is
  // de-asserted when reset is low.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s00_axi_awready <= 1'b0;
        s00_aw_en <= 1'b1;
      end
    else
      begin
        if (~s00_axi_awready && S0_AXI_AWVALID && S0_AXI_WVALID && s00_aw_en)
          begin
            // slave is ready to accept write address when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            s00_axi_awready <= 1'b1;
            s00_aw_en <= 1'b0;
          end
          else if (S0_AXI_BREADY && s00_axi_bvalid)
              begin
                s00_aw_en <= 1'b1;
                s00_axi_awready <= 1'b0;
              end
        else
          begin
            s00_axi_awready <= 1'b0;
          end
      end
  end

  // Implement axi_awaddr latching
  // This process is used to latch the address when both
  // S0_AXI_AWVALID and S0_AXI_WVALID are valid.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s00_axi_awaddr <= 0;
      end
    else
      begin
        if (~s00_axi_awready && S0_AXI_AWVALID && S0_AXI_WVALID && s00_aw_en)
          begin
            // Write Address latching
            s00_axi_awaddr <= S0_AXI_AWADDR;
          end
      end
  end

  // Implement s00_axi_wready generation
  // s00_axi_wready is asserted for one S_AXI_ACLK clock cycle when both
  // S0_AXI_AWVALID and S0_AXI_WVALID are asserted. s00_axi_wready is
  // de-asserted when reset is low.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s00_axi_wready <= 1'b0;
      end
    else
      begin
        if (~s00_axi_wready && S0_AXI_WVALID && S0_AXI_AWVALID && s00_aw_en )
          begin
            // slave is ready to accept write data when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            s00_axi_wready <= 1'b1;
          end
        else
          begin
            s00_axi_wready <= 1'b0;
          end
      end
  end

  // Implement memory mapped register select and write logic generation
  // The write data is accepted and written to memory mapped registers when
  // axi_awready, S0_AXI_WVALID, s00_axi_wready and S0_AXI_WVALID are asserted.
  // Write strobes are used to select byte enables of slave registers while writing.
  // These registers are cleared when reset (active low) is applied.
  // Slave register write enable is asserted when valid address and data are available
  // and the slave is ready to accept the write address and write data.
  assign s00_slv_reg_wren = s00_axi_wready && S0_AXI_WVALID && s00_axi_awready && S0_AXI_AWVALID;

  // Implement write response logic generation
  // The write response and response valid signals are asserted by the slave
  // when s00_axi_wready, S0_AXI_WVALID, s00_axi_wready and S0_AXI_WVALID are asserted.
  // This marks the acceptance of address and indicates the status of
  // write transaction.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s00_axi_bvalid  <= 0;
        s00_axi_bresp   <= 2'b0;
      end
    else
      begin
        if (s00_axi_awready && S0_AXI_AWVALID && ~s00_axi_bvalid && s00_axi_wready && S0_AXI_WVALID)
          begin
            // indicates a valid write response is available
            s00_axi_bvalid <= 1'b1;
            s00_axi_bresp  <= 2'b0; // 'OKAY' response
          end                   // work error responses in future
        else
          begin
            if (S0_AXI_BREADY && s00_axi_bvalid)
              //check if bready is asserted while bvalid is high)
              //(there is a possibility that bready is always asserted high)
              begin
                s00_axi_bvalid <= 1'b0;
              end
          end
      end
  end

  // Implement axi_arready generation
  // axi_arready is asserted for one S_AXI_ACLK clock cycle when
  // S0_AXI_ARVALID is asserted. axi_awready is
  // de-asserted when reset (active low) is asserted.
  // The read address is also latched when S0_AXI_ARVALID is
  // asserted. axi_araddr is reset to zero on reset assertion.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s00_axi_arready <= 1'b0;
        s00_axi_araddr  <= 32'b0;
      end
    else
      begin
        if (~s00_axi_arready && S0_AXI_ARVALID)
          begin
            // indicates that the slave has acceped the valid read address
            s00_axi_arready <= 1'b1;
            // Read address latching
            s00_axi_araddr  <= S0_AXI_ARADDR;
          end
        else
          begin
            s00_axi_arready <= 1'b0;
          end
      end
  end

  // Implement axi_arvalid generation
  // s00_axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
  // S0_AXI_ARVALID and s00_axi_arready are asserted. The slave registers
  // data are available on the s00_axi_rdata bus at this instance. The
  // assertion of s00_axi_rvalid marks the validity of read data on the
  // bus and s00_axi_rresp indicates the status of read transaction.s00_axi_rvalid
  // is deasserted on reset (active low). s00_axi_rresp and s00_axi_rdata are
  // cleared to zero on reset (active low).
  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s00_axi_rvalid <= 0;
        s00_axi_rresp  <= 0;
      end
    else
      begin
        if (s00_axi_arready && S0_AXI_ARVALID && ~s00_axi_rvalid)
          begin
            // Valid read data is available at the read data bus
            s00_axi_rvalid <= 1'b1;
            s00_axi_rresp  <= 2'b0; // 'OKAY' response
          end
        else if (s00_axi_rvalid && S0_AXI_RREADY)
          begin
            // Read data is accepted by the master
            s00_axi_rvalid <= 1'b0;
          end
      end
  end

  // Implement memory mapped register select and read logic generation
  // Slave register read enable is asserted when valid address is available
  // and the slave is ready to accept the read address.
  assign s00_slv_reg_rden = s00_axi_arready & S0_AXI_ARVALID & ~s00_axi_rvalid;

  // Output register or memory read data
  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s00_axi_rdata  <= 0;
      end
    else
      begin
        // When there is a valid read address (S0_AXI_ARVALID) with
        // acceptance of read address by the slave (axi_arready),
        // output the read data
        if (s00_slv_reg_rden)
          begin
            s00_axi_rdata <= s00_reg_data_out[0 +: C_S_AXI_DATA_WIDTH];  // register read data
          end
      end
  end

  always @(*)
  begin
    // Address decoding for reading registers
    case ( s00_axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
      4'h0   : s00_reg_data_out[0+:32] <= slv_reg0[0+:32];
      default : s00_reg_data_out[0+:32] <= 0;
    endcase
  end

  always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          slv_reg0[0+:32] <= 32'h0; // UUID Register
        end
      else
        begin
          if (s00_slv_reg_wren)
            begin
                case ( s00_axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
                  4'h0:
                    for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                      if ( S0_AXI_WSTRB[byte_index] == 1 ) begin
                        // Respective byte enables are asserted as per write strobes
                        // Slave register 0
                        slv_reg0[(byte_index*8) +: 8] <= S0_AXI_WDATA[(byte_index*8) +: 8];
                      end
                  default :
                    begin
                      slv_reg0[0+:32] <= slv_reg0[0+:32];
                    end
                endcase
            end
        end
    end

// Read only logic

  // Implement s00_axi_awready generation
  // s00_axi_awready is asserted for one S_AXI_ACLK clock cycle when both
  // S0_AXI_AWVALID and S0_AXI_WVALID are asserted. s00_axi_awready is
  // de-asserted when reset is low.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s01_axi_awready <= 1'b0;
        s01_aw_en <= 1'b1;
      end
    else
      begin
        if (~s01_axi_awready && S1_AXI_AWVALID && S1_AXI_WVALID && s01_aw_en)
          begin
            // slave is ready to accept write address when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            s01_axi_awready <= 1'b1;
            s01_aw_en <= 1'b0;
          end
          else if (S1_AXI_BREADY && s01_axi_bvalid)
              begin
                s01_aw_en <= 1'b1;
                s01_axi_awready <= 1'b0;
              end
        else
          begin
            s01_axi_awready <= 1'b0;
          end
      end
  end

  // Implement s01_axi_awaddr latching
  // This process is used to latch the address when both
  // S1_AXI_AWVALID and S1_AXI_WVALID are valid.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s01_axi_awaddr <= 0;
      end
    else
      begin
        if (~s01_axi_awready && S1_AXI_AWVALID && S1_AXI_WVALID && s01_aw_en)
          begin
            // Write Address latching
            s01_axi_awaddr <= S1_AXI_AWADDR;
          end
      end
  end

  // Implement s01_axi_wready generation
  // s01_axi_wready is asserted for one S_AXI_ACLK clock cycle when both
  // S0_AXI_AWVALID and S0_AXI_WVALID are asserted. s01_axi_wready is
  // de-asserted when reset is low.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s01_axi_wready <= 1'b0;
      end
    else
      begin
        if (~s01_axi_wready && S1_AXI_WVALID && S1_AXI_AWVALID && s01_aw_en )
          begin
            // slave is ready to accept write data when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            s01_axi_wready <= 1'b1;
          end
        else
          begin
            s01_axi_wready <= 1'b0;
          end
      end
  end

  // Implement memory mapped register select and write logic generation
  // The write data is accepted and written to memory mapped registers when
  // axi_awready, S0_AXI_WVALID, s01_axi_wready and S0_AXI_WVALID are asserted.
  // Write strobes are used to select byte enables of slave registers while writing.
  // These registers are cleared when reset (active low) is applied.
  // Slave register write enable is asserted when valid address and data are available
  // and the slave is ready to accept the write address and write data.
  //assign s01_slv_reg_wren = s01_axi_wready && S1_AXI_WVALID && s01_axi_awready && S1_AXI_AWVALID;

  // Implement write response logic generation
  // The write response and response valid signals are asserted by the slave
  // when s01_axi_wready, S0_AXI_WVALID, s01_axi_wready and S0_AXI_WVALID are asserted.
  // This marks the acceptance of address and indicates the status of
  // write transaction.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s01_axi_bvalid  <= 0;
        s01_axi_bresp   <= 2'b0;
      end
    else
      begin
        if (s01_axi_awready && S1_AXI_AWVALID && ~s01_axi_bvalid && s01_axi_wready && S0_AXI_WVALID)
          begin
            // indicates a valid write response is available
            s01_axi_bvalid <= 1'b1;
            s01_axi_bresp  <= 2'b0; // 'OKAY' response
          end                   // work error responses in future
        else
          begin
            if (S1_AXI_BREADY && s01_axi_bvalid)
              //check if bready is asserted while bvalid is high)
              //(there is a possibility that bready is always asserted high)
              begin
                s01_axi_bvalid <= 1'b0;
              end
          end
      end
  end

  // Implement s01_axi_arready generation
  // s01_axi_arready is asserted for one S_AXI_ACLK clock cycle when
  // S0_AXI_ARVALID is asserted. s01_axi_awready is
  // de-asserted when reset (active low) is asserted.
  // The read address is also latched when S0_AXI_ARVALID is
  // asserted. s01_axi_araddr is reset to zero on reset assertion.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s01_axi_arready <= 1'b0;
        s00_axi_araddr  <= 32'b0;
      end
    else
      begin
        if (~s01_axi_arready && S1_AXI_ARVALID)
          begin
            // indicates that the slave has acceped the valid read address
            s01_axi_arready <= 1'b1;
            // Read address latching
            s01_axi_araddr  <= S1_AXI_ARADDR;
          end
        else
          begin
            s01_axi_arready <= 1'b0;
          end
      end
  end

  // Implement axi_arvalid generation
  // s00_axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
  // S0_AXI_ARVALID and s00_axi_arready are asserted. The slave registers
  // data are available on the s00_axi_rdata bus at this instance. The
  // assertion of s00_axi_rvalid marks the validity of read data on the
  // bus and s00_axi_rresp indicates the status of read transaction.s00_axi_rvalid
  // is deasserted on reset (active low). s00_axi_rresp and s00_axi_rdata are
  // cleared to zero on reset (active low).
  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s01_axi_rvalid <= 0;
        s01_axi_rresp  <= 0;
      end
    else
      begin
        if (s01_axi_arready && S1_AXI_ARVALID && ~s01_axi_rvalid)
          begin
            // Valid read data is available at the read data bus
            s01_axi_rvalid <= 1'b1;
            s01_axi_rresp  <= 2'b0; // 'OKAY' response
          end
        else if (s01_axi_rvalid && S1_AXI_RREADY)
          begin
            // Read data is accepted by the master
            s01_axi_rvalid <= 1'b0;
          end
      end
  end

  // Implement memory mapped register select and read logic generation
  // Slave register read enable is asserted when valid address is available
  // and the slave is ready to accept the read address.
  assign s01_slv_reg_rden = s01_axi_arready & S1_AXI_ARVALID & ~s01_axi_rvalid;

  // Output register or memory read data
  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        s01_axi_rdata  <= 0;
      end
    else
      begin
        // When there is a valid read address (S0_AXI_ARVALID) with
        // acceptance of read address by the slave (axi_arready),
        // output the read data
        if (s01_slv_reg_rden)
          begin
            s01_axi_rdata <= s01_reg_data_out[0 +: C_S_AXI_DATA_WIDTH];  // register read data
          end
      end
  end

  always @(*)
  begin
    // Address decoding for reading registers
    case ( s01_axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
      4'h0   : s01_reg_data_out[0+:32] <= slv_reg0[0+:32];
      default : s01_reg_data_out[0+:32] <= 0;
    endcase
  end


endmodule