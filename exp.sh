#!/bin/bash

set -e

CPUS=$(cat /sys/devices/system/cpu/online | cut -d'-' -f2)
CPUS=$((CPUS+1))
LPS=512

if (( $CPUS > 32 )); then 
CPUS=32
fi
#LPS=$(($LPS*CPUS/32))

if [ "$#" != 1 ]; then
    echo "Passed $# parameter(s) instead of 1"
    echo "usage: ./exp <build|run_all|run_balanced|run_unbalanced|run_alternating|run_ftl|run_cpu|run_gpu|plot_all|report>"
    exit
fi

mkdir -p bins
mkdir -p sim_build
mkdir -p run_logs
mkdir -p configs


XPUS="1 2 3"
WORKLOADS="alternating balanced unbalanced"

if [[ "$1" == "build" ]]; then
  if [[ ! -d rootsim_gputw ]]; then
  echo ###### cloning repository #########
   git clone https://github.com/ROOT-Sim/core.git --single-branch --branch gpu-test-conf rootsim_gputw
  fi
  echo ###### cmake #########
  if [[ -d sim_build ]]; then rm -fr sim_build; fi
  cmake -Bsim_build -Srootsim_gputw -DCMAKE_BUILD_TYPE=Release

  echo ###### generating configs #######
  echo "#define NUM_THREADS $((CPUS-1))" > configs/balanced.h
  echo "#define NUM_LPS ($LPS*1024)" >> configs/balanced.h
  cp configs/balanced.h configs/unbalanced.h
  cp configs/balanced.h configs/alternating.h
  cp configs/balanced.h configs/kick.h

  echo "#define ENABLE_HOT 1"        >> configs/balanced.h
  echo "#define PHASE_WINDOW_SIZE (1)" >> configs/balanced.h
  echo "#define HOT_PHASE_PERIOD (80*1000*1000)"  >> configs/balanced.h
  echo "#define END_SIM_GVT  (64*1000*1000)" >> configs/balanced.h

  echo "#define ENABLE_HOT 1"        >> configs/unbalanced.h
  echo "#define PHASE_WINDOW_SIZE (80*1000*1000)" >> configs/unbalanced.h
  echo "#define HOT_PHASE_PERIOD 2"  >> configs/unbalanced.h
  echo "#define END_SIM_GVT  (64*1000*1000)" >> configs/unbalanced.h

  echo "#define ENABLE_HOT 1"        >> configs/alternating.h
  echo "#define PHASE_WINDOW_SIZE (8*1000*1000)" >> configs/alternating.h
  echo "#define HOT_PHASE_PERIOD 2"  >> configs/alternating.h
  echo "#define END_SIM_GVT  (64*1000*1000)" >> configs/alternating.h


  echo "#define ENABLE_HOT 1"        >> configs/kick.h
  echo "#define PHASE_WINDOW_SIZE (8*1000*100)" >> configs/kick.h
  echo "#define HOT_PHASE_PERIOD 2"  >> configs/kick.h
  echo "#define END_SIM_GVT  (32*1000*100)" >> configs/kick.h


  echo ###### building binaries #########
  for j in $WORKLOADS; do
    cp configs/$j.h rootsim_gputw/src/cuda/phold/test_config.h && make -j8 -C sim_build && cp sim_build/test/test_phold bins/$j
  done
  cp configs/kick.h rootsim_gputw/src/cuda/phold/test_config.h && make -j8 -C sim_build && cp sim_build/test/test_phold bins/kick
fi

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


i=0
if [[ "$1" == "run_cpu" ]]; then
 i=1
elif [[ "$1" == "run_gpu" ]]; then
 i=2
elif [[ "$1" == "run_ftl" ]]; then
 i=3
fi

if [[ "$i" != "0" ]]; then
for j in $WORKLOADS; do
    run="$j"
    mkdir -p run_logs/$run
    echo python3 rootsim_gputw/measure_energy.py ./bins/$run $i > run_logs/$run/$i.sh
    python3 rootsim_gputw/measure_energy.py ./bins/$run $i | tee run_logs/$run/$i.txt
  done
fi

for j in $WORKLOADS; do
run="$j"
if [[ "$1" == "plot_$run" || "$1" == "plot_all" ]]; then
  max=0
  for i in $XPUS; do
    tail -n2 run_logs/$run/$i.txt
    cur=$(tail -n1 run_logs/$run/$i.txt | cut -d',' -f1 | cut -d'.' -f1)
    if [ "$cur" -gt "$max" ]; then
      max="$cur"
    fi
  done
  echo MAX:$max
  for i in $XPUS; do
    s=1
    if [[ "$run" == "balanced" ]]; then s=0; fi
    echo "cd plot_scripts && ./process_log.sh ../run_logs/$run/$i.txt 200 $s && cd .."
    cd plot_scripts && ./process_log.sh ../run_logs/$run/$i.txt $max $s && cd ..
    cd plot_scripts && python3 parse_log_4_energy.py ../run_logs/$run && gnuplot -e "outputFileName='../run_logs/$run'" energy.plt && cd ..
  done
fi
done


if [[ "$1" == "kick" ]]; then
    echo python3 rootsim_gputw/measure_energy.py ./bins/kick 3  | tee run_logs/kick.txt
    python3 rootsim_gputw/measure_energy.py ./bins/kick 3 | tee run_logs/kick.txt
fi


if [[ "$1" == "report" ]]; then
echo "\item CPU:" $(lscpu | grep "Model name:" | cut -d':' -f2)                 > run_logs/machine.tex
echo "\item GPU:" $(lspci | grep "VGA compatible controller:" | cut -d':' -f3) >> run_logs/machine.tex
echo "\item RAM:" $(lsmem | grep "Total online memory:" | cut -d':' -f2)       >> run_logs/machine.tex
pdflatex report.tex
fi