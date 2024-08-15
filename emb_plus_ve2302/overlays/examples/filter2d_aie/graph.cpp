/**
* Copyright (C) 2024 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/

#include "graph.h"
#include "config.h"
// Graph object
myGraph filter_graph;

int main(int argc, char** argv) {
    filter_graph.init();
    filter_graph.run(1);
    filter_graph.end();
    return 0;
}
