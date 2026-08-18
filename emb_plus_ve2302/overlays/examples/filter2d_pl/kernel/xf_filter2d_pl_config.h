/*
 *
 * Copyright 2020 Xilinx, Inc.
 * Copyright (C) 2021-2023 Advanced Micro Devices, Inc.
 * SPDX-License-Identifier: MIT
 *
 */

#ifndef _XF_FILTER2D_PL_CONFIG_H_
#define _XF_FILTER2D_PL_CONFIG_H_

#include "common/xf_common.hpp"
#include "common/xf_utility.hpp"
#include "imgproc/xf_custom_convolution.hpp"

#define WIDTH 3840
#define HEIGHT 2160
#ifndef PPC
#define PPC XF_NPPC8
#endif

const uint32_t pCOLS = WIDTH / PPC;
const uint32_t pCOLSD = WIDTH * 2 / PPC;

/* chroma_mode values. The host mirrors these; keep the two in step. */
#define CHROMA_PASSTHROUGH 0
#define CHROMA_NEUTRAL 1
#define CHROMA_NEUTRAL_VALUE 128

extern "C" void filter2d_pl_accel(XF_TNAME(XF_16UC1, PPC) * frm_in,
                       XF_TNAME(XF_16UC1, PPC) * frm_out,
                       int16_t* kernel,
                       uint32_t rows,
                       uint32_t cols,
                       uint32_t fourcc_in,
                       uint32_t fourcc_out,
                       uint32_t chroma_mode);

#endif // end of  _XF_FILTER2D_PL_CONFIG_H_
