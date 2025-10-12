/**
* Copyright (C) 2025 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/

#include <ap_int.h>
#include <ap_axi_sdata.h>
#include <hls_stream.h>

extern "C" {

void mm2s(
    ap_int<16>* mem,
    hls::stream<ap_axis<16, 0, 0, 0>>& str,
    int size, int num_tiles
) {
for(int n=0; n < num_tiles; n++){
    for (int i = 0; i < size; i++)
    {
        ap_axis<16, 0, 0, 0> x;
        x.data = mem[i];
        x.keep = -1;
        str.write(x);
    }
}
}

}
