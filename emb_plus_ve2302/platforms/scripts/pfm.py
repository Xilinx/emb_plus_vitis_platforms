# Copyright (C) 2023 - 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
#
# Platform creation script using Vitis Python API (replaces pfm.tcl / XSCT)
#
# Usage: vitis -s pfm.py -xsa <file> [-proc <processor>] [-out <dir>]

import sys
import os
import glob
import shutil

def parse_args(argv):
    """Parse command-line arguments."""
    args = {"proc": "psv_cortexa72", "out": ""}
    i = 0
    while i < len(argv):
        if argv[i] == "-xsa":
            i += 1
            args["xsa"] = argv[i]
        elif argv[i] == "-proc":
            i += 1
            args["proc"] = argv[i]
        elif argv[i] == "-out":
            i += 1
            args["out"] = argv[i]
        elif argv[i] == "-help":
            print("Usage: vitis -s pfm.py -xsa <file> [-proc <processor>] [-out <dir>]")
            print("  -xsa  <file>       XSA file location")
            print("  -proc <processor>  Processor (default: psv_cortexa72)")
            print("  -out  <dir>        Output directory for platform files")
            sys.exit(0)
        i += 1

    if "xsa" not in args:
        print("ERROR: -xsa argument is required")
        sys.exit(1)

    return args

def main():
    args = parse_args(sys.argv[1:])
    xsa_path = os.path.abspath(args["xsa"])
    platform_name = os.path.splitext(os.path.basename(xsa_path))[0]
    ws = os.path.join("xsct", platform_name)

    print(f"Creating platform '{platform_name}' from '{xsa_path}'")
    print(f"Workspace: {ws}")

    # Initialize Vitis client
    import vitis
    client = vitis.create_client()
    client.set_workspace(ws)

    # Create the platform component
    platform = client.create_platform_component(
        name=platform_name,
        hw_design=xsa_path,
        os="linux",
        cpu=args["proc"],
        domain_name="smp_linux",
        no_boot_bsp=True,
    )

    # Build (generate) the platform
    platform.build()

    # Find the generated xpfm and copy to output directory if specified
    if args["out"]:
        out_dir = os.path.abspath(args["out"])
        os.makedirs(out_dir, exist_ok=True)

        # Search for the generated xpfm in the workspace
        xpfm_files = glob.glob(os.path.join(ws, "**", "*.xpfm"), recursive=True)
        if not xpfm_files:
            print("ERROR: No .xpfm file found after platform generation")
            sys.exit(1)

        # Copy the entire export directory contents to the output directory
        xpfm_src = xpfm_files[0]
        export_dir = os.path.dirname(xpfm_src)
        print(f"Found platform at: {export_dir}")

        # Copy all files from the export directory
        for item in os.listdir(export_dir):
            src = os.path.join(export_dir, item)
            dst = os.path.join(out_dir, item)
            if os.path.isdir(src):
                if os.path.exists(dst):
                    shutil.rmtree(dst)
                shutil.copytree(src, dst)
            else:
                shutil.copy2(src, dst)

        # Ensure the xpfm has the expected name
        dst_xpfm = os.path.join(out_dir, platform_name + ".xpfm")
        xpfm_in_out = glob.glob(os.path.join(out_dir, "*.xpfm"))
        if xpfm_in_out and xpfm_in_out[0] != dst_xpfm:
            os.rename(xpfm_in_out[0], dst_xpfm)

        print(f"Platform files copied to: {out_dir}")
        print(f"Platform xpfm: {dst_xpfm}")

    print(f"Platform '{platform_name}' created successfully")

if __name__ == "__main__":
    main()
