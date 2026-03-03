/**
* Copyright (C) 2023 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/
#ifndef _XF_PLCTRL_GRAPH_CTRL_HPP_
#define _XF_PLCTRL_GRAPH_CTRL_HPP_

#include "ctrl_pkt_utils.hpp"
#include "drivers/aiengine/aie_codegen_inc/xaiegbl_params.h"

namespace xf {
namespace plctrl {

static void updateAIERTP(hls::stream<ap_axiu<32, 0, 0, 0>> &ctrlOut,
                         ap_uint<32> ctrlPktID, ap_int<32> rtpVal,
                         ap_uint<32> rtpAddr) {
#pragma HLS inline
  controlPacketWrite(ctrlOut, ctrlPktID, rtpAddr, 1, rtpVal);
}
static void setAIEIterations(hls::stream<ap_axiu<32, 0, 0, 0>> &ctrlOut,
                             ap_uint<32> ctrlPktID, ap_uint<32> num_iter,
                             ap_uint<32> iter_mem_addr) {

#pragma HLS inline
  // set num_iter
  controlPacketWrite(ctrlOut, ctrlPktID, iter_mem_addr, 1, num_iter);
}

static void enableAIECores(hls::stream<ap_axiu<32, 0, 0, 0>> &ctrlOut,
                           ap_uint<32> ctrlPktID) {
#pragma HLS inline
  // enable AIE cores
  controlPacketWrite(ctrlOut, ctrlPktID, XAIEGBL_CORE_CORECTRL, 1, 0x1);
}

static void disableAIECores(hls::stream<ap_axiu<32, 0, 0, 0>> &ctrlOut,
                            ap_uint<32> ctrlPktID) {
#pragma HLS inline
  // set disable-event for AIE cores
  controlPacketWrite(ctrlOut, ctrlPktID, XAIEGBL_CORE_CORECTRL, 1, 0x0);
}

} // end of namespace plctrl
} // end of xf
#endif
