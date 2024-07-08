/*
 *
 * Copyright (C) 2021-2024 Advanced Micro Devices, Inc.
 * SPDX-License-Identifier: MIT
 *
 */

def logCommitIDs() {
    sh label: 'log commit IDs',
    script: '''
        idfile=${ws}/commitIDs
        pushd ${ws}/src
        echo "src-branch : ${BRANCH_NAME}" >> ${idfile}
        echo -n "src : " >> ${idfile}
        git rev-parse HEAD >> ${idfile}
        subm=($(cat .gitmodules | grep path | cut -d "=" -f2))
        for sm in "${subm[@]}"; do
            pushd ${sm}
            echo -n "${sm} : " >> ${idfile}
            git rev-parse HEAD >> ${idfile}
            popd
        done
        popd
        pushd ${ws}/paeg-helper
        echo -n "paeg-helper : " >> ${idfile}
        git rev-parse HEAD >> ${idfile}
        popd
        cat ${idfile}
    '''
}

def createWorkDir() {
    sh label: 'create work dir',
    script: '''
        if [ ! -d ${work_dir} ]; then
            mkdir -p ${work_dir}
            cp -rf ${ws}/src/* ${work_dir}
        fi
    '''
}

def buildPlatform() {
    sh label: 'platform build',
    script: '''
        pushd ${work_dir}/${board}
        source ${setup} -r ${tool_release} && set -e
        ${lsf} make platform PFM=${pfm_base} SILICON=${silicon} JOBS=32
        popd
    '''
}

def deployPlatform() {
    sh label: 'platform deploy',
    script: '''
        if [ "${BRANCH_NAME}" == "${deploy_branch}" ]; then
            DEPLOYDIR=${DEPLOYDIR}/daily_latest
        else
            DEPLOYDIR=${DEPLOYDIR}/pr_latest
        fi
        pushd ${work_dir}/${board}
        DSTDIR=${DEPLOYDIR}/platforms
        mkdir -p ${DSTDIR}/${pfm}
        cp ${ws}/commitIDs platforms/${pfm}
        rsync -avh --delete platforms/${pfm}/ ${DSTDIR}/${pfm}/
        popd
    '''
}

def deployPlatformFirmware() {
    sh label: 'platform firmware deploy',
    script: '''
        if [ "${BRANCH_NAME}" == "${deploy_branch}" ]; then
            DEPLOYDIR=${DEPLOYDIR}/daily_latest
        else
            DEPLOYDIR=${DEPLOYDIR}/pr_latest
        fi
        pushd ${work_dir}/${board}
        mkdir -p tmp
        unzip platforms/${pfm}/hw/${pfm_name}.xsa -d tmp
        pushd tmp
        source ${setup} -r ${tool_release} && set -e
        echo "all: { ${pfm_name}.bit }" > bootgen.bif
        bootgen -arch zynqmp -process_bitstream bin -image bootgen.bif
        popd
        fw=$(echo ${pfm_name} | tr _ -)
        DSTDIR=${DEPLOYDIR}/firmware/${fw}
        mkdir -p ${DSTDIR}
        TMPDIR=$(mktemp -d -p .)
        chmod go+rx ${TMPDIR}
        cp -f tmp/${pfm_name}.bit ${TMPDIR}/${fw}.bit
        cp -f tmp/${pfm_name}.bit.bin ${TMPDIR}/${fw}.bin
        cp ${ws}/commitIDs ${TMPDIR}
        rsync -avh --delete ${TMPDIR}/ ${DSTDIR}/
        popd
    '''
}

def buildOverlay() {
    sh label: 'overlay build',
    script: '''
        pushd ${work_dir}/${board}
        if [ -d platforms/${pfm} ]; then
            echo "Using platform from local build"
        elif [ -d ${DEPLOYDIR}/daily_latest/platforms/${pfm} ]; then
            echo "Using platform from build artifacts"
            ln -s ${DEPLOYDIR}/daily_latest/platforms/${pfm} platforms/
        else
            echo "No valid platform found: ${pfm}"
            exit 1
        fi
        source ${setup} -r ${tool_release} && set -e
        bsub -R "select[osdistro==ubuntu]" -R "rusage[mem=${PAEG_LSF_MEM}]" -Is -q sil_ssw \
            make overlay OVERLAY=${overlay} SILICON=${silicon}
        popd
    '''
}

def deployOverlay() {
    sh label: 'overlay deploy',
    script: '''
        if [ "${BRANCH_NAME}" == "${deploy_branch}" ]; then
            DEPLOYDIR=${DEPLOYDIR}/daily_latest
        else
            DEPLOYDIR=${DEPLOYDIR}/pr_latest
        fi
        if [ "${silicon}" != "prod" ]; then
            board=${board}_${silicon}
        fi
        DSTDIR=${DEPLOYDIR}/firmware/${board}-${overlay}
        mkdir -p ${DSTDIR}
        TMPDIR=$(mktemp -d -p .)
        chmod go+rx ${TMPDIR}
        cp -f ${example_dir}/*.xclbin ${TMPDIR}
        cp -f ${example_dir}/*.deb ${TMPDIR}
        cp ${ws}/commitIDs ${TMPDIR}
        rsync -avh --delete ${TMPDIR}/ ${DSTDIR}/
    '''
}

pipeline {
    agent {
        label 'Build_Master'
    }
    environment {
        deploy_branch="main"
        tool_release="2024.2"
        tool_build="daily_latest"
        auto_branch="2022.1"
        pfm_ver="202420_1"
        ws="${WORKSPACE}"
        setup="${ws}/paeg-helper/env-setup.sh"
        lsf="${ws}/paeg-helper/scripts/lsf"
        PAEG_LSF_MEM=65536
        PAEG_LSF_QUEUE="long"
        DEPLOYDIR="/wrk/paeg_builds/build-artifacts/emb-plus-vitis-platforms/${tool_release}"
    }
    options {
        // don't let the implicit checkout happen
        skipDefaultCheckout true
    }
    triggers {
        cron(env.BRANCH_NAME == 'main' ? 'H 21 * * *' : '')
    }
    stages {
        stage('Clone Repos') {
            steps {
                // checkout main source repo
                checkout([
                    $class: 'GitSCM',
                    branches: scm.branches,
                    doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                    extensions: scm.extensions +
                    [
                        [$class: 'RelativeTargetDirectory', relativeTargetDir: 'src'],
                        [$class: 'ChangelogToBranch', options: [compareRemote: 'origin', compareTarget: env.deploy_branch]]
                    ],
                    userRemoteConfigs: scm.userRemoteConfigs
                ])
                // checkout paeg-automation helper repo
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: auto_branch]],
                    doGenerateSubmoduleConfigurations: false,
                    extensions:
                    [
                        [$class: 'CleanCheckout'],
                        [$class: 'RelativeTargetDirectory', relativeTargetDir: 'paeg-helper']
                    ],
                    submoduleCfg: [],
                    userRemoteConfigs: [[
                        credentialsId: '01d4faf7-fb5a-4bd9-b300-57ac0bfc7991',
                        url: 'https://gitenterprise.xilinx.com/PAEG/paeg-automation.git'
                    ]]
                ])
                logCommitIDs()
            }
        }
        stage('Create Build Directories') {
            parallel {
                stage('ve2302_pcie_qdma')  {
                    environment {
                        pfm_name="ve2302_pcie_qdma"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    steps {
                        createWorkDir()
                    }
                }
                stage('ve2302_es1_pcie_qdma platform build')  {
                    environment {
                        pfm_name="ve2302_es1_pcie_qdma"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    steps {
                        createWorkDir()
                    }
                }
            }
        }
        stage('Build Platforms') {
            parallel {
                stage('ve2302_pcie_qdma platform build')  {
                    environment {
                        pfm_base="ve2302_pcie_qdma"
                        pfm_name="ve2302_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="prod"
                        pfm_dir="${work_dir}/${board}/platforms/${pfm}"
                        xpfm="${pfm_dir}/${pfm_name}.xpfm"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/platforms/vivado/ve2302_pcie_qdma/**"
                            triggeredBy 'TimerTrigger'
                            triggeredBy 'UserIdCause'
                        }
                    }
                    steps {
                        buildPlatform()
                    }
                    post {
                        success {
                            script {
                                env.VE2302_PFM_SUCCESS = '1'
                            }
                            deployPlatform()
                        }
                    }
                }
                stage('ve2302_es1_pcie_qdma platform build')  {
                    environment {
                        pfm_base="ve2302_pcie_qdma"
                        pfm_name="ve2302_es1_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="es1"
                        pfm_dir="${work_dir}/${board}/platforms/${pfm}"
                        xpfm="${pfm_dir}/${pfm_name}.xpfm"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/platforms/vivado/ve2302_pcie_qdma/**"
                            triggeredBy 'TimerTrigger'
                            triggeredBy 'UserIdCause'
                        }
                    }
                    steps {
                        buildPlatform()
                    }
                    post {
                        success {
                            script {
                                env.VE2302_ES1_PFM_SUCCESS = '1'
                            }
                            deployPlatform()
                        }
                    }
                }
            }
        }
        stage('Build Overlays') {
            parallel {
                stage('filter2d_pl overlay build') {
                    environment {
                        pfm_name="ve2302_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="prod"
                        overlay="filter2d_pl"
                        example_dir="${work_dir}/${board}/overlays/examples/${overlay}"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/overlays/examples/filter2d_pl/**"
                            triggeredBy 'TimerTrigger'
                            environment name: 'VE2302_PFM_SUCCESS', value: '1'
                        }
                    }
                    steps {
                        buildOverlay()
                    }
                    post {
                        success {
                            deployOverlay()
                        }
                    }
                }
                stage('filter2d_pl ES1 overlay build') {
                    environment {
                        pfm_name="ve2302_es1_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="es1"
                        overlay="filter2d_pl"
                        example_dir="${work_dir}/${board}/overlays/examples/${overlay}"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/overlays/examples/filter2d_pl/**"
                            triggeredBy 'TimerTrigger'
                            environment name: 'VE2302_ES1_PFM_SUCCESS', value: '1'
                        }
                    }
                    steps {
                        buildOverlay()
                    }
                    post {
                        success {
                            deployOverlay()
                        }
                    }
                }
                stage('verify_test overlay build') {
                    environment {
                        pfm_name="ve2302_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="prod"
                        overlay="verify_test"
                        example_dir="${work_dir}/${board}/overlays/examples/${overlay}"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/overlays/examples/verify_test/**"
                            triggeredBy 'TimerTrigger'
                            environment name: 'VE2302_PFM_SUCCESS', value: '1'
                        }
                    }
                    steps {
                        buildOverlay()
                    }
                    post {
                        success {
                            deployOverlay()
                        }
                    }
                }
                stage('verify_test ES1 overlay build') {
                    environment {
                        pfm_name="ve2302_es1_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="es1"
                        overlay="verify_test"
                        example_dir="${work_dir}/${board}/overlays/examples/${overlay}"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/overlays/examples/verify_test/**"
                            triggeredBy 'TimerTrigger'
                            environment name: 'VE2302_ES1_PFM_SUCCESS', value: '1'
                        }
                    }
                    steps {
                        buildOverlay()
                    }
                    post {
                        success {
                            deployOverlay()
                        }
                    }
                }
                stage('bandwidth_test overlay build') {
                    environment {
                        pfm_name="ve2302_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="prod"
                        overlay="bandwidth_test"
                        example_dir="${work_dir}/${board}/overlays/examples/${overlay}"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/overlays/examples/bandwidth_test/**"
                            triggeredBy 'TimerTrigger'
                            environment name: 'VE2302_PFM_SUCCESS', value: '1'
                        }
                    }
                    steps {
                        buildOverlay()
                    }
                    post {
                        success {
                            deployOverlay()
                        }
                    }
                }
                stage('bandwidth_test ES1 overlay build') {
                    environment {
                        pfm_name="ve2302_es1_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="es1"
                        overlay="bandwidth_test"
                        example_dir="${work_dir}/${board}/overlays/examples/${overlay}"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/overlays/examples/bandwidth_test/**"
                            triggeredBy 'TimerTrigger'
                            environment name: 'VE2302_ES1_PFM_SUCCESS', value: '1'
                        }
                    }
                    steps {
                        buildOverlay()
                    }
                    post {
                        success {
                            deployOverlay()
                        }
                    }
                }
                stage('validate_aie2_pl overlay build') {
                    environment {
                        pfm_name="ve2302_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="prod"
                        overlay="validate_aie2_pl"
                        example_dir="${work_dir}/${board}/overlays/examples/${overlay}"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/overlays/examples/validate_aie2_pl/**"
                            triggeredBy 'TimerTrigger'
                            environment name: 'VE2302_PFM_SUCCESS', value: '1'
                        }
                    }
                    steps {
                        buildOverlay()
                    }
                    post {
                        success {
                            deployOverlay()
                        }
                    }
                }
                stage('validate_aie2_pl ES1 overlay build') {
                    environment {
                        pfm_name="ve2302_es1_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="es1"
                        overlay="validate_aie2_pl"
                        example_dir="${work_dir}/${board}/overlays/examples/${overlay}"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/overlays/examples/validate_aie2_pl/**"
                            triggeredBy 'TimerTrigger'
                            environment name: 'VE2302_ES1_PFM_SUCCESS', value: '1'
                        }
                    }
                    steps {
                        buildOverlay()
                    }
                    post {
                        success {
                            deployOverlay()
                        }
                    }
                }
                stage('filter2d_aie overlay build') {
                    environment {
                        pfm_name="ve2302_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="prod"
                        overlay="filter2d_aie"
                        example_dir="${work_dir}/${board}/overlays/examples/${overlay}"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/overlays/examples/filter2d_aie/**"
                            triggeredBy 'TimerTrigger'
                            environment name: 'VE2302_PFM_SUCCESS', value: '1'
                        }
                    }
                    steps {
                        buildOverlay()
                    }
                    post {
                        success {
                            deployOverlay()
                        }
                    }
                }
                stage('filter2d_aie ES1 overlay build') {
                    environment {
                        pfm_name="ve2302_es1_pcie_qdma"
                        pfm="xilinx_${pfm_name}_${pfm_ver}"
                        work_dir="${ws}/build/${pfm_name}"
                        board="emb_plus_ve2302"
                        silicon="es1"
                        overlay="filter2d_aie"
                        example_dir="${work_dir}/${board}/overlays/examples/${overlay}"
                    }
                    when {
                        anyOf {
                            changeset "**/emb_plus_ve2302/overlays/examples/filter2d_aie/**"
                            triggeredBy 'TimerTrigger'
                            environment name: 'VE2302_ES1_PFM_SUCCESS', value: '1'
                        }
                    }
                    steps {
                        buildOverlay()
                    }
                    post {
                        success {
                            deployOverlay()
                        }
                    }
                }
            }
        }
    }
    post {
        cleanup {
            cleanWs()
        }
    }
}
