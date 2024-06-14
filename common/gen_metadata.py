# Copyright (C) 2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

#!/usr/bin/python3

import os
import re
import sys
import argparse

parser = argparse.ArgumentParser(description="Partition_metadata generation - required files")
parser.add_argument("-pdi",required=True, help="Project_Partial.pdi (partial PDI image) required")
parser.add_argument("-config", required=True, help="config_bd.tcl file")
parser.add_argument("-o","--output", help="metadata file name", default="./overlay_partition_metadata.json")

args = parser.parse_args()
pdi_file_name = args.pdi
config_bd_file_path = args.config
metadata_file_path = args.output
current_path = os.getcwd()
generated_file_name = "overlay_partition_metadata.json  " # Generated file name "overlay_partition_metadata.json"


### Bootgen variables

uuid_txt_file = "uuid_data.txt"
uuid_file_path = current_path+"/"+ uuid_txt_file
cmd = "bootgen -arch versal -read {} > {}" ## Bootgen run and save output to txt file (overwrite old)


### UUIDs variables

idRegex = re.compile(r'id \(0x18\) : 0x([0-9a-fA-F]+)')
uniqueIdRegexp = re.compile (r'unique_id \(0x24\) : 0x([0-9a-fA-F]+)')
parentIdRegexp = re.compile (r'parent_unique_id \(0x28\) : 0x([0-9a-fA-F]+)')
functionIdRegexp = re.compile (r'function_id \(0x2c\) : 0x([0-9a-fA-F]+)')
major = "0x1"                                        ### To be determined later
minor = "0x0"                                        ### To be determined later

###############################################################
#         Metadata Variables                                  #
#                                                             #
###############################################################


partition_header_str_1 = '''{
    "partition_metadata":
    {'''

partition_header_str_2 = '''        "schema_version":
        {{
            "major": "{major}",
            "minor": "{minor}"
        }},'''

partition_header_str_3 = '''        "interfaces":
        ['''

partition_header_str_4 = '''            {{
                "interface_uuid": "{interface_uuid}"
            }}'''

partition_header_str_5 = '''        ],'''

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

### Regular expressions

romuuid_Regex = re.compile(r'CONFIG.C_INITIAL_UUID \{([0-9a-fA-F]+)\} \\')
ep_res_mem_Regex = re.compile(r' -offset (0x[0-9a-fA-F]+) -range (0x[0-9a-fA-F]+)')
pf_Regex = re.compile(r'CONFIG.pf(\d)_bar(\d)_64bit')
bar_address_Regex = re.compile(r'CONFIG.pf\d_pciebar2axibar_\d {(0x[0-9a-fA-F]+)} \\')
bar_scale_Regex = re.compile(r'CONFIG.pf\d_bar\d_scale_qdma {([0-9a-zA-Z]+)} \\')
bar_size_Regex = re.compile(r'CONFIG.pf\d_bar\d_size_qdma {(\d*)} \\')
connected_bd_cell_Regex = re.compile (r'get_bd_cells /([0-9a-zA-Z_]+)/([0-9a-zA-Z_]+)/([0-9a-zA-Z_/]+)]')
only_ep_Regex = re.compile (r'ep_([0-9a-zA-Z_]+)')
ep_partRegex = re.compile (r'([0-9a-zA-Z_]+) ([dict create)? ep_([0-9a-zA-Z_]+)')
ep_properties_Regex = re.compile(r' -offset (0x[0-9a-fA-F]+) -range (0x[0-9a-fA-F]+)')

###############################################################
#                        RAVE Variables                       #
#                                                             #
###############################################################


# Runs bootgen and gets IDs
def run_bootgen(pdi_file_name,uuid_txt_file):
    command = cmd.format(pdi_file_name, uuid_txt_file)
    os.system(command)
    return os.path.abspath(uuid_txt_file)       ##Returns absolute path of the file as string
# Extracts IDs
def extract_uuid(uuid_file_path):
    with open (uuid_file_path, 'r') as file:
        correct_section = False         # Checks the header (section) Image Header (pl_cfi)
        for line in file:
            if "IMAGE HEADER (pl_cfi)" in line:
                correct_section = True;             ## Right section of the file
            if correct_section:
                if "id (0x18) :" in line:
                    id_mo = idRegex.findall(line)
                    uniqueId_mo = uniqueIdRegexp.findall(line)
                if "parent_unique_id (0x28) :" in line:
                    parentID_mo = parentIdRegexp.findall(line)
                    functionID_mo = functionIdRegexp.findall(line)
                if "IMAGE HEADER (aie2_subsys)" in line:
                    correct_section = False;
    uuid_list = [id_mo[0],uniqueId_mo[0],parentID_mo[0],functionID_mo[0]]
    return uuid_list

# Returns a list of tuples including pf number and bar number
def extract_qdma_bar_info(config_bd_file_path):
    with open (config_bd_file_path, 'r') as file:
        pfbar_list =[]
        correct_part = False
        for line in file:
            if "set qdma_0" in line:
                correct_part = True
            if correct_part:
                if "CONFIG.pf" in line and "64bit_qdma" in line and "true" in line:
                    pf_mo = pf_Regex.search(line)
                    pfbar_tuple = (pf_mo.group(1),pf_mo.group(2))
                    pfbar_list.append(pfbar_tuple)
                if "$qdma_0" in line:
                    correct_part = False
    return pfbar_list

# Returns the range and offset for each PF and bar
def extract_bars_ranges_offsets(pfbar_list,config_bd_file_path):
    bar_address_list=[]
    bar_scale_list=[]
    bar_size_list=[]
    for bar in pfbar_list:
        searchable_address_str = "CONFIG.pf{}_pciebar2axibar_{}".format(bar[0],bar[1])
        searchable_scale_str = "CONFIG.pf{}_bar{}_scale_qdma".format(bar[0],bar[1])
        searchable_size_str = "CONFIG.pf{}_bar{}_size_qdma".format(bar[0],bar[1])
        correct_part = False
        with open (config_bd_file_path, 'r') as file:
            for line in file:
                if searchable_address_str in line:
                    bar_address_mo = bar_address_Regex.search(line)
                    bar_address_list.append(bar_address_mo.group(1))
                elif searchable_scale_str in line:
                    bar_scale_mo = bar_scale_Regex.search(line)
                    bar_scale_list.append(bar_scale_mo.group(1))
                elif searchable_size_str in line:
                    bar_size_mo = bar_size_Regex.search(line)
                    bar_size_list.append(bar_size_mo.group(1))
    return bar_address_list, bar_scale_list, bar_size_list

# Define actual range for each bar
def get_range(bar_size_list,bar_scale_list):
    bar_range_list=[]
    for i in range(len(bar_scale_list)):
        if bar_scale_list[i] == "Megabytes":
            bar_range= int(bar_size_list[i])*1024*1024
            actual_range = "0x{:016x}".format(bar_range)
            bar_range_list.append(actual_range)
        elif bar_scale_list[i] =="Kilobytes":
            bar_range= int(bar_size_list[i])*1024
            actual_range = "0x{:016x}".format(bar_range)
            bar_range_list.append(actual_range)
    return bar_range_list


# Creates a list of strings that are representing the bars that need to be included in the partition_metada file. This list should be used later when strings are appended to the generate metadata file 
def write_bars(pfbar_list,bar_address_list, bar_range_list):
    bar_string_list =[]
    j =0;
    for i in (pfbar_list):
        bar_ba_str = i[1]
        bar_pf_str = i[0]
        bar_offset_str = bar_address_list[j]
        bar_range_str = bar_range_list[j]
        formatted_str = bar_string.format(bar_base_address=bar_ba_str,bar_pf=bar_pf_str,bar_offset=bar_offset_str,bar_range=bar_range_str)
        bar_string_list.append(formatted_str)
        j=j+1;
    return bar_string_list

    
# Generates the partition_metadata file and append text to it
def metadata_file_header(metadata_file_path):
    file = open(metadata_file_path,'w')
    file.write(partition_header_str_1)
    file.write('\n')
    string2 = partition_header_str_2.format(major=major,minor=minor)
    file.write(string2)
    file.write('\n')
    file.write(partition_header_str_3)
    file.write('\n')
    string4 = partition_header_str_4.format(interface_uuid=interface_uuid)
    file.write(string4)
    file.write('\n')
    file.write(partition_header_str_5)
    file.write('\n')
    file.close()



# Gets the endpoints and returns them in a list "endpoints"
def extract_endpoints (config_bd_file_path):
    with open(config_bd_file_path, 'r') as file:
        right_place = False
        endpoints=[]
        end_points_list =[]
        cells = []
        for line in file:
            if "set_property PFM.XRT_ENDPOINT" in line:
                right_place = True;
                ep_list=[]
            if right_place:
                if "ep_" in line and "debug" in line:
                    ep_part_mo = ep_partRegex.search(line);
                    extract_ep_only = ep_part_mo.group(2)
                    if "[dict create" in extract_ep_only:
                        only_ep_mo = only_ep_Regex.search(extract_ep_only)
                        ep_tuple = (ep_part_mo.group(1),only_ep_mo.group(0))
                        ep_list.append(ep_tuple)
                    endpoints.append("ep_"+ep_part_mo[0])
                if "get_bd_cells /blp/blp_logic" in line and "dbg" in line:
                    connected_bd_cells_mo = connected_bd_cell_Regex.findall(line)
                    connected_tuple = connected_bd_cells_mo[0]
                    cells.append(connected_tuple[2])
                    end_points_list.append(ep_list)
                    right_place = False
    return cells,end_points_list


def extract_ep_features(cells, end_points_list, config_bd_file_path):
    ep_range_list=[]
    ep_offset_list=[]
    for i in range(len(cells)):
        for j in end_points_list[i]:
            ep_interface = j[0]
            searchable_str = "{}/{}".format(cells[i],ep_interface)
            with open (config_bd_file_path, 'r') as file:
                for line in file:
                    if "assign_bd_address" in line and searchable_str in line:
                        ep_properties_mo = ep_properties_Regex.search(line)
                        ep_offset = ep_properties_mo.group(1)
                        ep_offset_int = int(ep_offset,16)
                        ep_offset_hex = "0x{:016x}".format(ep_offset_int)
                        ep_offset_list.append(ep_offset_hex)
                        ep_range = ep_properties_mo.group(2)
                        ep_range_int = int(ep_range,16)
                        ep_range_hex = "0x{:016x}".format(ep_range_int)
                        ep_range_list.append(ep_range_hex)
                        break
    return ep_range_list, ep_offset_list

# Extracts the actual PF and Base address for each endpoint and adjust offsets 
def ep_offset_pf_add_base_adj(ep_offset_list,bar_address_list,pfbar_list):
    adjusted_offset_list = []
    ep_pf_list = []
    ep_ba_list = []
    for i in ep_offset_list:
        z = i[0:11]+'0'*7
        bar_index = bar_address_list.index(z)
        actual_offset = '0x'+'0'*9+i[11:21]
        adjusted_offset_list.append(actual_offset)
        bar_tuple = pfbar_list[bar_index]
        ep_pf = bar_tuple[0]
        ep_pf_list.append(ep_pf)
        ep_ba = bar_tuple[1]
        ep_ba_list.append(ep_ba)
    return ep_pf_list, ep_ba_list, adjusted_offset_list

def metadata_file_generation(metadata_file_path,config_bd_file_path):
    metadata_file_header(metadata_file_path)
    pfbar_list = extract_qdma_bar_info(config_bd_file_path)
    bar_address_list, bar_scale_list, bar_size_list = extract_bars_ranges_offsets(pfbar_list,config_bd_file_path)
    bar_range_list = get_range(bar_size_list,bar_scale_list)
    file = open(metadata_file_path,'a')
    file.write(addressable_endpoints_str)
    file.write('\n')
    cells,end_points_list = extract_endpoints (config_bd_file_path)
    ep_range_list, ep_offset_list  = extract_ep_features(cells, end_points_list, config_bd_file_path)
    ep_pf_list, ep_ba_list, adjusted_offset_list = ep_offset_pf_add_base_adj(ep_offset_list,bar_address_list,pfbar_list)

    endpoints_names_list = []
    for j in end_points_list:
        for l in j:
            endpoints_names_list.append(l[1])

    for k in range (len(endpoints_names_list)):
        endpoint_segment = addressable_endpoints.format(ep_name=endpoints_names_list[k],ep_offset=adjusted_offset_list[k], ep_range=ep_range_list[k], ep_pf=ep_pf_list[k], ep_base_address=ep_ba_list[k])
        file.write(endpoint_segment)
        if (k < (len(endpoints_names_list) -1 )):
            file.write(',')
        file.write('\n')

    file.write(closing_str)
    file.close()
    correct_endpoint_part = False



uuid_file_location = run_bootgen(pdi_file_name,uuid_txt_file)
uuid_list = extract_uuid(uuid_file_location)

# Interface ID from the list 
interface_uuid_str = uuid_list[2]
interface_uuid_int = int(interface_uuid_str,16)
interface_uuid = "{:032x}".format(interface_uuid_int)


metadata_file_generation(metadata_file_path,config_bd_file_path)
print("overlay_partition_metadata.json has been successfully generated!")
print("Please check the file located at " + metadata_file_path)

