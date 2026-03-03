-- Copyright (C) 2023 Advanced Micro Devices, Inc.
-- SPDX-License-Identifier: MIT

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_misc.all;
    use ieee.numeric_std.all;

library hw_discovery_v1_0_1;

entity hw_discovery_v1_0_1_pcie_vsec is
    generic(
    	  C_NUM_PFS                 : integer range 1 to 4           := 1;
        C_CAP_BASE_ADDR           : std_logic_vector(11 downto 0)  := x"480"; -- 0x480 default for PCIE4
        C_NEXT_CAP_ADDR           : std_logic_vector(11 downto 0)  := (others => '0');
        C_PF0_BAR_INDEX           : integer range 0 to 6           := 0;
        C_PF0_LOW_OFFSET          : std_logic_vector(27 downto 0)  := (others => '0');
        C_PF0_HIGH_OFFSET         : std_logic_vector(31 downto 0)  := (others => '0');
        C_PF1_BAR_INDEX           : integer range 0 to 6           := 0;
        C_PF1_LOW_OFFSET          : std_logic_vector(27 downto 0)  := (others => '0');
        C_PF1_HIGH_OFFSET         : std_logic_vector(31 downto 0)  := (others => '0');
        C_PF2_BAR_INDEX           : integer range 0 to 6           := 0;
        C_PF2_LOW_OFFSET          : std_logic_vector(27 downto 0)  := (others => '0');
        C_PF2_HIGH_OFFSET         : std_logic_vector(31 downto 0)  := (others => '0');
        C_PF3_BAR_INDEX           : integer range 0 to 6           := 0;
        C_PF3_LOW_OFFSET          : std_logic_vector(27 downto 0)  := (others => '0');
        C_PF3_HIGH_OFFSET         : std_logic_vector(31 downto 0)  := (others => '0');
        C_XDEVICEFAMILY           : string                         := "no_family"
    );
    port(

        -----------------------------------------------------------------------
        -- Clocks & Resets
        -----------------------------------------------------------------------

        aclk_pcie                  								: in  std_logic;
        aresetn_pcie               								: in  std_logic;

        -----------------------------------------------------------------------
        -- pcie4_cfg_ext Interface (aclk_pcie)
        -----------------------------------------------------------------------

        s_pcie4_cfg_ext_function_number           : in  std_logic_vector(7 downto 0);
        s_pcie4_cfg_ext_read_data                 : out std_logic_vector(31 downto 0);
        s_pcie4_cfg_ext_read_data_valid           : out std_logic;
        s_pcie4_cfg_ext_read_received             : in  std_logic;
        s_pcie4_cfg_ext_register_number           : in  std_logic_vector(9 downto 0);
        s_pcie4_cfg_ext_write_byte_enable         : in  std_logic_vector(3 downto 0);
        s_pcie4_cfg_ext_write_data                : in  std_logic_vector(31 downto 0);
        s_pcie4_cfg_ext_write_received            : in  std_logic;

        -----------------------------------------------------------------------
        -- pcie4_cfg_ext Interface (aclk_pcie)
        -----------------------------------------------------------------------

        m_pcie4_cfg_ext_function_number           : out std_logic_vector(7 downto 0);
        m_pcie4_cfg_ext_read_data                 : in  std_logic_vector(31 downto 0);
        m_pcie4_cfg_ext_read_data_valid           : in  std_logic;
        m_pcie4_cfg_ext_read_received             : out std_logic;
        m_pcie4_cfg_ext_register_number           : out std_logic_vector(9 downto 0);
        m_pcie4_cfg_ext_write_byte_enable         : out std_logic_vector(3 downto 0);
        m_pcie4_cfg_ext_write_data                : out std_logic_vector(31 downto 0);
        m_pcie4_cfg_ext_write_received            : out std_logic

    );
end entity hw_discovery_v1_0_1_pcie_vsec;

architecture rtl of hw_discovery_v1_0_1_pcie_vsec is

-------------------------------------------------------------------------------
--
--      CONSTANTS
--
-------------------------------------------------------------------------------

constant  CAP_ID                : std_logic_vector(15 downto 0)             								:= x"000B";
constant  CAP_VERSION           : std_logic_vector(3 downto 0)              								:= x"1";
constant  VSEC_ID               : std_logic_vector(15 downto 0)             								:= x"0020";
constant  VSEC_REV              : std_logic_vector(3 downto 0)              								:= x"0";
constant  VSEC_LENGTH           : std_logic_vector(11 downto 0)             								:= x"010";
constant  NEXT_CAP_BASE_ADDR    : integer                              											:= (to_integer(unsigned(C_CAP_BASE_ADDR)) + 16);
constant  NEXT_CAP_CONFIG_ADDR  : integer                              											:= (to_integer(unsigned(C_NEXT_CAP_ADDR)));
constant  CAP_BASE_BYTE_ADDR    : integer                                   								:= (to_integer(unsigned(C_CAP_BASE_ADDR)) / 4);
constant  CAP_BASE_ADDR         : integer                                   								:= (to_integer(unsigned(C_CAP_BASE_ADDR)) / 16);
constant  ALF_VSEC_NXT_REG      : std_logic_vector(11 downto 0)   													:= std_logic_vector(to_unsigned(NEXT_CAP_BASE_ADDR, 12));
constant  ALF_VSEC_CONFIG_NXT   : std_logic_vector(11 downto 0)   													:= std_logic_vector(to_unsigned(NEXT_CAP_CONFIG_ADDR, 12));
constant  ALF_VSEC_BASE_REG     : std_logic_vector(7 downto 0)   														:= std_logic_vector(to_unsigned(CAP_BASE_ADDR, 8));
constant  ALF_VSEC_REG_0        : std_logic_vector(s_pcie4_cfg_ext_register_number'RANGE)   := std_logic_vector(to_unsigned(CAP_BASE_BYTE_ADDR, s_pcie4_cfg_ext_register_number'LENGTH));
constant  ALF_VSEC_REG_1        : std_logic_vector(s_pcie4_cfg_ext_register_number'RANGE)   := std_logic_vector(to_unsigned((CAP_BASE_BYTE_ADDR + 1), s_pcie4_cfg_ext_register_number'LENGTH));
constant  ALF_VSEC_REG_2        : std_logic_vector(s_pcie4_cfg_ext_register_number'RANGE)   := std_logic_vector(to_unsigned((CAP_BASE_BYTE_ADDR + 2), s_pcie4_cfg_ext_register_number'LENGTH));
constant  ALF_VSEC_REG_3        : std_logic_vector(s_pcie4_cfg_ext_register_number'RANGE)   := std_logic_vector(to_unsigned((CAP_BASE_BYTE_ADDR + 3), s_pcie4_cfg_ext_register_number'LENGTH));
constant  PF0_BAR_INDEX         : std_logic_vector(2 downto 0)              								:= std_logic_vector(to_unsigned(C_PF0_BAR_INDEX, 3));
constant  PF1_BAR_INDEX         : std_logic_vector(2 downto 0)              								:= std_logic_vector(to_unsigned(C_PF1_BAR_INDEX, 3));
constant  PF2_BAR_INDEX         : std_logic_vector(2 downto 0)              								:= std_logic_vector(to_unsigned(C_PF2_BAR_INDEX, 3));
constant  PF3_BAR_INDEX         : std_logic_vector(2 downto 0)              								:= std_logic_vector(to_unsigned(C_PF3_BAR_INDEX, 3));
constant  NUM_PFS               : std_logic_vector(1 downto 0)  														:= std_logic_vector(to_unsigned((C_NUM_PFS - 1), 2));

-------------------------------------------------------------------------------
--
--      SIGNALS
--
-------------------------------------------------------------------------------

signal cfg_ext_read_data   			: std_logic_vector(31 downto 0)		:= (others => '0');
signal cfg_ext_read_data_valid  : std_logic                     	:= '0';

signal enable_m_cfg_ext  : std_logic                     	:= '0';

begin

	G_GENERATE_M_PCIE4_NXT_CFG_EXT : if (NEXT_CAP_CONFIG_ADDR >= NEXT_CAP_BASE_ADDR) generate

		CF:
		process(aclk_pcie)

			begin

	    	if (rising_edge(aclk_pcie)) then

					m_pcie4_cfg_ext_function_number   <= s_pcie4_cfg_ext_function_number;
					m_pcie4_cfg_ext_read_received     <= s_pcie4_cfg_ext_read_received;
					m_pcie4_cfg_ext_register_number   <= s_pcie4_cfg_ext_register_number;
					m_pcie4_cfg_ext_write_byte_enable <= s_pcie4_cfg_ext_write_byte_enable;
					m_pcie4_cfg_ext_write_data        <= s_pcie4_cfg_ext_write_data;
					m_pcie4_cfg_ext_write_received    <= s_pcie4_cfg_ext_write_received;

					if (enable_m_cfg_ext = '1') then
  					s_pcie4_cfg_ext_read_data								<= m_pcie4_cfg_ext_read_data;
  					s_pcie4_cfg_ext_read_data_valid					<= m_pcie4_cfg_ext_read_data_valid;
  				else
  					s_pcie4_cfg_ext_read_data         <= cfg_ext_read_data;
  					s_pcie4_cfg_ext_read_data_valid   <= cfg_ext_read_data_valid;
  				end if;

				end if;

		end process;

	end generate G_GENERATE_M_PCIE4_NXT_CFG_EXT;

	G_GENERATE_M_PCIE4_CFG_EXT : if (NEXT_CAP_CONFIG_ADDR < NEXT_CAP_BASE_ADDR) generate

		CF:
		process(aclk_pcie)

			begin

	    	if (rising_edge(aclk_pcie)) then

					s_pcie4_cfg_ext_read_data         <= cfg_ext_read_data;
					s_pcie4_cfg_ext_read_data_valid   <= cfg_ext_read_data_valid;

					m_pcie4_cfg_ext_function_number   <= (others => '0');
					m_pcie4_cfg_ext_read_received     <= '0';
					m_pcie4_cfg_ext_register_number   <= (others => '0');
					m_pcie4_cfg_ext_write_byte_enable <= (others => '0');
					m_pcie4_cfg_ext_write_data        <= (others => '0');
					m_pcie4_cfg_ext_write_received    <= '0';

				end if;

		end process;

	end generate G_GENERATE_M_PCIE4_CFG_EXT;

	RD:
	process(aclk_pcie)

	  variable func_num_var : std_logic_vector(1 downto 0);
	  variable reg_num_var  : std_logic_vector(1 downto 0);

	begin

	    if (rising_edge(aclk_pcie)) then

        if (aresetn_pcie = '0') then
	        cfg_ext_read_data_valid   <= '0';
	        cfg_ext_read_data         <= (others => '0');
	        func_num_var      				:= s_pcie4_cfg_ext_function_number(1 downto 0);
	        reg_num_var      					:= s_pcie4_cfg_ext_register_number(1 downto 0);
				  enable_m_cfg_ext          <= '0';
          cfg_ext_read_data_valid <= '0';
          cfg_ext_read_data       <= (others => '0');

				else

	        -- default assignment
	        cfg_ext_read_data_valid   <= '0';
	        cfg_ext_read_data         <= (others => '0');
	        func_num_var      				:= s_pcie4_cfg_ext_function_number(1 downto 0);
	        reg_num_var      					:= s_pcie4_cfg_ext_register_number(1 downto 0);

	        if (s_pcie4_cfg_ext_read_received = '1') then

  					  enable_m_cfg_ext          <= '0';
	        		if (s_pcie4_cfg_ext_register_number(9 downto 2) = ALF_VSEC_BASE_REG) then

		            -- default read response
		            cfg_ext_read_data_valid <= '1';
		            cfg_ext_read_data       <= (others => '0');

		            case func_num_var is

									when "00" => -- PF0

		             		case reg_num_var is

		             		  when "00" =>

		             		    -- PF0 Extended Capability Header

		             		    cfg_ext_read_data   <= C_NEXT_CAP_ADDR & CAP_VERSION & CAP_ID;

		             		  when "01" =>

		             		    -- VSEC Header - Identifies as Xilinx Additional List of Features (ALF)

		             		 		cfg_ext_read_data   <= VSEC_LENGTH & VSEC_REV & VSEC_ID;

		             		  when "10" =>

		             		    -- ALF Field 1 (BAR Index & Low Offset)

		             		  	cfg_ext_read_data   <= C_PF0_LOW_OFFSET & '0' & PF0_BAR_INDEX;

		             		  when others =>

		             		    -- ALF Field 2 (High Offset)

		             		    cfg_ext_read_data   <= C_PF0_HIGH_OFFSET;

		             		end case;

									when "01" => -- PF2

										if (NUM_PFS > "00") then

		             			case reg_num_var is

		             			  when "00" =>

		             			    -- PF1 Extended Capability Header

		             			    cfg_ext_read_data   <= C_NEXT_CAP_ADDR & CAP_VERSION & CAP_ID;

		             			  when "01" =>

		             			    -- VSEC Header - Identifies as Xilinx Additional List of Features (ALF)

		             			 		cfg_ext_read_data   <= VSEC_LENGTH & VSEC_REV & VSEC_ID;

		             			  when "10" =>

		             			    -- ALF Field 1 (BAR Index & Low Offset)

		             			  	cfg_ext_read_data   <= C_PF1_LOW_OFFSET & '0' & PF1_BAR_INDEX;

		             			  when others =>

		             			    -- ALF Field 2 (High Offset)

		             			    cfg_ext_read_data   <= C_PF1_HIGH_OFFSET;

		             			end case;

										end if;

									when "10" => -- PF2

										if (NUM_PFS(1) = '1') then

		             			case reg_num_var is

		             			  when "00" =>

		             			    -- PF0 Extended Capability Header

		             			    cfg_ext_read_data   <= C_NEXT_CAP_ADDR & CAP_VERSION & CAP_ID;

		             			  when "01" =>

		             			    -- VSEC Header - Identifies as Xilinx Additional List of Features (ALF)

		             			 		cfg_ext_read_data   <= VSEC_LENGTH & VSEC_REV & VSEC_ID;

		             			  when "10" =>

		             			    -- ALF Field 1 (BAR Index & Low Offset)

		             			  	cfg_ext_read_data   <= C_PF2_LOW_OFFSET & '0' & PF2_BAR_INDEX;

		             			  when others =>

		             			    -- ALF Field 2 (High Offset)

		             			    cfg_ext_read_data   <= C_PF2_HIGH_OFFSET;

		             			end case;

										end if;

									when others => -- PF3

										if (NUM_PFS = "11") then

		             			case reg_num_var is

		             			  when "00" =>

		             			    -- PF0 Extended Capability Header

		             			    cfg_ext_read_data   <= C_NEXT_CAP_ADDR & CAP_VERSION & CAP_ID;

		             			  when "01" =>

		             			    -- VSEC Header - Identifies as Xilinx Additional List of Features (ALF)

		             			 		cfg_ext_read_data   <= VSEC_LENGTH & VSEC_REV & VSEC_ID;

		             			  when "10" =>

		             			    -- ALF Field 1 (BAR Index & Low Offset)

		             			  	cfg_ext_read_data   <= C_PF3_LOW_OFFSET & '0' & PF3_BAR_INDEX;

		             			  when others =>

		             			    -- ALF Field 2 (High Offset)

		             			    cfg_ext_read_data   <= C_PF3_HIGH_OFFSET;

		             			end case;

									end if;

		            end case;

						elsif (NEXT_CAP_CONFIG_ADDR < NEXT_CAP_BASE_ADDR) then

	            cfg_ext_read_data_valid <= '1';
	            cfg_ext_read_data       <= (others => '0');

						elsif (s_pcie4_cfg_ext_register_number(9 downto 2) >= ALF_VSEC_CONFIG_NXT(11 downto 4)) then

							enable_m_cfg_ext        <= '1';
		        	cfg_ext_read_data_valid <= '0';
		        	cfg_ext_read_data       <= (others => '0');

						else

	            cfg_ext_read_data_valid <= '1';
	            cfg_ext_read_data       <= (others => '0');

						end if;

	        end if;
        end if;

	    end if;

	end process;

end architecture rtl;


-- (c) Copyright 2022, Advanced Micro Devices, Inc.
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.
------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library axi_lite_ipif_v3_0_4;
    use axi_lite_ipif_v3_0_4.ipif_pkg.all;

library hw_discovery_v1_0_1;

entity hw_discovery_v1_0_1_bar_layout_table is
    generic (
        C_NUM_SLOTS_BAR_LAYOUT_TABLE  : integer range 1 to 16           := 1;
        C_ENTRY_TYPE_0                : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_0                 : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_0                : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_0       : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_0       : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_0        : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_0               : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_1                : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_1                 : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_1                : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_1       : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_1       : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_1        : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_1               : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_2                : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_2                 : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_2                : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_2       : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_2       : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_2        : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_2               : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_3                : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_3                 : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_3                : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_3       : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_3       : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_3        : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_3               : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_4                : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_4                 : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_4                : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_4       : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_4       : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_4        : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_4               : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_5                : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_5                 : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_5                : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_5       : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_5       : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_5        : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_5               : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_6                : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_6                 : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_6                : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_6       : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_6       : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_6        : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_6               : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_7                : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_7                 : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_7                : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_7       : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_7       : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_7        : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_7               : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_8                : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_8                 : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_8                : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_8       : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_8       : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_8        : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_8               : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_9                : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_9                 : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_9                : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_9       : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_9       : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_9        : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_9               : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_10               : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_10                : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_10               : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_10      : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_10      : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_10       : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_10              : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_11               : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_11                : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_11               : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_11      : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_11      : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_11       : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_11              : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_12               : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_12                : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_12               : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_12      : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_12      : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_12       : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_12              : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_13               : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_13                : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_13               : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_13      : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_13      : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_13       : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_13              : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_14               : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_14                : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_14               : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_14      : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_14      : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_14       : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_14              : std_logic_vector(3 downto 0)    := (others => '0');
        C_ENTRY_TYPE_15               : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_BAR_15                : integer range 0 to 6            := 0;
        C_ENTRY_ADDR_15               : std_logic_vector(47 downto 0)   := (others => '0');
        C_ENTRY_MAJOR_VERSION_15      : integer range 0 to 255          := 0;
        C_ENTRY_MINOR_VERSION_15      : integer range 0 to 255          := 0;
        C_ENTRY_VERSION_TYPE_15       : std_logic_vector(7 downto 0)    := (others => '0');
        C_ENTRY_RSVD0_15              : std_logic_vector(3 downto 0)    := (others => '0');
        C_S_AXI_DATA_WIDTH            : integer range 32 to 32          := 32;
        C_S_AXI_ADDR_WIDTH            : integer range 1 to 64           := 32;
        C_XDEVICEFAMILY               : string                          := "no_family"
        );
    port (

        -----------------------------------------------------------------------
        -- Processor AXI Interface (S_AXI_ACLK)
        -----------------------------------------------------------------------

        S_AXI_ACLK                : in  std_logic;
        S_AXI_ARESETN             : in  std_logic;
        S_AXI_AWADDR              : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWVALID             : in  std_logic;
        S_AXI_AWREADY             : out std_logic;
        S_AXI_WDATA               : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB               : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID              : in  std_logic;
        S_AXI_WREADY              : out std_logic;
        S_AXI_BRESP               : out std_logic_vector(1 downto 0);
        S_AXI_BVALID              : out std_logic;
        S_AXI_BREADY              : in  std_logic;
        S_AXI_ARADDR              : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARVALID             : in  std_logic;
        S_AXI_ARREADY             : out std_logic;
        S_AXI_RDATA               : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP               : out std_logic_vector(1 downto 0);
        S_AXI_RVALID              : out std_logic;
        S_AXI_RREADY              : in  std_logic
    );

end hw_discovery_v1_0_1_bar_layout_table;


architecture top of hw_discovery_v1_0_1_bar_layout_table is


    -------------------------------------------------------------------------------
    -- Constant Declarations
    -------------------------------------------------------------------------------

    constant ZEROES : std_logic_vector(0 to 31) := X"00000000";

    constant C_FAMILY : string := C_XDEVICEFAMILY;

    constant REG_BASEADDR : std_logic_vector := X"00000000";

    impure function makemask (Width: INTEGER) return std_logic_vector is
      variable retv: std_logic_vector (31 downto 0) := (others => '0');
      begin
        for i in (Width - 1) downto 0 loop
            retv(i) := '1';
        end loop;
        return retv;
      end function;

    constant REG_HIGHADDR : std_logic_vector(0 to 31) := makemask(C_S_AXI_ADDR_WIDTH);

    constant C_ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE := (
        ZEROES & REG_BASEADDR,
        ZEROES & REG_HIGHADDR
        );

    constant C_ARD_IDX_REGS : integer := 0;

    constant C_ARD_NUM_CE_ARRAY : INTEGER_ARRAY_TYPE := (
        C_ARD_IDX_REGS => 1
        );

    constant C_S_AXI_MIN_SIZE : std_logic_vector(31 downto 0) := makemask(C_S_AXI_ADDR_WIDTH);

    constant C_USE_WSTRB : integer := 0;

    constant C_DPHASE_TIMEOUT : integer := 12;

    subtype IIC_CE_RNG is integer range calc_start_ce_index(C_ARD_NUM_CE_ARRAY, 0) to calc_start_ce_index(C_ARD_NUM_CE_ARRAY, 0) + C_ARD_NUM_CE_ARRAY(0) - 1;

    attribute ram_style : string;

    -- BAR Layout Table ROM type
    type bar_layout_rom_type is array (0 to 63) of std_logic_vector(31 downto 0);
    type rom_header_type is array (0 to 3) of std_logic_vector(31 downto 0);
    type rom_entry_type is array (0 to 63) of std_logic_vector(31 downto 0);

    -- Field Constants
    constant HEADER_FORMAT      : std_logic_vector(19 downto 0)   := x"00001";
    constant HEADER_REV         : std_logic_vector(7 downto 0)    := x"00";
    constant HEADER_LAST_CAP    : std_logic                       := '1';
    constant HEADER_RESERVED    : std_logic_vector(2 downto 0)    := "000";
    constant HEADER_LENGTH      : std_logic_vector(31 downto 0)   := std_logic_vector(to_unsigned((C_NUM_SLOTS_BAR_LAYOUT_TABLE * 16) + 32, 32));
    constant FORMAT_ENTRY_SIZE  : std_logic_vector(7 downto 0)    := x"10";
    constant ENTRY_REVISION     : std_logic_vector(4 downto 0)    := (others => '0');
    constant ENTRY_END_OF_TABLE : std_logic_vector(7 downto 0)    := (others => '1');

    constant ROM_HEADER         : rom_header_type                 := (0 => (HEADER_RESERVED & HEADER_LAST_CAP & HEADER_REV & HEADER_FORMAT),
                                                                      1 => HEADER_LENGTH,
                                                                      2 => (x"000000" & FORMAT_ENTRY_SIZE),
                                                                      3 => (others => '0'));

    constant ROM_ENTRIES        : rom_entry_type                  := (0   => (C_ENTRY_ADDR_0(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_0, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_0),
                                                                      1   => C_ENTRY_ADDR_0(47 downto 16),
                                                                      2   => x"0" & C_ENTRY_RSVD0_0 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_0, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_0, 8)) & C_ENTRY_VERSION_TYPE_0,
                                                                      3   => x"00000000",
                                                                      4   => (C_ENTRY_ADDR_1(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_1, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_1),
                                                                      5   => C_ENTRY_ADDR_1(47 downto 16),
                                                                      6   => x"0" & C_ENTRY_RSVD0_1 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_1, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_1, 8)) & C_ENTRY_VERSION_TYPE_1,
                                                                      7   => x"00000000",
                                                                      8   => (C_ENTRY_ADDR_2(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_2, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_2),
                                                                      9   => C_ENTRY_ADDR_2(47 downto 16),
                                                                      10  => x"0" & C_ENTRY_RSVD0_2 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_2, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_2, 8)) & C_ENTRY_VERSION_TYPE_2,
                                                                      11  => x"00000000",
                                                                      12  => (C_ENTRY_ADDR_3(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_3, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_3),
                                                                      13  => C_ENTRY_ADDR_3(47 downto 16),
                                                                      14  => x"0" & C_ENTRY_RSVD0_3 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_3, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_3, 8)) & C_ENTRY_VERSION_TYPE_3,
                                                                      15  => x"00000000",
                                                                      16  => (C_ENTRY_ADDR_4(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_4, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_4),
                                                                      17  => C_ENTRY_ADDR_4(47 downto 16),
                                                                      18  => x"0" & C_ENTRY_RSVD0_4 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_4, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_4, 8)) & C_ENTRY_VERSION_TYPE_4,
                                                                      19  => x"00000000",
                                                                      20  => (C_ENTRY_ADDR_5(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_5, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_5),
                                                                      21  => C_ENTRY_ADDR_5(47 downto 16),
                                                                      22  => x"0" & C_ENTRY_RSVD0_5 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_5, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_5, 8)) & C_ENTRY_VERSION_TYPE_5,
                                                                      23  => x"00000000",
                                                                      24  => (C_ENTRY_ADDR_6(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_6, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_6),
                                                                      25  => C_ENTRY_ADDR_6(47 downto 16),
                                                                      26  => x"0" & C_ENTRY_RSVD0_6 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_6, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_6, 8)) & C_ENTRY_VERSION_TYPE_6,
                                                                      27  => x"00000000",
                                                                      28  => (C_ENTRY_ADDR_7(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_7, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_7),
                                                                      29  => C_ENTRY_ADDR_7(47 downto 16),
                                                                      30  => x"0" & C_ENTRY_RSVD0_7 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_7, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_7, 8)) & C_ENTRY_VERSION_TYPE_7,
                                                                      31  => x"00000000",
                                                                      32  => (C_ENTRY_ADDR_8(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_8, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_8),
                                                                      33  => C_ENTRY_ADDR_8(47 downto 16),
                                                                      34  => x"0" & C_ENTRY_RSVD0_8 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_8, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_8, 8)) & C_ENTRY_VERSION_TYPE_8,
                                                                      35  => x"00000000",
                                                                      36  => (C_ENTRY_ADDR_9(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_9, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_9),
                                                                      37  => C_ENTRY_ADDR_9(47 downto 16),
                                                                      38  => x"0" & C_ENTRY_RSVD0_9 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_9, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_9, 8)) & C_ENTRY_VERSION_TYPE_9,
                                                                      39  => x"00000000",
                                                                      40  => (C_ENTRY_ADDR_10(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_10, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_10),
                                                                      41  => C_ENTRY_ADDR_10(47 downto 16),
                                                                      42  => x"0" & C_ENTRY_RSVD0_10 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_10, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_10, 8)) & C_ENTRY_VERSION_TYPE_10,
                                                                      43  => x"00000000",
                                                                      44  => (C_ENTRY_ADDR_11(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_11, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_11),
                                                                      45  => C_ENTRY_ADDR_11(47 downto 16),
                                                                      46  => x"0" & C_ENTRY_RSVD0_11 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_11, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_11, 8)) & C_ENTRY_VERSION_TYPE_11,
                                                                      47  => x"00000000",
                                                                      48  => (C_ENTRY_ADDR_12(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_12, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_12),
                                                                      49  => C_ENTRY_ADDR_12(47 downto 16),
                                                                      50  => x"0" & C_ENTRY_RSVD0_12 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_12, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_12, 8)) & C_ENTRY_VERSION_TYPE_12,
                                                                      51  => x"00000000",
                                                                      52  => (C_ENTRY_ADDR_13(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_13, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_13),
                                                                      53  => C_ENTRY_ADDR_13(47 downto 16),
                                                                      54  => x"0" & C_ENTRY_RSVD0_13 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_13, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_13, 8)) & C_ENTRY_VERSION_TYPE_13,
                                                                      55  => x"00000000",
                                                                      56  => (C_ENTRY_ADDR_14(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_14, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_14),
                                                                      57  => C_ENTRY_ADDR_14(47 downto 16),
                                                                      58  => x"0" & C_ENTRY_RSVD0_14 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_14, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_14, 8)) & C_ENTRY_VERSION_TYPE_14,
                                                                      59  => x"00000000",
                                                                      60  => (C_ENTRY_ADDR_15(15 downto 0) & std_logic_vector(to_unsigned(C_ENTRY_BAR_15, 3)) & ENTRY_REVISION & C_ENTRY_TYPE_15),
                                                                      61  => C_ENTRY_ADDR_15(47 downto 16),
                                                                      62  => x"0" & C_ENTRY_RSVD0_15 & std_logic_vector(to_unsigned(C_ENTRY_MAJOR_VERSION_15, 8)) & std_logic_vector(to_unsigned(C_ENTRY_MINOR_VERSION_15, 8)) & C_ENTRY_VERSION_TYPE_15,
                                                                      63  => x"00000000");

    -------------------------------------------------------------------------------
    -- Function Declarations
    -------------------------------------------------------------------------------

    function fn_rom_init return bar_layout_rom_type is

        variable rom  : bar_layout_rom_type := (others => (others => '0'));
        variable j    : integer             := 0;

    begin

        -- Insert the ROM Header & Format Fields
        for i in rom_header_type'RANGE loop

            rom(i)  := ROM_HEADER(i);

        end loop;

        -- Insert the configured table entries
        j := 0;

        for i in 4 to (C_NUM_SLOTS_BAR_LAYOUT_TABLE * 4 + 3) loop

            rom(i)  := ROM_ENTRIES(j);
            j       := j + 1;

        end loop;

        -- Insert the end of table entry
        rom((C_NUM_SLOTS_BAR_LAYOUT_TABLE * 4 + 4)) := x"000000" & ENTRY_END_OF_TABLE;

        return rom;

    end function;

    -------------------------------------------------------------------------------
    -- Signal Declarations
    -------------------------------------------------------------------------------

    signal Bus2IP_Clk           : std_logic                                                                := '0';
    signal Bus2IP_Resetn        : std_logic                                                                := '0';
    signal Bus2IP_Addr          : std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0)                        := (others => '0');
    signal Bus2IP_RNW           : std_logic                                                                := '0';
    signal Bus2IP_BE            : std_logic_vector(((C_S_AXI_DATA_WIDTH/8)-1) downto 0)                    := (others => '0');
    signal Bus2IP_CS            : std_logic_vector(((C_ARD_ADDR_RANGE_ARRAY'length)/2-1) downto 0)         := (others => '0');
    signal Bus2IP_RdCE          : std_logic_vector((calc_num_ce(C_ARD_NUM_CE_ARRAY)-1) downto 0)           := (others => '0');
    signal Bus2IP_WrCE          : std_logic_vector((calc_num_ce(C_ARD_NUM_CE_ARRAY)-1) downto 0)           := (others => '0');
    signal Bus2IP_Data          : std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0)                        := (others => '0');
    signal IP2Bus_Data          : std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0)                        := (others => '0');
    signal IP2Bus_WrAck         : std_logic                                                                := '0';
    signal IP2Bus_RdAck         : std_logic                                                                := '0';
    signal IP2Bus_Error         : std_logic                                                                := '0';
    signal IP2Bus_Ack           : std_logic_vector(1 to 4)                                                 := (others => '0');
    signal BAR_Layout_ROM       : bar_layout_rom_type                                                      := fn_rom_init;

    attribute ram_style of BAR_Layout_ROM       : signal is "distributed";

begin

    axi_lite_ipif_1 : entity axi_lite_ipif_v3_0_4.axi_lite_ipif
        generic map
        (
            C_S_AXI_DATA_WIDTH     => C_S_AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH     => C_S_AXI_ADDR_WIDTH,
            C_S_AXI_MIN_SIZE       => C_S_AXI_MIN_SIZE,
            C_USE_WSTRB            => C_USE_WSTRB,
            C_DPHASE_TIMEOUT       => C_DPHASE_TIMEOUT,
            C_ARD_ADDR_RANGE_ARRAY => C_ARD_ADDR_RANGE_ARRAY,
            C_ARD_NUM_CE_ARRAY     => C_ARD_NUM_CE_ARRAY,
            C_FAMILY               => C_FAMILY
        )
        port map (
            S_AXI_ACLK    => S_AXI_ACLK,
            S_AXI_ARESETN => S_AXI_ARESETN,
            S_AXI_AWADDR  => S_AXI_AWADDR,
            S_AXI_AWVALID => S_AXI_AWVALID,
            S_AXI_AWREADY => S_AXI_AWREADY,
            S_AXI_WDATA   => S_AXI_WDATA,
            S_AXI_WSTRB   => S_AXI_WSTRB,
            S_AXI_WVALID  => S_AXI_WVALID,
            S_AXI_WREADY  => S_AXI_WREADY,
            S_AXI_BRESP   => S_AXI_BRESP,
            S_AXI_BVALID  => S_AXI_BVALID,
            S_AXI_BREADY  => S_AXI_BREADY,
            S_AXI_ARADDR  => S_AXI_ARADDR,
            S_AXI_ARVALID => S_AXI_ARVALID,
            S_AXI_ARREADY => S_AXI_ARREADY,
            S_AXI_RDATA   => S_AXI_RDATA,
            S_AXI_RRESP   => S_AXI_RRESP,
            S_AXI_RVALID  => S_AXI_RVALID,
            S_AXI_RREADY  => S_AXI_RREADY,
            Bus2IP_Clk    => Bus2IP_Clk,
            Bus2IP_Resetn => Bus2IP_Resetn,
            Bus2IP_Addr   => Bus2IP_Addr,
            Bus2IP_RNW    => Bus2IP_RNW,
            Bus2IP_BE     => Bus2IP_BE,
            Bus2IP_CS     => Bus2IP_CS,
            Bus2IP_RdCE   => Bus2IP_RdCE,
            Bus2IP_WrCE   => Bus2IP_WrCE,
            Bus2IP_Data   => Bus2IP_Data,
            IP2Bus_Data   => IP2Bus_Data,
            IP2Bus_WrAck  => IP2Bus_WrAck,
            IP2Bus_RdAck  => IP2Bus_RdAck,
            IP2Bus_Error  => IP2Bus_Error
        );

    axi_dec : process(Bus2IP_Clk)

        variable Addr_Slice1    : std_logic_vector(7 downto 2)   := (others => '0');

    begin

        if rising_edge(Bus2IP_Clk) then

            -- Default assignments
            IP2Bus_Data   <= (others => '0');
            IP2Bus_Ack    <= (others => '0');
            IP2Bus_WrAck  <= '0';
            IP2Bus_RdAck  <= '0';

            if (Bus2IP_CS(0) = '1') then

                Addr_Slice1  := Bus2IP_Addr(Addr_Slice1'RANGE);

                -- Read the BAR Layout Table ROM
                IP2Bus_Data  <= BAR_Layout_ROM(to_integer(unsigned(Addr_Slice1)));

                -- Generate the Ack shift reg
                IP2Bus_Ack   <= '1' & IP2Bus_Ack(1 to IP2Bus_Ack'HIGH-1);

            end if;

            -- Single cycle Rd/Wr Ack to IPIF
            if ((IP2Bus_Ack(3) = '1') and (IP2Bus_Ack(4) = '0')) then

                IP2Bus_WrAck  <= '1';
                IP2Bus_RdAck  <= '1';

            end if;

        end if;

    end process axi_dec;

    IP2Bus_Error <= '0';


end top;


-- (c) Copyright 2022, Advanced Micro Devices, Inc.
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.
------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_misc.all;
    use ieee.numeric_std.all;

library axi_lite_ipif_v3_0_4;
    use axi_lite_ipif_v3_0_4.ipif_pkg.all;

library xpm;
    use xpm.vcomponents.all;

library hw_discovery_v1_0_1;

entity hw_discovery_v1_0_1_hw_disc is
    generic (
    	  C_NUM_PFS                     		: integer range 1 to 4           := 1;
        C_CAP_BASE_ADDR               		: std_logic_vector(11 downto 0)  := x"480"; -- 0x480 default for PCIE4
        C_NEXT_CAP_ADDR           		    : std_logic_vector(11 downto 0)  := (others => '0');
        C_PF0_NUM_SLOTS_BAR_LAYOUT_TABLE  : integer range 1 to 16          := 1;
        C_PF0_BAR_INDEX               		: integer range 0 to 6           := 0;
        C_PF0_LOW_OFFSET              		: std_logic_vector(27 downto 0)  := (others => '0');
        C_PF0_HIGH_OFFSET             		: std_logic_vector(31 downto 0)  := (others => '0');
        C_PF0_ENTRY_TYPE_0                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_0                 : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_0                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_0       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_0       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_0        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_0               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_1                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_1                 : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_1                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_1       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_1       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_1        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_1               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_2                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_2                 : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_2                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_2       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_2       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_2        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_2               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_3                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_3                 : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_3                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_3       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_3       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_3        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_3               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_4                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_4                 : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_4                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_4       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_4       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_4        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_4               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_5                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_5                 : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_5                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_5       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_5       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_5        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_5               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_6                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_6                 : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_6                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_6       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_6       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_6        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_6               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_7                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_7                 : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_7                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_7       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_7       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_7        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_7               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_8                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_8                 : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_8                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_8       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_8       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_8        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_8               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_9                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_9                 : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_9                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_9       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_9       : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_9        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_9               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_10               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_10                : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_10               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_10      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_10      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_10       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_10              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_11               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_11                : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_11               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_11      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_11      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_11       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_11              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_12               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_12                : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_12               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_12      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_12      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_12       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_12              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_13               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_13                : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_13               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_13      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_13      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_13       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_13              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_14               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_14                : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_14               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_14      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_14      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_14       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_14              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_ENTRY_TYPE_15               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_BAR_15                : integer range 0 to 6           := 0;
        C_PF0_ENTRY_ADDR_15               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF0_ENTRY_MAJOR_VERSION_15      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_MINOR_VERSION_15      : integer range 0 to 255         := 0;
        C_PF0_ENTRY_VERSION_TYPE_15       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF0_ENTRY_RSVD0_15              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF0_S_AXI_DATA_WIDTH            : integer range 32 to 32         := 32;
        C_PF0_S_AXI_ADDR_WIDTH            : integer range 1 to 64          := 32;
        C_PF1_NUM_SLOTS_BAR_LAYOUT_TABLE  : integer range 1 to 16          := 1;
        C_PF1_BAR_INDEX               		: integer range 0 to 6           := 0;
        C_PF1_LOW_OFFSET              		: std_logic_vector(27 downto 0)  := (others => '0');
        C_PF1_HIGH_OFFSET             		: std_logic_vector(31 downto 0)  := (others => '0');
        C_PF1_ENTRY_TYPE_0                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_0                 : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_0                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_0       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_0       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_0        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_0               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_1                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_1                 : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_1                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_1       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_1       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_1        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_1               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_2                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_2                 : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_2                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_2       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_2       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_2        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_2               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_3                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_3                 : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_3                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_3       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_3       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_3        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_3               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_4                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_4                 : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_4                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_4       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_4       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_4        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_4               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_5                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_5                 : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_5                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_5       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_5       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_5        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_5               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_6                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_6                 : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_6                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_6       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_6       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_6        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_6               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_7                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_7                 : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_7                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_7       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_7       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_7        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_7               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_8                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_8                 : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_8                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_8       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_8       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_8        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_8               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_9                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_9                 : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_9                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_9       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_9       : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_9        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_9               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_10               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_10                : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_10               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_10      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_10      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_10       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_10              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_11               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_11                : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_11               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_11      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_11      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_11       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_11              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_12               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_12                : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_12               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_12      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_12      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_12       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_12              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_13               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_13                : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_13               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_13      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_13      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_13       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_13              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_14               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_14                : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_14               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_14      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_14      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_14       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_14              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_ENTRY_TYPE_15               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_BAR_15                : integer range 0 to 6           := 0;
        C_PF1_ENTRY_ADDR_15               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF1_ENTRY_MAJOR_VERSION_15      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_MINOR_VERSION_15      : integer range 0 to 255         := 0;
        C_PF1_ENTRY_VERSION_TYPE_15       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF1_ENTRY_RSVD0_15              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF1_S_AXI_DATA_WIDTH            : integer range 32 to 32         := 32;
        C_PF1_S_AXI_ADDR_WIDTH            : integer range 1 to 64          := 32;
        C_PF2_NUM_SLOTS_BAR_LAYOUT_TABLE  : integer range 1 to 16          := 1;
        C_PF2_BAR_INDEX               		: integer range 0 to 6           := 0;
        C_PF2_LOW_OFFSET              		: std_logic_vector(27 downto 0)  := (others => '0');
        C_PF2_HIGH_OFFSET             		: std_logic_vector(31 downto 0)  := (others => '0');
        C_PF2_ENTRY_TYPE_0                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_0                 : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_0                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_0       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_0       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_0        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_0               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_1                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_1                 : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_1                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_1       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_1       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_1        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_1               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_2                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_2                 : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_2                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_2       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_2       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_2        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_2               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_3                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_3                 : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_3                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_3       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_3       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_3        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_3               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_4                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_4                 : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_4                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_4       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_4       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_4        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_4               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_5                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_5                 : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_5                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_5       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_5       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_5        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_5               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_6                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_6                 : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_6                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_6       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_6       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_6        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_6               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_7                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_7                 : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_7                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_7       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_7       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_7        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_7               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_8                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_8                 : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_8                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_8       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_8       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_8        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_8               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_9                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_9                 : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_9                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_9       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_9       : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_9        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_9               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_10               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_10                : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_10               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_10      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_10      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_10       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_10              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_11               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_11                : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_11               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_11      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_11      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_11       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_11              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_12               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_12                : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_12               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_12      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_12      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_12       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_12              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_13               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_13                : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_13               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_13      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_13      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_13       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_13              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_14               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_14                : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_14               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_14      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_14      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_14       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_14              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_ENTRY_TYPE_15               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_BAR_15                : integer range 0 to 6           := 0;
        C_PF2_ENTRY_ADDR_15               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF2_ENTRY_MAJOR_VERSION_15      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_MINOR_VERSION_15      : integer range 0 to 255         := 0;
        C_PF2_ENTRY_VERSION_TYPE_15       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF2_ENTRY_RSVD0_15              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF2_S_AXI_DATA_WIDTH            : integer range 32 to 32         := 32;
        C_PF2_S_AXI_ADDR_WIDTH            : integer range 1 to 64          := 32;
        C_PF3_NUM_SLOTS_BAR_LAYOUT_TABLE  : integer range 1 to 16          := 1;
        C_PF3_BAR_INDEX               		: integer range 0 to 6           := 0;
        C_PF3_LOW_OFFSET              		: std_logic_vector(27 downto 0)  := (others => '0');
        C_PF3_HIGH_OFFSET             		: std_logic_vector(31 downto 0)  := (others => '0');
        C_PF3_ENTRY_TYPE_0                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_0                 : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_0                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_0       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_0       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_0        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_0               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_1                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_1                 : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_1                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_1       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_1       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_1        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_1               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_2                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_2                 : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_2                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_2       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_2       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_2        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_2               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_3                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_3                 : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_3                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_3       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_3       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_3        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_3               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_4                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_4                 : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_4                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_4       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_4       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_4        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_4               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_5                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_5                 : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_5                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_5       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_5       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_5        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_5               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_6                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_6                 : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_6                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_6       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_6       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_6        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_6               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_7                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_7                 : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_7                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_7       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_7       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_7        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_7               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_8                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_8                 : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_8                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_8       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_8       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_8        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_8               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_9                : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_9                 : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_9                : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_9       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_9       : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_9        : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_9               : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_10               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_10                : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_10               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_10      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_10      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_10       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_10              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_11               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_11                : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_11               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_11      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_11      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_11       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_11              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_12               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_12                : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_12               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_12      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_12      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_12       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_12              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_13               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_13                : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_13               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_13      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_13      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_13       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_13              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_14               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_14                : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_14               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_14      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_14      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_14       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_14              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_ENTRY_TYPE_15               : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_BAR_15                : integer range 0 to 6           := 0;
        C_PF3_ENTRY_ADDR_15               : std_logic_vector(47 downto 0)  := (others => '0');
        C_PF3_ENTRY_MAJOR_VERSION_15      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_MINOR_VERSION_15      : integer range 0 to 255         := 0;
        C_PF3_ENTRY_VERSION_TYPE_15       : std_logic_vector(7 downto 0)   := (others => '0');
        C_PF3_ENTRY_RSVD0_15              : std_logic_vector(3 downto 0)   := (others => '0');
        C_PF3_S_AXI_DATA_WIDTH            : integer range 32 to 32         := 32;
        C_PF3_S_AXI_ADDR_WIDTH            : integer range 1 to 64          := 32;
        C_XDEVICEFAMILY               		: string                         := "no_family"
        );
    port (
        -----------------------------------------------------------------------
        -- Clocks & Resets
        -----------------------------------------------------------------------

        aclk_pcie                  								: in  std_logic;
        aresetn_pcie               								: in  std_logic;

        aclk_ctrl                   							: in  std_logic;
        aresetn_ctrl             									: in  std_logic;

        -----------------------------------------------------------------------
        -- slave pcie4_cfg_ext Interface (aclk_pcie)
        -----------------------------------------------------------------------

        s_pcie4_cfg_ext_function_number           : in  std_logic_vector(7 downto 0);
        s_pcie4_cfg_ext_read_data                 : out std_logic_vector(31 downto 0);
        s_pcie4_cfg_ext_read_data_valid           : out std_logic;
        s_pcie4_cfg_ext_read_received             : in  std_logic;
        s_pcie4_cfg_ext_register_number           : in  std_logic_vector(9 downto 0);
        s_pcie4_cfg_ext_write_byte_enable         : in  std_logic_vector(3 downto 0);
        s_pcie4_cfg_ext_write_data                : in  std_logic_vector(31 downto 0);
        s_pcie4_cfg_ext_write_received            : in  std_logic;

        -----------------------------------------------------------------------
        -- master pcie4_cfg_ext Interface (aclk_pcie)
        -----------------------------------------------------------------------

        m_pcie4_cfg_ext_function_number           : out std_logic_vector(7 downto 0);
        m_pcie4_cfg_ext_read_data                 : in  std_logic_vector(31 downto 0);
        m_pcie4_cfg_ext_read_data_valid           : in  std_logic;
        m_pcie4_cfg_ext_read_received             : out std_logic;
        m_pcie4_cfg_ext_register_number           : out std_logic_vector(9 downto 0);
        m_pcie4_cfg_ext_write_byte_enable         : out std_logic_vector(3 downto 0);
        m_pcie4_cfg_ext_write_data                : out std_logic_vector(31 downto 0);
        m_pcie4_cfg_ext_write_received            : out std_logic;

        -----------------------------------------------------------------------
        -- AXI Interface (aclk_ctrl) for PF0
        -----------------------------------------------------------------------

        s_axi_ctrl_pf0_AWADDR              				: in  std_logic_vector(C_PF0_S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_ctrl_pf0_AWVALID             				: in  std_logic;
        s_axi_ctrl_pf0_AWREADY             				: out std_logic;
        s_axi_ctrl_pf0_WDATA               				: in  std_logic_vector(C_PF0_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_ctrl_pf0_WSTRB               				: in  std_logic_vector((C_PF0_S_AXI_DATA_WIDTH/8)-1 downto 0);
        s_axi_ctrl_pf0_WVALID              				: in  std_logic;
        s_axi_ctrl_pf0_WREADY              				: out std_logic;
        s_axi_ctrl_pf0_BRESP               				: out std_logic_vector(1 downto 0);
        s_axi_ctrl_pf0_BVALID              				: out std_logic;
        s_axi_ctrl_pf0_BREADY              				: in  std_logic;
        s_axi_ctrl_pf0_ARADDR              				: in  std_logic_vector(C_PF0_S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_ctrl_pf0_ARVALID             				: in  std_logic;
        s_axi_ctrl_pf0_ARREADY             				: out std_logic;
        s_axi_ctrl_pf0_RDATA               				: out std_logic_vector(C_PF0_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_ctrl_pf0_RRESP               				: out std_logic_vector(1 downto 0);
        s_axi_ctrl_pf0_RVALID              				: out std_logic;
        s_axi_ctrl_pf0_RREADY              				: in  std_logic;

        -----------------------------------------------------------------------
        -- AXI Interface (aclk_ctrl) for PF1
        -----------------------------------------------------------------------

        s_axi_ctrl_pf1_AWADDR              				: in  std_logic_vector(C_PF1_S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_ctrl_pf1_AWVALID             				: in  std_logic;
        s_axi_ctrl_pf1_AWREADY             				: out std_logic;
        s_axi_ctrl_pf1_WDATA               				: in  std_logic_vector(C_PF1_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_ctrl_pf1_WSTRB               				: in  std_logic_vector((C_PF1_S_AXI_DATA_WIDTH/8)-1 downto 0);
        s_axi_ctrl_pf1_WVALID              				: in  std_logic;
        s_axi_ctrl_pf1_WREADY              				: out std_logic;
        s_axi_ctrl_pf1_BRESP               				: out std_logic_vector(1 downto 0);
        s_axi_ctrl_pf1_BVALID              				: out std_logic;
        s_axi_ctrl_pf1_BREADY              				: in  std_logic;
        s_axi_ctrl_pf1_ARADDR              				: in  std_logic_vector(C_PF1_S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_ctrl_pf1_ARVALID             				: in  std_logic;
        s_axi_ctrl_pf1_ARREADY             				: out std_logic;
        s_axi_ctrl_pf1_RDATA               				: out std_logic_vector(C_PF1_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_ctrl_pf1_RRESP               				: out std_logic_vector(1 downto 0);
        s_axi_ctrl_pf1_RVALID              				: out std_logic;
        s_axi_ctrl_pf1_RREADY              				: in  std_logic;

        -----------------------------------------------------------------------
        -- AXI Interface (aclk_ctrl) for PF2
        -----------------------------------------------------------------------

        s_axi_ctrl_pf2_AWADDR              				: in  std_logic_vector(C_PF2_S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_ctrl_pf2_AWVALID             				: in  std_logic;
        s_axi_ctrl_pf2_AWREADY             				: out std_logic;
        s_axi_ctrl_pf2_WDATA               				: in  std_logic_vector(C_PF2_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_ctrl_pf2_WSTRB               				: in  std_logic_vector((C_PF2_S_AXI_DATA_WIDTH/8)-1 downto 0);
        s_axi_ctrl_pf2_WVALID              				: in  std_logic;
        s_axi_ctrl_pf2_WREADY              				: out std_logic;
        s_axi_ctrl_pf2_BRESP               				: out std_logic_vector(1 downto 0);
        s_axi_ctrl_pf2_BVALID              				: out std_logic;
        s_axi_ctrl_pf2_BREADY              				: in  std_logic;
        s_axi_ctrl_pf2_ARADDR              				: in  std_logic_vector(C_PF2_S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_ctrl_pf2_ARVALID             				: in  std_logic;
        s_axi_ctrl_pf2_ARREADY             				: out std_logic;
        s_axi_ctrl_pf2_RDATA               				: out std_logic_vector(C_PF2_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_ctrl_pf2_RRESP               				: out std_logic_vector(1 downto 0);
        s_axi_ctrl_pf2_RVALID              				: out std_logic;
        s_axi_ctrl_pf2_RREADY              				: in  std_logic;

        -----------------------------------------------------------------------
        -- AXI Interface (aclk_ctrl) for PF3
        -----------------------------------------------------------------------

        s_axi_ctrl_pf3_AWADDR              				: in  std_logic_vector(C_PF3_S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_ctrl_pf3_AWVALID             				: in  std_logic;
        s_axi_ctrl_pf3_AWREADY             				: out std_logic;
        s_axi_ctrl_pf3_WDATA               				: in  std_logic_vector(C_PF3_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_ctrl_pf3_WSTRB               				: in  std_logic_vector((C_PF3_S_AXI_DATA_WIDTH/8)-1 downto 0);
        s_axi_ctrl_pf3_WVALID              				: in  std_logic;
        s_axi_ctrl_pf3_WREADY              				: out std_logic;
        s_axi_ctrl_pf3_BRESP               				: out std_logic_vector(1 downto 0);
        s_axi_ctrl_pf3_BVALID              				: out std_logic;
        s_axi_ctrl_pf3_BREADY              				: in  std_logic;
        s_axi_ctrl_pf3_ARADDR              				: in  std_logic_vector(C_PF3_S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_ctrl_pf3_ARVALID             				: in  std_logic;
        s_axi_ctrl_pf3_ARREADY             				: out std_logic;
        s_axi_ctrl_pf3_RDATA               				: out std_logic_vector(C_PF3_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_ctrl_pf3_RRESP               				: out std_logic_vector(1 downto 0);
        s_axi_ctrl_pf3_RVALID              				: out std_logic;
        s_axi_ctrl_pf3_RREADY              				: in  std_logic

    );

end hw_discovery_v1_0_1_hw_disc;

architecture rtl of hw_discovery_v1_0_1_hw_disc is

    -------------------------------------------------------------------------------
    -- Constant Declarations
    -------------------------------------------------------------------------------

    -- Constants for AXI4-Lite.
    constant ZEROES : std_logic_vector(0 to 31) := (others => '0');
    constant ONES   : std_logic_vector(0 to 31) := (others => '1');

    constant C_FAMILY : string := C_XDEVICEFAMILY;

begin

	pcie_vsec_inst : entity hw_discovery_v1_0_1.hw_discovery_v1_0_1_pcie_vsec
		generic map (
			C_NUM_PFS                 					=> C_NUM_PFS,
			C_CAP_BASE_ADDR           					=> C_CAP_BASE_ADDR,
			C_NEXT_CAP_ADDR           					=> C_NEXT_CAP_ADDR,
			C_PF0_BAR_INDEX           					=> C_PF0_BAR_INDEX,
			C_PF0_LOW_OFFSET          					=> C_PF0_LOW_OFFSET,
			C_PF0_HIGH_OFFSET         					=> C_PF0_HIGH_OFFSET,
			C_PF1_BAR_INDEX           					=> C_PF1_BAR_INDEX,
			C_PF1_LOW_OFFSET          					=> C_PF1_LOW_OFFSET,
			C_PF1_HIGH_OFFSET         					=> C_PF1_HIGH_OFFSET,
			C_PF2_BAR_INDEX           					=> C_PF2_BAR_INDEX,
			C_PF2_LOW_OFFSET          					=> C_PF2_LOW_OFFSET,
			C_PF2_HIGH_OFFSET         					=> C_PF2_HIGH_OFFSET,
			C_PF3_BAR_INDEX           					=> C_PF3_BAR_INDEX,
			C_PF3_LOW_OFFSET          					=> C_PF3_LOW_OFFSET,
			C_PF3_HIGH_OFFSET         					=> C_PF3_HIGH_OFFSET,
			C_XDEVICEFAMILY           					=> C_XDEVICEFAMILY
		)
		port map (
			aclk_pcie                  				 	=> aclk_pcie,
			aresetn_pcie               				 	=> aresetn_pcie,
			s_pcie4_cfg_ext_function_number    	=> s_pcie4_cfg_ext_function_number,
			s_pcie4_cfg_ext_read_data          	=> s_pcie4_cfg_ext_read_data,
			s_pcie4_cfg_ext_read_data_valid    	=> s_pcie4_cfg_ext_read_data_valid,
			s_pcie4_cfg_ext_read_received      	=> s_pcie4_cfg_ext_read_received,
			s_pcie4_cfg_ext_register_number    	=> s_pcie4_cfg_ext_register_number,
			s_pcie4_cfg_ext_write_byte_enable  	=> s_pcie4_cfg_ext_write_byte_enable,
			s_pcie4_cfg_ext_write_data         	=> s_pcie4_cfg_ext_write_data,
			s_pcie4_cfg_ext_write_received     	=> s_pcie4_cfg_ext_write_received,
			m_pcie4_cfg_ext_function_number    	=> m_pcie4_cfg_ext_function_number,
			m_pcie4_cfg_ext_read_data          	=> m_pcie4_cfg_ext_read_data,
			m_pcie4_cfg_ext_read_data_valid    	=> m_pcie4_cfg_ext_read_data_valid,
			m_pcie4_cfg_ext_read_received      	=> m_pcie4_cfg_ext_read_received,
			m_pcie4_cfg_ext_register_number    	=> m_pcie4_cfg_ext_register_number,
			m_pcie4_cfg_ext_write_byte_enable  	=> m_pcie4_cfg_ext_write_byte_enable,
			m_pcie4_cfg_ext_write_data         	=> m_pcie4_cfg_ext_write_data,
			m_pcie4_cfg_ext_write_received     	=> m_pcie4_cfg_ext_write_received
		);

	G_GENERATE: for i in 0 to C_NUM_PFS-1 generate

		G_GENERATE_PF0 : if (i = 0) generate

	  	-- Instantiate BAR Layout table
			BAR_LAYOUT_TABLE_inst_0 : entity hw_discovery_v1_0_1.hw_discovery_v1_0_1_bar_layout_table
	    	generic map (
	    		C_NUM_SLOTS_BAR_LAYOUT_TABLE  => C_PF0_NUM_SLOTS_BAR_LAYOUT_TABLE,
	    		C_ENTRY_TYPE_0                => C_PF0_ENTRY_TYPE_0,
	    		C_ENTRY_BAR_0                 => C_PF0_ENTRY_BAR_0,
	    		C_ENTRY_ADDR_0                => C_PF0_ENTRY_ADDR_0,
	    		C_ENTRY_MAJOR_VERSION_0       => C_PF0_ENTRY_MAJOR_VERSION_0,
	    		C_ENTRY_MINOR_VERSION_0       => C_PF0_ENTRY_MINOR_VERSION_0,
	    		C_ENTRY_VERSION_TYPE_0        => C_PF0_ENTRY_VERSION_TYPE_0,
	    		C_ENTRY_RSVD0_0               => C_PF0_ENTRY_RSVD0_0,
	    		C_ENTRY_TYPE_1                => C_PF0_ENTRY_TYPE_1,
	    		C_ENTRY_BAR_1                 => C_PF0_ENTRY_BAR_1,
	    		C_ENTRY_ADDR_1                => C_PF0_ENTRY_ADDR_1,
	    		C_ENTRY_MAJOR_VERSION_1       => C_PF0_ENTRY_MAJOR_VERSION_1,
	    		C_ENTRY_MINOR_VERSION_1       => C_PF0_ENTRY_MINOR_VERSION_1,
	    		C_ENTRY_VERSION_TYPE_1        => C_PF0_ENTRY_VERSION_TYPE_1,
	    		C_ENTRY_RSVD0_1               => C_PF0_ENTRY_RSVD0_1,
	    		C_ENTRY_TYPE_2                => C_PF0_ENTRY_TYPE_2,
	    		C_ENTRY_BAR_2                 => C_PF0_ENTRY_BAR_2,
	    		C_ENTRY_ADDR_2                => C_PF0_ENTRY_ADDR_2,
	    		C_ENTRY_MAJOR_VERSION_2       => C_PF0_ENTRY_MAJOR_VERSION_2,
	    		C_ENTRY_MINOR_VERSION_2       => C_PF0_ENTRY_MINOR_VERSION_2,
	    		C_ENTRY_VERSION_TYPE_2        => C_PF0_ENTRY_VERSION_TYPE_2,
	    		C_ENTRY_RSVD0_2               => C_PF0_ENTRY_RSVD0_2,
	    		C_ENTRY_TYPE_3                => C_PF0_ENTRY_TYPE_3,
	    		C_ENTRY_BAR_3                 => C_PF0_ENTRY_BAR_3,
	    		C_ENTRY_ADDR_3                => C_PF0_ENTRY_ADDR_3,
	    		C_ENTRY_MAJOR_VERSION_3       => C_PF0_ENTRY_MAJOR_VERSION_3,
	    		C_ENTRY_MINOR_VERSION_3       => C_PF0_ENTRY_MINOR_VERSION_3,
	    		C_ENTRY_VERSION_TYPE_3        => C_PF0_ENTRY_VERSION_TYPE_3,
	    		C_ENTRY_RSVD0_3               => C_PF0_ENTRY_RSVD0_3,
	    		C_ENTRY_TYPE_4                => C_PF0_ENTRY_TYPE_4,
	    		C_ENTRY_BAR_4                 => C_PF0_ENTRY_BAR_4,
	    		C_ENTRY_ADDR_4                => C_PF0_ENTRY_ADDR_4,
	    		C_ENTRY_MAJOR_VERSION_4       => C_PF0_ENTRY_MAJOR_VERSION_4,
	    		C_ENTRY_MINOR_VERSION_4       => C_PF0_ENTRY_MINOR_VERSION_4,
	    		C_ENTRY_VERSION_TYPE_4        => C_PF0_ENTRY_VERSION_TYPE_4,
	    		C_ENTRY_RSVD0_4               => C_PF0_ENTRY_RSVD0_4,
	    		C_ENTRY_TYPE_5                => C_PF0_ENTRY_TYPE_5,
	    		C_ENTRY_BAR_5                 => C_PF0_ENTRY_BAR_5,
	    		C_ENTRY_ADDR_5                => C_PF0_ENTRY_ADDR_5,
	    		C_ENTRY_MAJOR_VERSION_5       => C_PF0_ENTRY_MAJOR_VERSION_5,
	    		C_ENTRY_MINOR_VERSION_5       => C_PF0_ENTRY_MINOR_VERSION_5,
	    		C_ENTRY_VERSION_TYPE_5        => C_PF0_ENTRY_VERSION_TYPE_5,
	    		C_ENTRY_RSVD0_5               => C_PF0_ENTRY_RSVD0_5,
	    		C_ENTRY_TYPE_6                => C_PF0_ENTRY_TYPE_6,
	    		C_ENTRY_BAR_6                 => C_PF0_ENTRY_BAR_6,
	    		C_ENTRY_ADDR_6                => C_PF0_ENTRY_ADDR_6,
	    		C_ENTRY_MAJOR_VERSION_6       => C_PF0_ENTRY_MAJOR_VERSION_6,
	    		C_ENTRY_MINOR_VERSION_6       => C_PF0_ENTRY_MINOR_VERSION_6,
	    		C_ENTRY_VERSION_TYPE_6        => C_PF0_ENTRY_VERSION_TYPE_6,
	    		C_ENTRY_RSVD0_6               => C_PF0_ENTRY_RSVD0_6,
	    		C_ENTRY_TYPE_7                => C_PF0_ENTRY_TYPE_7,
	    		C_ENTRY_BAR_7                 => C_PF0_ENTRY_BAR_7,
	    		C_ENTRY_ADDR_7                => C_PF0_ENTRY_ADDR_7,
	    		C_ENTRY_MAJOR_VERSION_7       => C_PF0_ENTRY_MAJOR_VERSION_7,
	    		C_ENTRY_MINOR_VERSION_7       => C_PF0_ENTRY_MINOR_VERSION_7,
	    		C_ENTRY_VERSION_TYPE_7        => C_PF0_ENTRY_VERSION_TYPE_7,
	    		C_ENTRY_RSVD0_7               => C_PF0_ENTRY_RSVD0_7,
	    		C_ENTRY_TYPE_8                => C_PF0_ENTRY_TYPE_8,
	    		C_ENTRY_BAR_8                 => C_PF0_ENTRY_BAR_8,
	    		C_ENTRY_ADDR_8                => C_PF0_ENTRY_ADDR_8,
	    		C_ENTRY_MAJOR_VERSION_8       => C_PF0_ENTRY_MAJOR_VERSION_8,
	    		C_ENTRY_MINOR_VERSION_8       => C_PF0_ENTRY_MINOR_VERSION_8,
	    		C_ENTRY_VERSION_TYPE_8        => C_PF0_ENTRY_VERSION_TYPE_8,
	    		C_ENTRY_RSVD0_8               => C_PF0_ENTRY_RSVD0_8,
	    		C_ENTRY_TYPE_9                => C_PF0_ENTRY_TYPE_9,
	    		C_ENTRY_BAR_9                 => C_PF0_ENTRY_BAR_9,
	    		C_ENTRY_ADDR_9                => C_PF0_ENTRY_ADDR_9,
	    		C_ENTRY_MAJOR_VERSION_9       => C_PF0_ENTRY_MAJOR_VERSION_9,
	    		C_ENTRY_MINOR_VERSION_9       => C_PF0_ENTRY_MINOR_VERSION_9,
	    		C_ENTRY_VERSION_TYPE_9        => C_PF0_ENTRY_VERSION_TYPE_9,
	    		C_ENTRY_RSVD0_9               => C_PF0_ENTRY_RSVD0_9,
	    		C_ENTRY_TYPE_10               => C_PF0_ENTRY_TYPE_10,
	    		C_ENTRY_BAR_10                => C_PF0_ENTRY_BAR_10,
	    		C_ENTRY_ADDR_10               => C_PF0_ENTRY_ADDR_10,
	    		C_ENTRY_MAJOR_VERSION_10      => C_PF0_ENTRY_MAJOR_VERSION_10,
	    		C_ENTRY_MINOR_VERSION_10      => C_PF0_ENTRY_MINOR_VERSION_10,
	    		C_ENTRY_VERSION_TYPE_10       => C_PF0_ENTRY_VERSION_TYPE_10,
	    		C_ENTRY_RSVD0_10              => C_PF0_ENTRY_RSVD0_10,
	    		C_ENTRY_TYPE_11               => C_PF0_ENTRY_TYPE_11,
	    		C_ENTRY_BAR_11                => C_PF0_ENTRY_BAR_11,
	    		C_ENTRY_ADDR_11               => C_PF0_ENTRY_ADDR_11,
	    		C_ENTRY_MAJOR_VERSION_11      => C_PF0_ENTRY_MAJOR_VERSION_11,
	    		C_ENTRY_MINOR_VERSION_11      => C_PF0_ENTRY_MINOR_VERSION_11,
	    		C_ENTRY_VERSION_TYPE_11       => C_PF0_ENTRY_VERSION_TYPE_11,
	    		C_ENTRY_RSVD0_11              => C_PF0_ENTRY_RSVD0_11,
	    		C_ENTRY_TYPE_12               => C_PF0_ENTRY_TYPE_12,
	    		C_ENTRY_BAR_12                => C_PF0_ENTRY_BAR_12,
	    		C_ENTRY_ADDR_12               => C_PF0_ENTRY_ADDR_12,
	    		C_ENTRY_MAJOR_VERSION_12      => C_PF0_ENTRY_MAJOR_VERSION_12,
	    		C_ENTRY_MINOR_VERSION_12      => C_PF0_ENTRY_MINOR_VERSION_12,
	    		C_ENTRY_VERSION_TYPE_12       => C_PF0_ENTRY_VERSION_TYPE_12,
	    		C_ENTRY_RSVD0_12              => C_PF0_ENTRY_RSVD0_12,
	    		C_ENTRY_TYPE_13               => C_PF0_ENTRY_TYPE_13,
	    		C_ENTRY_BAR_13                => C_PF0_ENTRY_BAR_13,
	    		C_ENTRY_ADDR_13               => C_PF0_ENTRY_ADDR_13,
	    		C_ENTRY_MAJOR_VERSION_13      => C_PF0_ENTRY_MAJOR_VERSION_13,
	    		C_ENTRY_MINOR_VERSION_13      => C_PF0_ENTRY_MINOR_VERSION_13,
	    		C_ENTRY_VERSION_TYPE_13       => C_PF0_ENTRY_VERSION_TYPE_13,
	    		C_ENTRY_RSVD0_13              => C_PF0_ENTRY_RSVD0_13,
	    		C_ENTRY_TYPE_14               => C_PF0_ENTRY_TYPE_14,
	    		C_ENTRY_BAR_14                => C_PF0_ENTRY_BAR_14,
	    		C_ENTRY_ADDR_14               => C_PF0_ENTRY_ADDR_14,
	    		C_ENTRY_MAJOR_VERSION_14      => C_PF0_ENTRY_MAJOR_VERSION_14,
	    		C_ENTRY_MINOR_VERSION_14      => C_PF0_ENTRY_MINOR_VERSION_14,
	    		C_ENTRY_VERSION_TYPE_14       => C_PF0_ENTRY_VERSION_TYPE_14,
	    		C_ENTRY_RSVD0_14              => C_PF0_ENTRY_RSVD0_14,
	    		C_ENTRY_TYPE_15               => C_PF0_ENTRY_TYPE_15,
	    		C_ENTRY_BAR_15                => C_PF0_ENTRY_BAR_15,
	    		C_ENTRY_ADDR_15               => C_PF0_ENTRY_ADDR_15,
	    		C_ENTRY_MAJOR_VERSION_15      => C_PF0_ENTRY_MAJOR_VERSION_15,
	    		C_ENTRY_MINOR_VERSION_15      => C_PF0_ENTRY_MINOR_VERSION_15,
	    		C_ENTRY_VERSION_TYPE_15       => C_PF0_ENTRY_VERSION_TYPE_15,
	    		C_ENTRY_RSVD0_15              => C_PF0_ENTRY_RSVD0_15,
	    		C_S_AXI_DATA_WIDTH            => C_PF0_S_AXI_DATA_WIDTH,
	    		C_S_AXI_ADDR_WIDTH            => C_PF0_S_AXI_ADDR_WIDTH,
	    		C_XDEVICEFAMILY               => C_XDEVICEFAMILY
	    	)
	    	port map (
			    S_AXI_ACLK            		    => aclk_ctrl,
			    S_AXI_ARESETN         		    => aresetn_ctrl,
	    		S_AXI_AWADDR              		=> s_axi_ctrl_pf0_AWADDR,
	    		S_AXI_AWVALID             		=> s_axi_ctrl_pf0_AWVALID,
	    		S_AXI_AWREADY             		=> s_axi_ctrl_pf0_AWREADY,
	    		S_AXI_WDATA               		=> s_axi_ctrl_pf0_WDATA,
	    		S_AXI_WSTRB               		=> s_axi_ctrl_pf0_WSTRB,
	    		S_AXI_WVALID              		=> s_axi_ctrl_pf0_WVALID,
	    		S_AXI_WREADY              		=> s_axi_ctrl_pf0_WREADY,
	    		S_AXI_BRESP               		=> s_axi_ctrl_pf0_BRESP,
	    		S_AXI_BVALID              		=> s_axi_ctrl_pf0_BVALID,
	    		S_AXI_BREADY              		=> s_axi_ctrl_pf0_BREADY,
	    		S_AXI_ARADDR              		=> s_axi_ctrl_pf0_ARADDR,
	    		S_AXI_ARVALID             		=> s_axi_ctrl_pf0_ARVALID,
	    		S_AXI_ARREADY             		=> s_axi_ctrl_pf0_ARREADY,
	    		S_AXI_RDATA               		=> s_axi_ctrl_pf0_RDATA,
	    		S_AXI_RRESP               		=> s_axi_ctrl_pf0_RRESP,
	    		S_AXI_RVALID              		=> s_axi_ctrl_pf0_RVALID,
	    		S_AXI_RREADY              		=> s_axi_ctrl_pf0_RREADY
	    	);

			end generate G_GENERATE_PF0;

		G_GENERATE_PF1 : if (i = 1) generate

	  	-- Instantiate BAR Layout table
			BAR_LAYOUT_TABLE_inst_1 : entity hw_discovery_v1_0_1.hw_discovery_v1_0_1_bar_layout_table
	    	generic map (
	    		C_NUM_SLOTS_BAR_LAYOUT_TABLE  => C_PF1_NUM_SLOTS_BAR_LAYOUT_TABLE,
	    		C_ENTRY_TYPE_0                => C_PF1_ENTRY_TYPE_0,
	    		C_ENTRY_BAR_0                 => C_PF1_ENTRY_BAR_0,
	    		C_ENTRY_ADDR_0                => C_PF1_ENTRY_ADDR_0,
	    		C_ENTRY_MAJOR_VERSION_0       => C_PF1_ENTRY_MAJOR_VERSION_0,
	    		C_ENTRY_MINOR_VERSION_0       => C_PF1_ENTRY_MINOR_VERSION_0,
	    		C_ENTRY_VERSION_TYPE_0        => C_PF1_ENTRY_VERSION_TYPE_0,
	    		C_ENTRY_RSVD0_0               => C_PF1_ENTRY_RSVD0_0,
	    		C_ENTRY_TYPE_1                => C_PF1_ENTRY_TYPE_1,
	    		C_ENTRY_BAR_1                 => C_PF1_ENTRY_BAR_1,
	    		C_ENTRY_ADDR_1                => C_PF1_ENTRY_ADDR_1,
	    		C_ENTRY_MAJOR_VERSION_1       => C_PF1_ENTRY_MAJOR_VERSION_1,
	    		C_ENTRY_MINOR_VERSION_1       => C_PF1_ENTRY_MINOR_VERSION_1,
	    		C_ENTRY_VERSION_TYPE_1        => C_PF1_ENTRY_VERSION_TYPE_1,
	    		C_ENTRY_RSVD0_1               => C_PF1_ENTRY_RSVD0_1,
	    		C_ENTRY_TYPE_2                => C_PF1_ENTRY_TYPE_2,
	    		C_ENTRY_BAR_2                 => C_PF1_ENTRY_BAR_2,
	    		C_ENTRY_ADDR_2                => C_PF1_ENTRY_ADDR_2,
	    		C_ENTRY_MAJOR_VERSION_2       => C_PF1_ENTRY_MAJOR_VERSION_2,
	    		C_ENTRY_MINOR_VERSION_2       => C_PF1_ENTRY_MINOR_VERSION_2,
	    		C_ENTRY_VERSION_TYPE_2        => C_PF1_ENTRY_VERSION_TYPE_2,
	    		C_ENTRY_RSVD0_2               => C_PF1_ENTRY_RSVD0_2,
	    		C_ENTRY_TYPE_3                => C_PF1_ENTRY_TYPE_3,
	    		C_ENTRY_BAR_3                 => C_PF1_ENTRY_BAR_3,
	    		C_ENTRY_ADDR_3                => C_PF1_ENTRY_ADDR_3,
	    		C_ENTRY_MAJOR_VERSION_3       => C_PF1_ENTRY_MAJOR_VERSION_3,
	    		C_ENTRY_MINOR_VERSION_3       => C_PF1_ENTRY_MINOR_VERSION_3,
	    		C_ENTRY_VERSION_TYPE_3        => C_PF1_ENTRY_VERSION_TYPE_3,
	    		C_ENTRY_RSVD0_3               => C_PF1_ENTRY_RSVD0_3,
	    		C_ENTRY_TYPE_4                => C_PF1_ENTRY_TYPE_4,
	    		C_ENTRY_BAR_4                 => C_PF1_ENTRY_BAR_4,
	    		C_ENTRY_ADDR_4                => C_PF1_ENTRY_ADDR_4,
	    		C_ENTRY_MAJOR_VERSION_4       => C_PF1_ENTRY_MAJOR_VERSION_4,
	    		C_ENTRY_MINOR_VERSION_4       => C_PF1_ENTRY_MINOR_VERSION_4,
	    		C_ENTRY_VERSION_TYPE_4        => C_PF1_ENTRY_VERSION_TYPE_4,
	    		C_ENTRY_RSVD0_4               => C_PF1_ENTRY_RSVD0_4,
	    		C_ENTRY_TYPE_5                => C_PF1_ENTRY_TYPE_5,
	    		C_ENTRY_BAR_5                 => C_PF1_ENTRY_BAR_5,
	    		C_ENTRY_ADDR_5                => C_PF1_ENTRY_ADDR_5,
	    		C_ENTRY_MAJOR_VERSION_5       => C_PF1_ENTRY_MAJOR_VERSION_5,
	    		C_ENTRY_MINOR_VERSION_5       => C_PF1_ENTRY_MINOR_VERSION_5,
	    		C_ENTRY_VERSION_TYPE_5        => C_PF1_ENTRY_VERSION_TYPE_5,
	    		C_ENTRY_RSVD0_5               => C_PF1_ENTRY_RSVD0_5,
	    		C_ENTRY_TYPE_6                => C_PF1_ENTRY_TYPE_6,
	    		C_ENTRY_BAR_6                 => C_PF1_ENTRY_BAR_6,
	    		C_ENTRY_ADDR_6                => C_PF1_ENTRY_ADDR_6,
	    		C_ENTRY_MAJOR_VERSION_6       => C_PF1_ENTRY_MAJOR_VERSION_6,
	    		C_ENTRY_MINOR_VERSION_6       => C_PF1_ENTRY_MINOR_VERSION_6,
	    		C_ENTRY_VERSION_TYPE_6        => C_PF1_ENTRY_VERSION_TYPE_6,
	    		C_ENTRY_RSVD0_6               => C_PF1_ENTRY_RSVD0_6,
	    		C_ENTRY_TYPE_7                => C_PF1_ENTRY_TYPE_7,
	    		C_ENTRY_BAR_7                 => C_PF1_ENTRY_BAR_7,
	    		C_ENTRY_ADDR_7                => C_PF1_ENTRY_ADDR_7,
	    		C_ENTRY_MAJOR_VERSION_7       => C_PF1_ENTRY_MAJOR_VERSION_7,
	    		C_ENTRY_MINOR_VERSION_7       => C_PF1_ENTRY_MINOR_VERSION_7,
	    		C_ENTRY_VERSION_TYPE_7        => C_PF1_ENTRY_VERSION_TYPE_7,
	    		C_ENTRY_RSVD0_7               => C_PF1_ENTRY_RSVD0_7,
	    		C_ENTRY_TYPE_8                => C_PF1_ENTRY_TYPE_8,
	    		C_ENTRY_BAR_8                 => C_PF1_ENTRY_BAR_8,
	    		C_ENTRY_ADDR_8                => C_PF1_ENTRY_ADDR_8,
	    		C_ENTRY_MAJOR_VERSION_8       => C_PF1_ENTRY_MAJOR_VERSION_8,
	    		C_ENTRY_MINOR_VERSION_8       => C_PF1_ENTRY_MINOR_VERSION_8,
	    		C_ENTRY_VERSION_TYPE_8        => C_PF1_ENTRY_VERSION_TYPE_8,
	    		C_ENTRY_RSVD0_8               => C_PF1_ENTRY_RSVD0_8,
	    		C_ENTRY_TYPE_9                => C_PF1_ENTRY_TYPE_9,
	    		C_ENTRY_BAR_9                 => C_PF1_ENTRY_BAR_9,
	    		C_ENTRY_ADDR_9                => C_PF1_ENTRY_ADDR_9,
	    		C_ENTRY_MAJOR_VERSION_9       => C_PF1_ENTRY_MAJOR_VERSION_9,
	    		C_ENTRY_MINOR_VERSION_9       => C_PF1_ENTRY_MINOR_VERSION_9,
	    		C_ENTRY_VERSION_TYPE_9        => C_PF1_ENTRY_VERSION_TYPE_9,
	    		C_ENTRY_RSVD0_9               => C_PF1_ENTRY_RSVD0_9,
	    		C_ENTRY_TYPE_10               => C_PF1_ENTRY_TYPE_10,
	    		C_ENTRY_BAR_10                => C_PF1_ENTRY_BAR_10,
	    		C_ENTRY_ADDR_10               => C_PF1_ENTRY_ADDR_10,
	    		C_ENTRY_MAJOR_VERSION_10      => C_PF1_ENTRY_MAJOR_VERSION_10,
	    		C_ENTRY_MINOR_VERSION_10      => C_PF1_ENTRY_MINOR_VERSION_10,
	    		C_ENTRY_VERSION_TYPE_10       => C_PF1_ENTRY_VERSION_TYPE_10,
	    		C_ENTRY_RSVD0_10              => C_PF1_ENTRY_RSVD0_10,
	    		C_ENTRY_TYPE_11               => C_PF1_ENTRY_TYPE_11,
	    		C_ENTRY_BAR_11                => C_PF1_ENTRY_BAR_11,
	    		C_ENTRY_ADDR_11               => C_PF1_ENTRY_ADDR_11,
	    		C_ENTRY_MAJOR_VERSION_11      => C_PF1_ENTRY_MAJOR_VERSION_11,
	    		C_ENTRY_MINOR_VERSION_11      => C_PF1_ENTRY_MINOR_VERSION_11,
	    		C_ENTRY_VERSION_TYPE_11       => C_PF1_ENTRY_VERSION_TYPE_11,
	    		C_ENTRY_RSVD0_11              => C_PF1_ENTRY_RSVD0_11,
	    		C_ENTRY_TYPE_12               => C_PF1_ENTRY_TYPE_12,
	    		C_ENTRY_BAR_12                => C_PF1_ENTRY_BAR_12,
	    		C_ENTRY_ADDR_12               => C_PF1_ENTRY_ADDR_12,
	    		C_ENTRY_MAJOR_VERSION_12      => C_PF1_ENTRY_MAJOR_VERSION_12,
	    		C_ENTRY_MINOR_VERSION_12      => C_PF1_ENTRY_MINOR_VERSION_12,
	    		C_ENTRY_VERSION_TYPE_12       => C_PF1_ENTRY_VERSION_TYPE_12,
	    		C_ENTRY_RSVD0_12              => C_PF1_ENTRY_RSVD0_12,
	    		C_ENTRY_TYPE_13               => C_PF1_ENTRY_TYPE_13,
	    		C_ENTRY_BAR_13                => C_PF1_ENTRY_BAR_13,
	    		C_ENTRY_ADDR_13               => C_PF1_ENTRY_ADDR_13,
	    		C_ENTRY_MAJOR_VERSION_13      => C_PF1_ENTRY_MAJOR_VERSION_13,
	    		C_ENTRY_MINOR_VERSION_13      => C_PF1_ENTRY_MINOR_VERSION_13,
	    		C_ENTRY_VERSION_TYPE_13       => C_PF1_ENTRY_VERSION_TYPE_13,
	    		C_ENTRY_RSVD0_13              => C_PF1_ENTRY_RSVD0_13,
	    		C_ENTRY_TYPE_14               => C_PF1_ENTRY_TYPE_14,
	    		C_ENTRY_BAR_14                => C_PF1_ENTRY_BAR_14,
	    		C_ENTRY_ADDR_14               => C_PF1_ENTRY_ADDR_14,
	    		C_ENTRY_MAJOR_VERSION_14      => C_PF1_ENTRY_MAJOR_VERSION_14,
	    		C_ENTRY_MINOR_VERSION_14      => C_PF1_ENTRY_MINOR_VERSION_14,
	    		C_ENTRY_VERSION_TYPE_14       => C_PF1_ENTRY_VERSION_TYPE_14,
	    		C_ENTRY_RSVD0_14              => C_PF1_ENTRY_RSVD0_14,
	    		C_ENTRY_TYPE_15               => C_PF1_ENTRY_TYPE_15,
	    		C_ENTRY_BAR_15                => C_PF1_ENTRY_BAR_15,
	    		C_ENTRY_ADDR_15               => C_PF1_ENTRY_ADDR_15,
	    		C_ENTRY_MAJOR_VERSION_15      => C_PF1_ENTRY_MAJOR_VERSION_15,
	    		C_ENTRY_MINOR_VERSION_15      => C_PF1_ENTRY_MINOR_VERSION_15,
	    		C_ENTRY_VERSION_TYPE_15       => C_PF1_ENTRY_VERSION_TYPE_15,
	    		C_ENTRY_RSVD0_15              => C_PF1_ENTRY_RSVD0_15,
	    		C_S_AXI_DATA_WIDTH            => C_PF1_S_AXI_DATA_WIDTH,
	    		C_S_AXI_ADDR_WIDTH            => C_PF1_S_AXI_ADDR_WIDTH,
	    		C_XDEVICEFAMILY               => C_XDEVICEFAMILY
	    	)
		    port map (
			    S_AXI_ACLK            		    => aclk_ctrl,
			    S_AXI_ARESETN         		    => aresetn_ctrl,
		    	S_AXI_AWADDR              		=> s_axi_ctrl_pf1_AWADDR,
		    	S_AXI_AWVALID             		=> s_axi_ctrl_pf1_AWVALID,
		    	S_AXI_AWREADY             		=> s_axi_ctrl_pf1_AWREADY,
		    	S_AXI_WDATA               		=> s_axi_ctrl_pf1_WDATA,
		    	S_AXI_WSTRB               		=> s_axi_ctrl_pf1_WSTRB,
		    	S_AXI_WVALID              		=> s_axi_ctrl_pf1_WVALID,
		    	S_AXI_WREADY              		=> s_axi_ctrl_pf1_WREADY,
		    	S_AXI_BRESP               		=> s_axi_ctrl_pf1_BRESP,
		    	S_AXI_BVALID              		=> s_axi_ctrl_pf1_BVALID,
		    	S_AXI_BREADY              		=> s_axi_ctrl_pf1_BREADY,
		    	S_AXI_ARADDR              		=> s_axi_ctrl_pf1_ARADDR,
		    	S_AXI_ARVALID             		=> s_axi_ctrl_pf1_ARVALID,
		    	S_AXI_ARREADY             		=> s_axi_ctrl_pf1_ARREADY,
		    	S_AXI_RDATA               		=> s_axi_ctrl_pf1_RDATA,
		    	S_AXI_RRESP               		=> s_axi_ctrl_pf1_RRESP,
		    	S_AXI_RVALID              		=> s_axi_ctrl_pf1_RVALID,
		    	S_AXI_RREADY              		=> s_axi_ctrl_pf1_RREADY
		    );

			end generate G_GENERATE_PF1;

		G_GENERATE_PF2: if (i = 2) generate

	  	-- Instantiate BAR Layout table
			BAR_LAYOUT_TABLE_inst_2 : entity hw_discovery_v1_0_1.hw_discovery_v1_0_1_bar_layout_table
	    	generic map (
	    	  C_NUM_SLOTS_BAR_LAYOUT_TABLE  => C_PF2_NUM_SLOTS_BAR_LAYOUT_TABLE,
	    	  C_ENTRY_TYPE_0                => C_PF2_ENTRY_TYPE_0,
	    	  C_ENTRY_BAR_0                 => C_PF2_ENTRY_BAR_0,
	    	  C_ENTRY_ADDR_0                => C_PF2_ENTRY_ADDR_0,
	    	  C_ENTRY_MAJOR_VERSION_0       => C_PF2_ENTRY_MAJOR_VERSION_0,
	    	  C_ENTRY_MINOR_VERSION_0       => C_PF2_ENTRY_MINOR_VERSION_0,
	    	  C_ENTRY_VERSION_TYPE_0        => C_PF2_ENTRY_VERSION_TYPE_0,
	    	  C_ENTRY_RSVD0_0               => C_PF2_ENTRY_RSVD0_0,
	    	  C_ENTRY_TYPE_1                => C_PF2_ENTRY_TYPE_1,
	    	  C_ENTRY_BAR_1                 => C_PF2_ENTRY_BAR_1,
	    	  C_ENTRY_ADDR_1                => C_PF2_ENTRY_ADDR_1,
	    	  C_ENTRY_MAJOR_VERSION_1       => C_PF2_ENTRY_MAJOR_VERSION_1,
	    	  C_ENTRY_MINOR_VERSION_1       => C_PF2_ENTRY_MINOR_VERSION_1,
	    	  C_ENTRY_VERSION_TYPE_1        => C_PF2_ENTRY_VERSION_TYPE_1,
	    	  C_ENTRY_RSVD0_1               => C_PF2_ENTRY_RSVD0_1,
	    	  C_ENTRY_TYPE_2                => C_PF2_ENTRY_TYPE_2,
	    	  C_ENTRY_BAR_2                 => C_PF2_ENTRY_BAR_2,
	    	  C_ENTRY_ADDR_2                => C_PF2_ENTRY_ADDR_2,
	    	  C_ENTRY_MAJOR_VERSION_2       => C_PF2_ENTRY_MAJOR_VERSION_2,
	    	  C_ENTRY_MINOR_VERSION_2       => C_PF2_ENTRY_MINOR_VERSION_2,
	    	  C_ENTRY_VERSION_TYPE_2        => C_PF2_ENTRY_VERSION_TYPE_2,
	    	  C_ENTRY_RSVD0_2               => C_PF2_ENTRY_RSVD0_2,
	    	  C_ENTRY_TYPE_3                => C_PF2_ENTRY_TYPE_3,
	    	  C_ENTRY_BAR_3                 => C_PF2_ENTRY_BAR_3,
	    	  C_ENTRY_ADDR_3                => C_PF2_ENTRY_ADDR_3,
	    	  C_ENTRY_MAJOR_VERSION_3       => C_PF2_ENTRY_MAJOR_VERSION_3,
	    	  C_ENTRY_MINOR_VERSION_3       => C_PF2_ENTRY_MINOR_VERSION_3,
	    	  C_ENTRY_VERSION_TYPE_3        => C_PF2_ENTRY_VERSION_TYPE_3,
	    	  C_ENTRY_RSVD0_3               => C_PF2_ENTRY_RSVD0_3,
	    	  C_ENTRY_TYPE_4                => C_PF2_ENTRY_TYPE_4,
	    	  C_ENTRY_BAR_4                 => C_PF2_ENTRY_BAR_4,
	    	  C_ENTRY_ADDR_4                => C_PF2_ENTRY_ADDR_4,
	    	  C_ENTRY_MAJOR_VERSION_4       => C_PF2_ENTRY_MAJOR_VERSION_4,
	    	  C_ENTRY_MINOR_VERSION_4       => C_PF2_ENTRY_MINOR_VERSION_4,
	    	  C_ENTRY_VERSION_TYPE_4        => C_PF2_ENTRY_VERSION_TYPE_4,
	    	  C_ENTRY_RSVD0_4               => C_PF2_ENTRY_RSVD0_4,
	    	  C_ENTRY_TYPE_5                => C_PF2_ENTRY_TYPE_5,
	    	  C_ENTRY_BAR_5                 => C_PF2_ENTRY_BAR_5,
	    	  C_ENTRY_ADDR_5                => C_PF2_ENTRY_ADDR_5,
	    	  C_ENTRY_MAJOR_VERSION_5       => C_PF2_ENTRY_MAJOR_VERSION_5,
	    	  C_ENTRY_MINOR_VERSION_5       => C_PF2_ENTRY_MINOR_VERSION_5,
	    	  C_ENTRY_VERSION_TYPE_5        => C_PF2_ENTRY_VERSION_TYPE_5,
	    	  C_ENTRY_RSVD0_5               => C_PF2_ENTRY_RSVD0_5,
	    	  C_ENTRY_TYPE_6                => C_PF2_ENTRY_TYPE_6,
	    	  C_ENTRY_BAR_6                 => C_PF2_ENTRY_BAR_6,
	    	  C_ENTRY_ADDR_6                => C_PF2_ENTRY_ADDR_6,
	    	  C_ENTRY_MAJOR_VERSION_6       => C_PF2_ENTRY_MAJOR_VERSION_6,
	    	  C_ENTRY_MINOR_VERSION_6       => C_PF2_ENTRY_MINOR_VERSION_6,
	    	  C_ENTRY_VERSION_TYPE_6        => C_PF2_ENTRY_VERSION_TYPE_6,
	    	  C_ENTRY_RSVD0_6               => C_PF2_ENTRY_RSVD0_6,
	    	  C_ENTRY_TYPE_7                => C_PF2_ENTRY_TYPE_7,
	    	  C_ENTRY_BAR_7                 => C_PF2_ENTRY_BAR_7,
	    	  C_ENTRY_ADDR_7                => C_PF2_ENTRY_ADDR_7,
	    	  C_ENTRY_MAJOR_VERSION_7       => C_PF2_ENTRY_MAJOR_VERSION_7,
	    	  C_ENTRY_MINOR_VERSION_7       => C_PF2_ENTRY_MINOR_VERSION_7,
	    	  C_ENTRY_VERSION_TYPE_7        => C_PF2_ENTRY_VERSION_TYPE_7,
	    	  C_ENTRY_RSVD0_7               => C_PF2_ENTRY_RSVD0_7,
	    	  C_ENTRY_TYPE_8                => C_PF2_ENTRY_TYPE_8,
	    	  C_ENTRY_BAR_8                 => C_PF2_ENTRY_BAR_8,
	    	  C_ENTRY_ADDR_8                => C_PF2_ENTRY_ADDR_8,
	    	  C_ENTRY_MAJOR_VERSION_8       => C_PF2_ENTRY_MAJOR_VERSION_8,
	    	  C_ENTRY_MINOR_VERSION_8       => C_PF2_ENTRY_MINOR_VERSION_8,
	    	  C_ENTRY_VERSION_TYPE_8        => C_PF2_ENTRY_VERSION_TYPE_8,
	    	  C_ENTRY_RSVD0_8               => C_PF2_ENTRY_RSVD0_8,
	    	  C_ENTRY_TYPE_9                => C_PF2_ENTRY_TYPE_9,
	    	  C_ENTRY_BAR_9                 => C_PF2_ENTRY_BAR_9,
	    	  C_ENTRY_ADDR_9                => C_PF2_ENTRY_ADDR_9,
	    	  C_ENTRY_MAJOR_VERSION_9       => C_PF2_ENTRY_MAJOR_VERSION_9,
	    	  C_ENTRY_MINOR_VERSION_9       => C_PF2_ENTRY_MINOR_VERSION_9,
	    	  C_ENTRY_VERSION_TYPE_9        => C_PF2_ENTRY_VERSION_TYPE_9,
	    	  C_ENTRY_RSVD0_9               => C_PF2_ENTRY_RSVD0_9,
	    	  C_ENTRY_TYPE_10               => C_PF2_ENTRY_TYPE_10,
	    	  C_ENTRY_BAR_10                => C_PF2_ENTRY_BAR_10,
	    	  C_ENTRY_ADDR_10               => C_PF2_ENTRY_ADDR_10,
	    	  C_ENTRY_MAJOR_VERSION_10      => C_PF2_ENTRY_MAJOR_VERSION_10,
	    	  C_ENTRY_MINOR_VERSION_10      => C_PF2_ENTRY_MINOR_VERSION_10,
	    	  C_ENTRY_VERSION_TYPE_10       => C_PF2_ENTRY_VERSION_TYPE_10,
	    	  C_ENTRY_RSVD0_10              => C_PF2_ENTRY_RSVD0_10,
	    	  C_ENTRY_TYPE_11               => C_PF2_ENTRY_TYPE_11,
	    	  C_ENTRY_BAR_11                => C_PF2_ENTRY_BAR_11,
	    	  C_ENTRY_ADDR_11               => C_PF2_ENTRY_ADDR_11,
	    	  C_ENTRY_MAJOR_VERSION_11      => C_PF2_ENTRY_MAJOR_VERSION_11,
	    	  C_ENTRY_MINOR_VERSION_11      => C_PF2_ENTRY_MINOR_VERSION_11,
	    	  C_ENTRY_VERSION_TYPE_11       => C_PF2_ENTRY_VERSION_TYPE_11,
	    	  C_ENTRY_RSVD0_11              => C_PF2_ENTRY_RSVD0_11,
	    	  C_ENTRY_TYPE_12               => C_PF2_ENTRY_TYPE_12,
	    	  C_ENTRY_BAR_12                => C_PF2_ENTRY_BAR_12,
	    	  C_ENTRY_ADDR_12               => C_PF2_ENTRY_ADDR_12,
	    	  C_ENTRY_MAJOR_VERSION_12      => C_PF2_ENTRY_MAJOR_VERSION_12,
	    	  C_ENTRY_MINOR_VERSION_12      => C_PF2_ENTRY_MINOR_VERSION_12,
	    	  C_ENTRY_VERSION_TYPE_12       => C_PF2_ENTRY_VERSION_TYPE_12,
	    	  C_ENTRY_RSVD0_12              => C_PF2_ENTRY_RSVD0_12,
	    	  C_ENTRY_TYPE_13               => C_PF2_ENTRY_TYPE_13,
	    	  C_ENTRY_BAR_13                => C_PF2_ENTRY_BAR_13,
	    	  C_ENTRY_ADDR_13               => C_PF2_ENTRY_ADDR_13,
	    	  C_ENTRY_MAJOR_VERSION_13      => C_PF2_ENTRY_MAJOR_VERSION_13,
	    	  C_ENTRY_MINOR_VERSION_13      => C_PF2_ENTRY_MINOR_VERSION_13,
	    	  C_ENTRY_VERSION_TYPE_13       => C_PF2_ENTRY_VERSION_TYPE_13,
	    	  C_ENTRY_RSVD0_13              => C_PF2_ENTRY_RSVD0_13,
	    	  C_ENTRY_TYPE_14               => C_PF2_ENTRY_TYPE_14,
	    	  C_ENTRY_BAR_14                => C_PF2_ENTRY_BAR_14,
	    	  C_ENTRY_ADDR_14               => C_PF2_ENTRY_ADDR_14,
	    	  C_ENTRY_MAJOR_VERSION_14      => C_PF2_ENTRY_MAJOR_VERSION_14,
	    	  C_ENTRY_MINOR_VERSION_14      => C_PF2_ENTRY_MINOR_VERSION_14,
	    	  C_ENTRY_VERSION_TYPE_14       => C_PF2_ENTRY_VERSION_TYPE_14,
	    	  C_ENTRY_RSVD0_14              => C_PF2_ENTRY_RSVD0_14,
	    	  C_ENTRY_TYPE_15               => C_PF2_ENTRY_TYPE_15,
	    	  C_ENTRY_BAR_15                => C_PF2_ENTRY_BAR_15,
	    	  C_ENTRY_ADDR_15               => C_PF2_ENTRY_ADDR_15,
	    	  C_ENTRY_MAJOR_VERSION_15      => C_PF2_ENTRY_MAJOR_VERSION_15,
	    	  C_ENTRY_MINOR_VERSION_15      => C_PF2_ENTRY_MINOR_VERSION_15,
	    	  C_ENTRY_VERSION_TYPE_15       => C_PF2_ENTRY_VERSION_TYPE_15,
	    	  C_ENTRY_RSVD0_15              => C_PF2_ENTRY_RSVD0_15,
	    	  C_S_AXI_DATA_WIDTH            => C_PF2_S_AXI_DATA_WIDTH,
	    	  C_S_AXI_ADDR_WIDTH            => C_PF2_S_AXI_ADDR_WIDTH,
	    	  C_XDEVICEFAMILY               => C_XDEVICEFAMILY
	    	)
		    port map (
			    S_AXI_ACLK            		    => aclk_ctrl,
			    S_AXI_ARESETN         		    => aresetn_ctrl,
		    	S_AXI_AWADDR              		=> s_axi_ctrl_pf2_AWADDR,
		    	S_AXI_AWVALID             		=> s_axi_ctrl_pf2_AWVALID,
		    	S_AXI_AWREADY             		=> s_axi_ctrl_pf2_AWREADY,
		    	S_AXI_WDATA               		=> s_axi_ctrl_pf2_WDATA,
		    	S_AXI_WSTRB               		=> s_axi_ctrl_pf2_WSTRB,
		    	S_AXI_WVALID              		=> s_axi_ctrl_pf2_WVALID,
		    	S_AXI_WREADY              		=> s_axi_ctrl_pf2_WREADY,
		    	S_AXI_BRESP               		=> s_axi_ctrl_pf2_BRESP,
		    	S_AXI_BVALID              		=> s_axi_ctrl_pf2_BVALID,
		    	S_AXI_BREADY              		=> s_axi_ctrl_pf2_BREADY,
		    	S_AXI_ARADDR              		=> s_axi_ctrl_pf2_ARADDR,
		    	S_AXI_ARVALID             		=> s_axi_ctrl_pf2_ARVALID,
		    	S_AXI_ARREADY             		=> s_axi_ctrl_pf2_ARREADY,
		    	S_AXI_RDATA               		=> s_axi_ctrl_pf2_RDATA,
		    	S_AXI_RRESP               		=> s_axi_ctrl_pf2_RRESP,
		    	S_AXI_RVALID              		=> s_axi_ctrl_pf2_RVALID,
		    	S_AXI_RREADY              		=> s_axi_ctrl_pf2_RREADY
		    );

			end generate G_GENERATE_PF2;

		G_GENERATE_PF3 : if (i = 3) generate

	  	-- Instantiate BAR Layout table
			BAR_LAYOUT_TABLE_inst_3 : entity hw_discovery_v1_0_1.hw_discovery_v1_0_1_bar_layout_table
	    	generic map (
	    		C_NUM_SLOTS_BAR_LAYOUT_TABLE  => C_PF3_NUM_SLOTS_BAR_LAYOUT_TABLE,
	    		C_ENTRY_TYPE_0                => C_PF3_ENTRY_TYPE_0,
	    		C_ENTRY_BAR_0                 => C_PF3_ENTRY_BAR_0,
	    		C_ENTRY_ADDR_0                => C_PF3_ENTRY_ADDR_0,
	    		C_ENTRY_MAJOR_VERSION_0       => C_PF3_ENTRY_MAJOR_VERSION_0,
	    		C_ENTRY_MINOR_VERSION_0       => C_PF3_ENTRY_MINOR_VERSION_0,
	    		C_ENTRY_VERSION_TYPE_0        => C_PF3_ENTRY_VERSION_TYPE_0,
	    		C_ENTRY_RSVD0_0               => C_PF3_ENTRY_RSVD0_0,
	    		C_ENTRY_TYPE_1                => C_PF3_ENTRY_TYPE_1,
	    		C_ENTRY_BAR_1                 => C_PF3_ENTRY_BAR_1,
	    		C_ENTRY_ADDR_1                => C_PF3_ENTRY_ADDR_1,
	    		C_ENTRY_MAJOR_VERSION_1       => C_PF3_ENTRY_MAJOR_VERSION_1,
	    		C_ENTRY_MINOR_VERSION_1       => C_PF3_ENTRY_MINOR_VERSION_1,
	    		C_ENTRY_VERSION_TYPE_1        => C_PF3_ENTRY_VERSION_TYPE_1,
	    		C_ENTRY_RSVD0_1               => C_PF3_ENTRY_RSVD0_1,
	    		C_ENTRY_TYPE_2                => C_PF3_ENTRY_TYPE_2,
	    		C_ENTRY_BAR_2                 => C_PF3_ENTRY_BAR_2,
	    		C_ENTRY_ADDR_2                => C_PF3_ENTRY_ADDR_2,
	    		C_ENTRY_MAJOR_VERSION_2       => C_PF3_ENTRY_MAJOR_VERSION_2,
	    		C_ENTRY_MINOR_VERSION_2       => C_PF3_ENTRY_MINOR_VERSION_2,
	    		C_ENTRY_VERSION_TYPE_2        => C_PF3_ENTRY_VERSION_TYPE_2,
	    		C_ENTRY_RSVD0_2               => C_PF3_ENTRY_RSVD0_2,
	    		C_ENTRY_TYPE_3                => C_PF3_ENTRY_TYPE_3,
	    		C_ENTRY_BAR_3                 => C_PF3_ENTRY_BAR_3,
	    		C_ENTRY_ADDR_3                => C_PF3_ENTRY_ADDR_3,
	    		C_ENTRY_MAJOR_VERSION_3       => C_PF3_ENTRY_MAJOR_VERSION_3,
	    		C_ENTRY_MINOR_VERSION_3       => C_PF3_ENTRY_MINOR_VERSION_3,
	    		C_ENTRY_VERSION_TYPE_3        => C_PF3_ENTRY_VERSION_TYPE_3,
	    		C_ENTRY_RSVD0_3               => C_PF3_ENTRY_RSVD0_3,
	    		C_ENTRY_TYPE_4                => C_PF3_ENTRY_TYPE_4,
	    		C_ENTRY_BAR_4                 => C_PF3_ENTRY_BAR_4,
	    		C_ENTRY_ADDR_4                => C_PF3_ENTRY_ADDR_4,
	    		C_ENTRY_MAJOR_VERSION_4       => C_PF3_ENTRY_MAJOR_VERSION_4,
	    		C_ENTRY_MINOR_VERSION_4       => C_PF3_ENTRY_MINOR_VERSION_4,
	    		C_ENTRY_VERSION_TYPE_4        => C_PF3_ENTRY_VERSION_TYPE_4,
	    		C_ENTRY_RSVD0_4               => C_PF3_ENTRY_RSVD0_4,
	    		C_ENTRY_TYPE_5                => C_PF3_ENTRY_TYPE_5,
	    		C_ENTRY_BAR_5                 => C_PF3_ENTRY_BAR_5,
	    		C_ENTRY_ADDR_5                => C_PF3_ENTRY_ADDR_5,
	    		C_ENTRY_MAJOR_VERSION_5       => C_PF3_ENTRY_MAJOR_VERSION_5,
	    		C_ENTRY_MINOR_VERSION_5       => C_PF3_ENTRY_MINOR_VERSION_5,
	    		C_ENTRY_VERSION_TYPE_5        => C_PF3_ENTRY_VERSION_TYPE_5,
	    		C_ENTRY_RSVD0_5               => C_PF3_ENTRY_RSVD0_5,
	    		C_ENTRY_TYPE_6                => C_PF3_ENTRY_TYPE_6,
	    		C_ENTRY_BAR_6                 => C_PF3_ENTRY_BAR_6,
	    		C_ENTRY_ADDR_6                => C_PF3_ENTRY_ADDR_6,
	    		C_ENTRY_MAJOR_VERSION_6       => C_PF3_ENTRY_MAJOR_VERSION_6,
	    		C_ENTRY_MINOR_VERSION_6       => C_PF3_ENTRY_MINOR_VERSION_6,
	    		C_ENTRY_VERSION_TYPE_6        => C_PF3_ENTRY_VERSION_TYPE_6,
	    		C_ENTRY_RSVD0_6               => C_PF3_ENTRY_RSVD0_6,
	    		C_ENTRY_TYPE_7                => C_PF3_ENTRY_TYPE_7,
	    		C_ENTRY_BAR_7                 => C_PF3_ENTRY_BAR_7,
	    		C_ENTRY_ADDR_7                => C_PF3_ENTRY_ADDR_7,
	    		C_ENTRY_MAJOR_VERSION_7       => C_PF3_ENTRY_MAJOR_VERSION_7,
	    		C_ENTRY_MINOR_VERSION_7       => C_PF3_ENTRY_MINOR_VERSION_7,
	    		C_ENTRY_VERSION_TYPE_7        => C_PF3_ENTRY_VERSION_TYPE_7,
	    		C_ENTRY_RSVD0_7               => C_PF3_ENTRY_RSVD0_7,
	    		C_ENTRY_TYPE_8                => C_PF3_ENTRY_TYPE_8,
	    		C_ENTRY_BAR_8                 => C_PF3_ENTRY_BAR_8,
	    		C_ENTRY_ADDR_8                => C_PF3_ENTRY_ADDR_8,
	    		C_ENTRY_MAJOR_VERSION_8       => C_PF3_ENTRY_MAJOR_VERSION_8,
	    		C_ENTRY_MINOR_VERSION_8       => C_PF3_ENTRY_MINOR_VERSION_8,
	    		C_ENTRY_VERSION_TYPE_8        => C_PF3_ENTRY_VERSION_TYPE_8,
	    		C_ENTRY_RSVD0_8               => C_PF3_ENTRY_RSVD0_8,
	    		C_ENTRY_TYPE_9                => C_PF3_ENTRY_TYPE_9,
	    		C_ENTRY_BAR_9                 => C_PF3_ENTRY_BAR_9,
	    		C_ENTRY_ADDR_9                => C_PF3_ENTRY_ADDR_9,
	    		C_ENTRY_MAJOR_VERSION_9       => C_PF3_ENTRY_MAJOR_VERSION_9,
	    		C_ENTRY_MINOR_VERSION_9       => C_PF3_ENTRY_MINOR_VERSION_9,
	    		C_ENTRY_VERSION_TYPE_9        => C_PF3_ENTRY_VERSION_TYPE_9,
	    		C_ENTRY_RSVD0_9               => C_PF3_ENTRY_RSVD0_9,
	    		C_ENTRY_TYPE_10               => C_PF3_ENTRY_TYPE_10,
	    		C_ENTRY_BAR_10                => C_PF3_ENTRY_BAR_10,
	    		C_ENTRY_ADDR_10               => C_PF3_ENTRY_ADDR_10,
	    		C_ENTRY_MAJOR_VERSION_10      => C_PF3_ENTRY_MAJOR_VERSION_10,
	    		C_ENTRY_MINOR_VERSION_10      => C_PF3_ENTRY_MINOR_VERSION_10,
	    		C_ENTRY_VERSION_TYPE_10       => C_PF3_ENTRY_VERSION_TYPE_10,
	    		C_ENTRY_RSVD0_10              => C_PF3_ENTRY_RSVD0_10,
	    		C_ENTRY_TYPE_11               => C_PF3_ENTRY_TYPE_11,
	    		C_ENTRY_BAR_11                => C_PF3_ENTRY_BAR_11,
	    		C_ENTRY_ADDR_11               => C_PF3_ENTRY_ADDR_11,
	    		C_ENTRY_MAJOR_VERSION_11      => C_PF3_ENTRY_MAJOR_VERSION_11,
	    		C_ENTRY_MINOR_VERSION_11      => C_PF3_ENTRY_MINOR_VERSION_11,
	    		C_ENTRY_VERSION_TYPE_11       => C_PF3_ENTRY_VERSION_TYPE_11,
	    		C_ENTRY_RSVD0_11              => C_PF3_ENTRY_RSVD0_11,
	    		C_ENTRY_TYPE_12               => C_PF3_ENTRY_TYPE_12,
	    		C_ENTRY_BAR_12                => C_PF3_ENTRY_BAR_12,
	    		C_ENTRY_ADDR_12               => C_PF3_ENTRY_ADDR_12,
	    		C_ENTRY_MAJOR_VERSION_12      => C_PF3_ENTRY_MAJOR_VERSION_12,
	    		C_ENTRY_MINOR_VERSION_12      => C_PF3_ENTRY_MINOR_VERSION_12,
	    		C_ENTRY_VERSION_TYPE_12       => C_PF3_ENTRY_VERSION_TYPE_12,
	    		C_ENTRY_RSVD0_12              => C_PF3_ENTRY_RSVD0_12,
	    		C_ENTRY_TYPE_13               => C_PF3_ENTRY_TYPE_13,
	    		C_ENTRY_BAR_13                => C_PF3_ENTRY_BAR_13,
	    		C_ENTRY_ADDR_13               => C_PF3_ENTRY_ADDR_13,
	    		C_ENTRY_MAJOR_VERSION_13      => C_PF3_ENTRY_MAJOR_VERSION_13,
	    		C_ENTRY_MINOR_VERSION_13      => C_PF3_ENTRY_MINOR_VERSION_13,
	    		C_ENTRY_VERSION_TYPE_13       => C_PF3_ENTRY_VERSION_TYPE_13,
	    		C_ENTRY_RSVD0_13              => C_PF3_ENTRY_RSVD0_13,
	    		C_ENTRY_TYPE_14               => C_PF3_ENTRY_TYPE_14,
	    		C_ENTRY_BAR_14                => C_PF3_ENTRY_BAR_14,
	    		C_ENTRY_ADDR_14               => C_PF3_ENTRY_ADDR_14,
	    		C_ENTRY_MAJOR_VERSION_14      => C_PF3_ENTRY_MAJOR_VERSION_14,
	    		C_ENTRY_MINOR_VERSION_14      => C_PF3_ENTRY_MINOR_VERSION_14,
	    		C_ENTRY_VERSION_TYPE_14       => C_PF3_ENTRY_VERSION_TYPE_14,
	    		C_ENTRY_RSVD0_14              => C_PF3_ENTRY_RSVD0_14,
	    		C_ENTRY_TYPE_15               => C_PF3_ENTRY_TYPE_15,
	    		C_ENTRY_BAR_15                => C_PF3_ENTRY_BAR_15,
	    		C_ENTRY_ADDR_15               => C_PF3_ENTRY_ADDR_15,
	    		C_ENTRY_MAJOR_VERSION_15      => C_PF3_ENTRY_MAJOR_VERSION_15,
	    		C_ENTRY_MINOR_VERSION_15      => C_PF3_ENTRY_MINOR_VERSION_15,
	    		C_ENTRY_VERSION_TYPE_15       => C_PF3_ENTRY_VERSION_TYPE_15,
	    		C_ENTRY_RSVD0_15              => C_PF3_ENTRY_RSVD0_15,
	    		C_S_AXI_DATA_WIDTH            => C_PF3_S_AXI_DATA_WIDTH,
	    		C_S_AXI_ADDR_WIDTH            => C_PF3_S_AXI_ADDR_WIDTH,
	    		C_XDEVICEFAMILY               => C_XDEVICEFAMILY
	    		)
		    port map (
			    S_AXI_ACLK            		    => aclk_ctrl,
			    S_AXI_ARESETN         		    => aresetn_ctrl,
		    	S_AXI_AWADDR              		=> s_axi_ctrl_pf3_AWADDR,
		    	S_AXI_AWVALID             		=> s_axi_ctrl_pf3_AWVALID,
		    	S_AXI_AWREADY             		=> s_axi_ctrl_pf3_AWREADY,
		    	S_AXI_WDATA               		=> s_axi_ctrl_pf3_WDATA,
		    	S_AXI_WSTRB               		=> s_axi_ctrl_pf3_WSTRB,
		    	S_AXI_WVALID              		=> s_axi_ctrl_pf3_WVALID,
		    	S_AXI_WREADY              		=> s_axi_ctrl_pf3_WREADY,
		    	S_AXI_BRESP               		=> s_axi_ctrl_pf3_BRESP,
		    	S_AXI_BVALID              		=> s_axi_ctrl_pf3_BVALID,
		    	S_AXI_BREADY              		=> s_axi_ctrl_pf3_BREADY,
		    	S_AXI_ARADDR              		=> s_axi_ctrl_pf3_ARADDR,
		    	S_AXI_ARVALID             		=> s_axi_ctrl_pf3_ARVALID,
		    	S_AXI_ARREADY             		=> s_axi_ctrl_pf3_ARREADY,
		    	S_AXI_RDATA               		=> s_axi_ctrl_pf3_RDATA,
		    	S_AXI_RRESP               		=> s_axi_ctrl_pf3_RRESP,
		    	S_AXI_RVALID              		=> s_axi_ctrl_pf3_RVALID,
		    	S_AXI_RREADY              		=> s_axi_ctrl_pf3_RREADY
		    );

			end generate G_GENERATE_PF3;

		end generate G_GENERATE;

end architecture rtl;


