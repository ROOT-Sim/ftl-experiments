# Reproducibility PADS 2024

This documents describes how to reproduce the results discussed in the paper:

"Follow the Leader: Alternating CPU/GPU Computations in PDES"

Submitted to ACM SIGSIM PADS 2024

## Authors & Contacts

* Romolo Marotta <romolo.marotta@gmail.com>
* Alessandro Pellegrini <a.pellegrini@ing.uniroma2.it>
* Philipp Andelfinger <philipp.andelfinger@uni-rostock.de>

## Requirements

* x86_64 CPU and CUDA capable GPU
* Unix system with gcc toolchain
* The compilation should be performed on the target machine due to compile-time code generation phases
* Running with root priviledges for gathering stats from performance counters

The hardware/software configuration used by the authors is:

* CPU: AMD Ryzen 9 7950x
* RAM: 64GB
* GPU: NVIDIA RTX 3090 Ti
* OS: Debian GNU/Linux 11

## Dependencies

* For running tests: ```bash, gcc, cmake, make, cuda, python3, perf```
* For processing data and generating figures: ```bash, Python3, pip3, pandas, gnuplot, fonts-linuxlibertine```
* For generating RCR report: ```pdflatex, lscpu, lsmem, lspci```


## Kick the tires instructions

1. Clone the repository: ```git clone https://github.com/ROOT-Sim/ftl-experiments.git FTL```
2. Build: ```./exp.sh build```
3. Run a small simulation ```./exp.sh kick```

## Structure of the artifact

```
FTL/
 |-- bins/           /* experiments executable */
 |-- configs/        /* configuration files for experiment parameters          */
 |-- rootsim_gputw/  /* source code of the simulator                           */
 |-- run_logs/       /* logs generated during runs                             */
 |-- sim_build/      /* build of the simulator                                 */
 |-- exp.sh          /* script for bulding and launching experiments  */
 |-- LICENSE            /* license          */
 |-- README.md          /* This file */

```
## License

The software is released with the GPL 3 license.

## Article claims

The article has three major claims:

* C1: the balanced configuration favours GPU PDES implementation
* C2: the unbalanced configuration favours CPU PDES implementation
* C3: the follow-the-leader approach can reduce the execution time of simulations with time-varying computational
intensity 

## Reproducing the results

The paper has 12 Figures that can be reproduced.
These can be generated by running 3 experiments.
The mapping between claims, experiments, figures and tables are resumed in the following table.

| Claim | Figures            | Experiment   |
|-------|--------------------|--------------|
| C1    | 2a, 2d, 2g, 3a     | balanced     |
| C2    | 2b, 2e, 2h, 3b     | unbalanced   |
| C3    | 2c, 2f, 2i, 3c     | alternating  |

To setup the environment:
1. ```cd FTL```
2. ```./exp.sh build```

To run an experiment <exp> and process its results, type the following:

3. ```nohup ./exp.sh run_<exp> &```
4. ```./exp.sh plot_<exp>```

To run all experiments and process their results at once, type the following:

3. ```nohup ./exp.sh run_all &```
4. ```./process_exp.sh all```

The expected runtime of each experiment is detailed in the following table:

| Experiment   | Runtime |
|--------------|---------|
| balanced     | 10m     |
| unbalanced   | 10m     |
| alternating  | 10m     |
| **Total**    | **30m** |


Once all experiments have been run, you can find each figure at:

| Figure       | Path |
|--------------|---------|
| 2a           | run_logs/balanced/1.processed.pdf     |
| 2b           | run_logs/unbalanced/1.processed.pdf     |
| 2c           | run_logs/alternating/1.processed.pdf     |
| 2d           | run_logs/balanced/2.processed.pdf     |
| 2e           | run_logs/unbalanced/2.processed.pdf     |
| 2f           | run_logs/alternating/2.processed.pdf     |
| 2g           | run_logs/balanced/3.processed.pdf     |
| 2h           | run_logs/unbalanced/3.processed.pdf     |
| 2i           | run_logs/alternating/3.processed.pdf     |
| 3a           | run_logs/balanced.energy.pdf     |
| 3b           | run_logs/unbalanced.energy.pdf     |
| 3c           | run_logs/alternating.energy.pdf     |

To generate a report with both original and reproduced figures:

5. ```pdflatex report.tex```



## Notes
All scripts have been tested by running them from the following path:

  ```FTL/```



## Common issues

* Installing CUDA 12
  * follow the instruction on https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html
  * add ```/usr/local/cuda/bin``` to the ```PATH``` variable







