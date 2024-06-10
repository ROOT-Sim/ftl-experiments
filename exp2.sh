#!/bin/bash

set -e

CPUS=$(cat /sys/devices/system/cpu/online | cut -d'-' -f2)
CPUS=$((CPUS+1))
LPS=256

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
VOLATILITY="1 0.5 0.25"

if [[ "$1" == "build" ]]; then
  python3 -m venv .
  source bin/activate
  pip3 install pandas
  deactivate
  if [[ ! -d rootsim_gputw ]]; then
  echo ###### cloning repository #########
   git clone https://github.com/ROOT-Sim/core.git --single-branch --branch gpu-ftl-heu rootsim_gputw
  fi
  echo ###### cmake #########
  if [[ -d sim_build ]]; then rm -fr sim_build; fi
  cmake -Bsim_build -Srootsim_gputw -DCMAKE_BUILD_TYPE=Release

  echo ###### generating configs #######
  echo "#define NUM_THREADS $((CPUS-1))" > configs/trace.h
  echo "#define NUM_LPS ($LPS*1024)" >> configs/trace.h

  echo "#define ENABLE_HOT 1"        >> configs/trace.h
  echo "#define PHASE_WINDOW_SIZE (8*1000*1000)" >> configs/trace.h
  echo "#define HOT_PHASE_PERIOD 2"  >> configs/trace.h
  echo "#define END_SIM_GVT  (64*1000*1000)" >> configs/trace.h


  echo ###### building binaries #########
  cp configs/trace.h rootsim_gputw/src/cuda/phold/test_config.h
  
  for j in $VOLATILITY; do
    for i in {1..40}; do
		cp ftl_speed_trajectories/phold_trace/volatility_${j}_seed_${i}.txt rootsim_gputw/src/cuda/phold/settings_cpu.h && make -j8 -C sim_build && cp sim_build/test/test_phold bins/trace_${j}_${i}
	done
  done
fi

for j in $VOLATILITY; do
  for i in {1..10}; do
	for h in {0..2}; do
		if [[ "$1" == "run_all" ]]; then
		  echo -1 | sudo tee /proc/sys/kernel/perf_event_paranoid
		  mkdir -p trace_logs/
          echo python3 rootsim_gputw/measure_energy.py ./bins/trace_${j}_${i} 3 $h > trace_logs/trace_${j}_${i}_${h}.sh
          python3 rootsim_gputw/measure_energy.py ./bins/trace_${j}_${i} 3 $h | tee trace_logs/trace_${j}_${i}_${h}.txt
		fi
	  done
	done
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
  source bin/activate
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
  deactivate
fi
done


if [[ "$1" == "kick" ]]; then
    echo python3 rootsim_gputw/measure_energy.py ./bins/kick 3  | tee run_logs/kick.txt
    python3 rootsim_gputw/measure_energy.py ./bins/kick 3 | tee run_logs/kick.txt
fi


if [[ "$1" == "report" ]]; then
echo "\item CPU:" $(lscpu | grep "Model name:" | cut -d':' -f2)                 > run_logs/machine.tex
echo "\item GPU:" $(lspci | grep "NVIDIA" -i | cut -d':' -f3) >> run_logs/machine.tex
echo "\item RAM:" $(lsmem | grep "Total online memory:" | cut -d':' -f2)       >> run_logs/machine.tex
pdflatex report.tex
fi
