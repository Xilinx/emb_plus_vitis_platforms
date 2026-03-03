# Copyright (C) 2023 - 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

#!/usr/bin/python3

import os
import re
import sys
import argparse

parser = argparse.ArgumentParser(description="Partition_metadata generation - required files")
parser.add_argument("-pdi", required=True, help="Project_Partial.pdi (partial PDI image) required")
parser.add_argument("-config", required=True, help="config_bd.tcl file")
parser.add_argument("-ulp", required=True, help="ulp.tcl file")
parser.add_argument("-o", "--output", help="metadata file name", default="./partition_metadata.json")

args = parser.parse_args()
pdi_file_name = args.pdi
config_bd_file_path = args.config
ulp_file_path = args.ulp
platform_json_path = "./platform.json"
metadata_file_path = args.output
current_path = os.getcwd()
generated_file_name = "partition_metadata.json  "  # Generated file name "partition_metadata.json"
partition_info_str = '''        "partition_info": {'''
card = 've2302'
family = 'pcie_xdma'
package_name = 'xilinx-ve2302-pcie_xdma-base'
package_version = '1'
package_release = '20230914'
build_changelist = ''
hardware_changelist = ''
dtb_commithash = 'db419fa'

###############################################################
#                  UUID Variables                             #
#                                                             #
###############################################################

### Bootgen variables

uuid_txt_file = "uuid_data.txt"
uuid_file_path = current_path + "/" + uuid_txt_file
cmd = "bootgen -arch versal -read {} > {}"  ## Bootgen run and save output to txt file (overwrite old)

## UUIDs variables

idRegex = re.compile(r'id \(0x18\) : 0x([0-9a-fA-F]+)')
uniqueIdRegexp = re.compile(r'unique_id \(0x24\) : 0x([0-9a-fA-F]+)')
parentIdRegexp = re.compile(r'parent_unique_id \(0x28\) : 0x([0-9a-fA-F]+)')
functionIdRegexp = re.compile(r'function_id \(0x2c\) : 0x([0-9a-fA-F]+)')
logic_uuid = "733815cb9a3ad6ed7dd5b94fdbafb6cf"      ### To be determined later
major = "0x1"                                        ### To be determined later
minor = "0x0"                                        ### To be determined later

###############################################################
#         Metadata Variables                                  #
#                                                             #
###############################################################

########## Platform.json file generation ##########
ddr_version = "1.0"

parition_header_str = '''{{
    "meminfo": [
    {{
        "type": "{memory_type}",
        "banks": [
           '''

mem_bank_str = '''{{                 "name": "{bank_name}"             }}'''

meminfo_closing_str = '''        ]
    }}
    ],
    "total_ddr_banks": "{ddr_bank_count}",
    "version": "{ddr_version}"
}}
'''

memory_type_Regex = re.compile(r'CONFIG.CONTROLLERTYPE \{([0-9a-zA-Z_]+)\} \\')
ddr_bank_count_Regex = re.compile(r'CONFIG.MC_CHAN_REGION\d \{([0-9a-fA-F]+)\} \\')
bank_name_line_Regex = re.compile(r'set_property PFM.AXI_PORT {S\d\d_AXI')
bank_name_Regex = re.compile(r'sptag \"([0-9a-zA-Z_]+)\" memory')

def extract_memory_type_count(config_bd_file_path):
    with open(config_bd_file_path, 'r') as file:
        bank_count = 0
        memory_type = None
        for line in file:
            if "CONFIG.CONTROLLERTYPE" in line:
                memory_type_mo = memory_type_Regex.search(line)
                memory_type = memory_type_mo.group(1)
            if "CONFIG.MC_CHAN_REGION" in line:
                bank_count = bank_count + 1
    return bank_count, memory_type

def extract_bank_name(ulp_file_path):
    with open(ulp_file_path, 'r') as file:
        bank_name = None
        for line in file:
            if bank_name_line_Regex.search(line):
                bank_name_mo = bank_name_Regex.search(line)
                bank_name = bank_name_mo.group(1)
    return bank_name

## Addressable reserved memory variables ==> Should be editable if needed
mem_name = "ep_reserved_ps_mem_00"
mem_reg_abst_name = "xilinx.com:reg_abs:ps_memory:1.0"
mem_pf = "0x1"
mem_base_addr = "0x2"

partition_header_str_1 = '''{
    "partition_metadata":
    {'''

partition_header_str_2 = '''        "schema_version":
        {{
            "major": "{major}",
            "minor": "{minor}"
        }},'''

partition_header_str_3 = '''        "logic_uuid": "{logic_uuid}",
        "interfaces":
        ['''

partition_header_str_4 = '''            {{
                "interface_uuid": "{interface_uuid}"
            }}'''

partition_header_str_5 = '''        ],
        "pcie":
        {'''

partition_header_str_6 = '''            "bars":
            ['''

bar_string = '''                {{
                    "pcie_base_address_register": "0x{bar_base_address}",
                    "pcie_physical_function": "0x{bar_pf}",
                    "offset": "{bar_offset}",
                    "range": "{bar_range}"
                }}'''

## This is for addressable_endpoints reserved memory

res_mem_string = '''            \"{mem_name}\":
            {{
                \"offset\" : \"{offset}\",
                \"range\" : \"{mem_range}\",
                \"pcie_base_address_register\" : \"{mem_base_addr}\",
                \"pcie_physical_function\" : \"{mem_pf}\",
                \"register_abstraction_name\" : \"{mem_reg_abst_name}\"
            }},            '''

pcie_bars_closing_str = '''            ]
        },'''

revision_control_str = '''            "revision_control" : {{
                "card" : "{card}",
                "family" : "{family}",
                "package_name" : "{package_name}",
                "package_version" : "{package_version}",
                "package_release" : "{package_release}",
                "build_changelist" : "{build_changelist}",
                "hardware_changelist" : "{hardware_changelist}",
                "dtb_commithash" : "{dtb_commithash}"
            }}'''

partition_closing_str = '''        },'''

addressable_endpoints_str = '''        "addressable_endpoints":
        {'''
addressable_endpoints = """            \"{ep_name}\":
            {{
                \"offset\": \"{ep_offset}\",
                \"range\": \"{ep_range}\",
                \"pcie_physical_function\": \"0x{ep_pf}\",
                \"pcie_base_address_register\": \"0x{ep_base_address}\"
            }}"""

closing_str = '''        }
    }
}'''

# Regular expressions

ep_res_mem_Regex = re.compile(r' -offset (0x[0-9a-fA-F]+) -range (0x[0-9a-fA-F]+)')

# Detect enabled bars inside the xdma block: 'CONFIG.pfX_barY_64bit {true}'
pf_Regex = re.compile(r'CONFIG\.pf(\d)_bar(\d)_64bit\s*\{true\}')

# Scale/size without _xdma
bar_scale_Regex = re.compile(r'CONFIG\.pf\d_bar\d_scale\s*\{([0-9a-zA-Z]+)\}')
bar_size_Regex = re.compile(r'CONFIG\.pf\d_bar\d_size\s*\{(\d+)\}')

connected_bd_cell_Regex = re.compile(r'get_bd_cells /([0-9a-zA-Z_]+)/([0-9a-zA-Z_]+)/([0-9a-zA-Z_/]+)]')
only_ep_Regex = re.compile(r'ep_([0-9a-zA-Z_]+)')
ep_partRegex = re.compile(r'([0-9a-zA-Z_]+) ([dict create)? ep_([0-9a-zA-Z_]+)')

##actual_range = "0x{:016x}".format(bar_range)
ep_properties_Regex = re.compile(r' -offset (0x[0-9a-fA-F]+) -range (0x[0-9a-fA-F]+)')

###############################################################
#                        RAVE Variables                       #
#                                                             #
###############################################################

ep_xdma_00_str = addressable_endpoints.format(ep_name="ep_xdma_00", ep_offset="0x0000000000000000", ep_range="0x0000000000040000", ep_pf="1", ep_base_address="4")

ep_xgq_payload_mgmt_str = addressable_endpoints.format(ep_name="ep_xgq_payload_mgmt_00", ep_offset="0x0000000008000000", ep_range="0x0000000008000000", ep_pf="0", ep_base_address="0")
ep_xgq_payload_usr_str = addressable_endpoints.format(ep_name="ep_xgq_payload_user_00", ep_offset="0x0000000006000000", ep_range="0x0000000001000000", ep_pf="1", ep_base_address="4")

# -------------------------------------------------------------------
# Hardcoded BAR address mapping (replaces parsing of pciebar2axibar)
# Keys are tuples of strings: (pf, bar). Values are 64-bit hex strings.
# -------------------------------------------------------------------
HARD_CODED_PF_BAR_TO_AXIBAR = {
    ("0", "0"): "0x0000020100000000",
    ("0", "2"): "0x0000000000000000",
    ("0", "4"): "0x0000000000000000",
    ("1", "0"): "0x0000000000000000",
    ("1", "2"): "0x0000000000000000",
    ("1", "4"): "0x0000020200000000",
}

##### Running bootgen and getting IDs
def run_bootgen(pdi_file_name, uuid_txt_file):
    command = cmd.format(pdi_file_name, uuid_txt_file)
    os.system(command)
    return os.path.abspath(uuid_txt_file)

## Function to extract IDs
def extract_uuid(uuid_file_path):
    with open(uuid_file_path, 'r') as file:
        correct_section = False
        for line in file:
            if "IMAGE HEADER (pl_cfi)" in line:
                correct_section = True
            if correct_section:
                if "id (0x18) :" in line:
                    id_mo = idRegex.findall(line)
                    uniqueId_mo = uniqueIdRegexp.findall(line)
                if "parent_unique_id (0x28) :" in line:
                    parentID_mo = parentIdRegexp.findall(line)
                    functionID_mo = functionIdRegexp.findall(line)
                if "IMAGE HEADER (aie2_subsys)" in line:
                    correct_section = False
    uuid_list = [id_mo[0], uniqueId_mo[0], parentID_mo[0], functionID_mo[0]]
    return uuid_list

def get_xdma_block_lines(config_bd_file_path):
    """Return lines between 'set xdma_0' and '$xdma_0'."""
    lines_in_block = []
    in_block = False
    with open(config_bd_file_path, 'r') as f:
        for line in f:
            if "set xdma_0" in line:
                in_block = True
            if in_block:
                lines_in_block.append(line)
            if "$xdma_0" in line and in_block:
                in_block = False
    return lines_in_block

# Return a list of tuples (pf, bar) for enabled bars inside the xdma block
def extract_xdma_bar_info(config_bd_file_path):
    pfbar_list = []
    for line in get_xdma_block_lines(config_bd_file_path):
        pf_mo = pf_Regex.search(line)
        if pf_mo:
            pfbar_tuple = (pf_mo.group(1), pf_mo.group(2))
            pfbar_list.append(pfbar_tuple)
    return pfbar_list

# Return address (hardcoded), scale, and size for each PF/BAR
def extract_bars_ranges_offsets(pfbar_list, config_bd_file_path):
    bar_address_list = []
    bar_scale_list = []
    bar_size_list = []

    block_lines = get_xdma_block_lines(config_bd_file_path)

    for pf, bar in pfbar_list:
        # Hardcoded offset mapping
        addr = HARD_CODED_PF_BAR_TO_AXIBAR.get((pf, bar), "0x0000000000000000")
        bar_address_list.append(addr)

        # Parse 'scale' and 'size'
        scale_re = re.compile(rf'CONFIG\.pf{pf}_bar{bar}_scale\s*\{{([0-9a-zA-Z]+)\}}')
        size_re = re.compile(rf'CONFIG\.pf{pf}_bar{bar}_size\s*\{{(\d+)\}}')

        scale_val = None
        size_val = None

        for line in block_lines:
            if scale_val is None:
                mo = scale_re.search(line)
                if mo:
                    scale_val = mo.group(1)
            if size_val is None:
                mo = size_re.search(line)
                if mo:
                    size_val = mo.group(1)
            if scale_val is not None and size_val is not None:
                break

        bar_scale_list.append(scale_val)
        bar_size_list.append(size_val)

    return bar_address_list, bar_scale_list, bar_size_list

# Compute byte ranges from size and scale
def get_range(bar_size_list, bar_scale_list):
    bar_range_list = []
    for i in range(len(bar_scale_list)):
        if bar_scale_list[i] == "Megabytes":
            bar_range = int(bar_size_list[i]) * 1024 * 1024
            actual_range = "0x{:016x}".format(bar_range)
            bar_range_list.append(actual_range)
        elif bar_scale_list[i] == "Kilobytes":
            bar_range = int(bar_size_list[i]) * 1024
            actual_range = "0x{:016x}".format(bar_range)
            bar_range_list.append(actual_range)
        else:
            # Fallback: treat as already in bytes
            bar_range = int(bar_size_list[i])
            actual_range = "0x{:016x}".format(bar_range)
            bar_range_list.append(actual_range)
    return bar_range_list

# Create a list of JSON fragments for bars
def write_bars(pfbar_list, bar_address_list, bar_range_list):
    bar_string_list = []
    j = 0
    for i in pfbar_list:
        bar_ba_str = i[1]
        bar_pf_str = i[0]
        bar_offset_str = bar_address_list[j]
        bar_range_str = bar_range_list[j]
        formatted_str = bar_string.format(bar_base_address=bar_ba_str, bar_pf=bar_pf_str, bar_offset=bar_offset_str, bar_range=bar_range_str)
        bar_string_list.append(formatted_str)
        j = j + 1
    return bar_string_list

def extract_mem_prop(config_bd_file_path):
    with open(config_bd_file_path, 'r') as file:
        for line in file:
            if "assign_bd_address" in line and "C0_DDR_CH1" in line and "xdma_0" in line:
                ep_res_mem_mo = ep_res_mem_Regex.search(line)
                offset_int = int(ep_res_mem_mo.group(1), 16)
                offset = "0x{:016x}".format(offset_int)
                mem_range_int = int(ep_res_mem_mo.group(2), 16)
                mem_range = "0x{:016x}".format(mem_range_int)
                break

        addressable_mem = res_mem_string.format(mem_name=mem_name, offset=offset, mem_range=mem_range, mem_base_addr=mem_base_addr, mem_pf=mem_pf, mem_reg_abst_name=mem_reg_abst_name)
    return addressable_mem

# Write the header part of the metadata file
def metadata_file_header(metadata_file_path):
    file = open(metadata_file_path, 'w')
    file.write(partition_header_str_1)
    file.write('\n')
    string2 = partition_header_str_2.format(major=major, minor=minor)
    file.write(string2)
    file.write('\n')
    string3 = partition_header_str_3.format(logic_uuid=logic_uuid)
    file.write(string3)
    file.write('\n')
    string4 = partition_header_str_4.format(interface_uuid=interface_uuid)
    file.write(string4)
    file.write('\n')
    file.write(partition_header_str_5)
    file.write('\n')
    file.write(partition_header_str_6)
    file.write('\n')
    file.close()

### Function to get the endpoints and return them in a list "endpoints"
def extract_endpoints(config_bd_file_path):
    with open(config_bd_file_path, 'r') as file:
        right_place = False
        endpoints = []
        end_points_list = []
        cells = []
        for line in file:
            if "set_property PFM.XRT_ENDPOINT" in line:
                right_place = True
                ep_list = []
            if right_place:
                if "ep_" in line:
                    ep_part_mo = ep_partRegex.search(line)
                    extract_ep_only = ep_part_mo.group(2)
                    if "[dict create" in extract_ep_only:
                        only_ep_mo = only_ep_Regex.search(extract_ep_only)
                        ep_tuple = (ep_part_mo.group(1), only_ep_mo.group(0))
                        ep_list.append(ep_tuple)
                    else:
                        ep_part_mo_str = ep_part_mo.group(2).replace(' ', '')
                        ep_tuple = (ep_part_mo.group(1), ep_part_mo_str)
                        ep_list.append(ep_tuple)
                    endpoints.append("ep_" + ep_part_mo[0])
                if "get_bd_cells /blp/blp_logic" in line:
                    connected_bd_cells_mo = connected_bd_cell_Regex.findall(line)
                    connected_tuple = connected_bd_cells_mo[0]
                    cells.append(connected_tuple[2])
                    end_points_list.append(ep_list)
                    right_place = False
    return cells, end_points_list

def extract_ep_features(cells, end_points_list, config_bd_file_path):
    ep_range_list = []
    ep_offset_list = []
    for i in range(len(cells)):
        for j in end_points_list[i]:
            ep_interface = j[0]
            searchable_str = "{}/{}".format(cells[i], ep_interface)
            with open(config_bd_file_path, 'r') as file:
                for line in file:
                    if "assign_bd_address" in line and searchable_str in line:
                        ep_properties_mo = ep_properties_Regex.search(line)
                        ep_offset = ep_properties_mo.group(1)
                        ep_offset_int = int(ep_offset, 16)
                        ep_offset_hex = "0x{:016x}".format(ep_offset_int)
                        ep_offset_list.append(ep_offset_hex)
                        ep_range = ep_properties_mo.group(2)
                        ep_range_int = int(ep_range, 16)
                        ep_range_hex = "0x{:016x}".format(ep_range_int)
                        ep_range_list.append(ep_range_hex)
                        break
    return ep_range_list, ep_offset_list

## Adjust endpoints offsets and derive PF and Base Address per endpoint
def ep_offset_pf_add_base_adj(ep_offset_list, bar_address_list, pfbar_list):
    adjusted_offset_list = []
    ep_pf_list = []
    ep_ba_list = []
    for i in ep_offset_list:
        z = i[0:11] + '0' * 7
        bar_index = bar_address_list.index(z)
        actual_offset = '0x' + '0' * 9 + i[11:21]
        adjusted_offset_list.append(actual_offset)
        bar_tuple = pfbar_list[bar_index]
        ep_pf = bar_tuple[0]
        ep_pf_list.append(ep_pf)
        ep_ba = bar_tuple[1]
        ep_ba_list.append(ep_ba)
    return ep_pf_list, ep_ba_list, adjusted_offset_list

def metadata_file_generation(metadata_file_path, config_bd_file_path):
    metadata_file_header(metadata_file_path)

    pfbar_list = extract_xdma_bar_info(config_bd_file_path)
    bar_address_list, bar_scale_list, bar_size_list = extract_bars_ranges_offsets(pfbar_list, config_bd_file_path)
    bar_range_list = get_range(bar_size_list, bar_scale_list)
    bar_string_list = write_bars(pfbar_list, bar_address_list, bar_range_list)

    file = open(metadata_file_path, 'a')
    for i in range(len(bar_string_list)):
        file.write(bar_string_list[i])
        if i < (len(bar_string_list) - 1):
            file.write(',')
        file.write('\n')

    file.write(pcie_bars_closing_str)
    file.write('\n')
    file.write(partition_info_str)
    file.write('\n')
    revision_ctrl_str = revision_control_str.format(card=card, family=family, package_name=package_name, package_version=package_version, package_release=package_release, build_changelist=build_changelist, hardware_changelist=hardware_changelist, dtb_commithash=dtb_commithash)
    file.write(revision_ctrl_str)
    file.write('\n')
    file.write(partition_closing_str)
    file.write('\n')
    file.write(addressable_endpoints_str)
    file.write('\n')
    addressable_mem = extract_mem_prop(config_bd_file_path)
    file.write(addressable_mem)
    file.write('\n')
    file.write(ep_xdma_00_str)
    file.write(',')
    file.write('\n')
    file.write(ep_xgq_payload_mgmt_str)
    file.write(',')
    file.write('\n')
    file.write(ep_xgq_payload_usr_str)
    file.write(',')
    file.write('\n')

    cells, end_points_list = extract_endpoints(config_bd_file_path)
    ep_range_list, ep_offset_list = extract_ep_features(cells, end_points_list, config_bd_file_path)
    ep_pf_list, ep_ba_list, adjusted_offset_list = ep_offset_pf_add_base_adj(ep_offset_list, bar_address_list, pfbar_list)

    endpoints_names_list = []
    for j in end_points_list:
        for l in j:
            endpoints_names_list.append(l[1])

    for k in range(len(endpoints_names_list)):
        endpoint_segment = addressable_endpoints.format(ep_name=endpoints_names_list[k], ep_offset=adjusted_offset_list[k], ep_range=ep_range_list[k], ep_pf=ep_pf_list[k], ep_base_address=ep_ba_list[k])
        file.write(endpoint_segment)
        if k < (len(endpoints_names_list) - 1):
            file.write(',')
        file.write('\n')

    file.write(closing_str)
    file.close()

    ### RAVE Specific strings
    msix_start_Str = '                "msix_interrupt_start_index": "0x0",'
    msix_end_str = '                "msix_interrupt_end_index": "0x0",'
    correct_endpoint_part = False

    with open(metadata_file_path, 'r') as file2:
        lines = file2.readlines()

    for i, line in enumerate(lines):
        if "ep_xgq_user_to_apu_sq_pi_00" in line:
            correct_endpoint_part = True
        if correct_endpoint_part and "pcie_physical_function" in line:
            lines.insert(i + 1, msix_start_Str)
            lines.insert(i + 2, '\n')
            lines.insert(i + 3, msix_end_str)
            lines.insert(i + 4, '\n')
            break

    with open(metadata_file_path, 'w') as file2:
        file2.writelines(lines)

# Function to write the platform.json file
def platform_json_generation(ulp_file_path, config_bd_file_path):
    bank_count, memory_type_str = extract_memory_type_count(config_bd_file_path)
    bank_count_str = str(bank_count)
    bank_name_str = extract_bank_name(ulp_file_path)
    file = open(platform_json_path, 'w')
    string1 = parition_header_str.format(memory_type=memory_type_str)
    file.write(string1)
    file.write('\n')
    string2 = mem_bank_str.format(bank_name=bank_name_str)
    file.write(string2)
    file.write('\n')
    string3 = meminfo_closing_str.format(ddr_bank_count=bank_count_str, ddr_version=ddr_version)
    file.write(string3)
    file.close()

# Generating platform.json file
platform_json_generation(ulp_file_path, config_bd_file_path)

## You can change the logic_uuid or interface_uuid here in case you need to overwrite it
uuid_file_location = run_bootgen(pdi_file_name, uuid_txt_file)
uuid_list = extract_uuid(uuid_file_location)  ## uuid_list = [[id,uniqueId,parentID,functionID]

## You can also change the id associated with either interface uuid or logic uuid in the following list assignment
interface_uuid_str = uuid_list[1]  # unique id
logic_uuid_str = uuid_list[1]      # unique id
interface_uuid_int = int(interface_uuid_str, 16)
logic_uuid_int = int(logic_uuid_str, 16)
interface_uuid = "{:032x}".format(interface_uuid_int)
logic_uuid = "{:032x}".format(logic_uuid_int)

metadata_file_generation(metadata_file_path, config_bd_file_path)
print("partition_metadata.json has been successfully generated!")
print("Please check the file located at " + metadata_file_path)
