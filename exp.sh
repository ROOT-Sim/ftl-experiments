#!/bin/bash

set -e

CPUS=$(cat /sys/devices/system/cpu/online | cut -d'-' -f2)
CPUS=$((CPUS+1))
LPS=512

if (( $CPUS > 32 )); then 
CPUS=32
fi
LPS=$(($LPS*CPUS/32))

if [ "$#" != 1 ]; then
    echo "Passed $# parameter(s) instead of 1"
    echo "usage: ./exp <build|run_all|run_balanced|run_unbalanced|run_alternating|plot>"
    exit
fi

mkdir -p bins
mkdir -p sim_build
mkdir -p run_logs
mkdir -p configs

if [[ "$1" == "build" ]]; then
  if [[ ! -d rootsim_gputw ]]; then
  echo ###### cloning repository #########
   git clone https://github.com/ROOT-Sim/core.git --single-branch --branch gpu-test-conf rootsim_gputw
  fi
  echo ###### cmake #########
  if [[ -d sim_build ]]; then rm -fr sim_build; fi
  cmake -Bsim_build -Srootsim_gputw -UWITH_MPI -DCMAKE_BUILD_TYPE=RELEASE

  echo ###### generating configs #######
  echo "#define N_THREADS $((CPUS-1))" > configs/balanced.h
  echo "#define NUM_LPS ($LPS*1024)" >> configs/balanced.h
  cp configs/balanced.h configs/unbalanced.h
  cp configs/balanced.h configs/alternating.h

  echo "#define ENABLE_HOT 0"        >> configs/balanced.h
  echo "#define HOT_PHASE_PERIOD 1"  >> configs/balanced.h

  echo "#define ENABLE_HOT 1"        >> configs/unbalanced.h
  echo "#define HOT_PHASE_PERIOD 1"  >> configs/unbalanced.h

  echo "#define ENABLE_HOT 1"        >> configs/alternating.h
  echo "#define HOT_PHASE_PERIOD 2"  >> configs/alternating.h

  echo ###### building binaries #########
  cp configs/balanced.h rootsim_gputw/src/cuda/test_config.h && make -C sim_build && cp sim_build/test/test_phold bins/balanced
  cp configs/unbalanced.h rootsim_gputw/src/cuda/test_config.h && make -C sim_build && cp sim_build/test/test_phold bins/unbalanced
  cp configs/alternating.h rootsim_gputw/src/cuda/test_config.h && make -C sim_build && cp sim_build/test/test_phold bins/alternating
fi

XPUS="1 2 3"
WORKLOADS="alternating balanced unbalanced"

for j in $WORKLOADS; do
run="$j"
if [[ "$1" == "run_$run" || "$1" == "run_all" ]]; then
  echo -1 | sudo tee /proc/sys/kernel/perf_event_paranoid
  mkdir -p run_logs/$run
  for i in $XPUS; do
    echo python3 rootsim_gputw/measure_energy.py ./bins/$run $i > run_logs/$run/$i.sh
    python3 rootsim_gputw/measure_energy.py ./bins/$run $i | tee run_logs/$run/$i.txt
  done
fi
done


