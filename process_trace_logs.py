f=open('prova.txt')
print("volatility,seed,heuristic,wct,cpu,gpu")
n = ""

traces=11

dataset = {}
for i in [0.25, 0.5, 1]:
  dataset[i] = {}
  for k in range(traces)[1:]:
    dataset[i][k] = {}
    for j in [0,1,2]:
      dataset[i][k][j] = {"x":[],"y":[]}
    
for line in f.readlines():
  line = line.strip()
  if line == "": continue
  if "==" in line:
    n = line
    continue
  else:
    line = n+','+line
    line = line.replace(">", "").replace("==",'').replace('<', '').replace(' ', '').replace('.txt', '')
    line = line.replace('trace_', '').replace('logs/', '').replace('_', ',')
  
  line = line.split(',')
  line[0] = float(line[0])
  line[2] = int(line[2])
  line[1] = int(line[1])
  dataset[line[0]][line[1]][line[2]]["x"] = float(line[3])
  dataset[line[0]][line[1]][line[2]]["y"] = float(line[4])+float(line[5])
  print(line)


f.close()


for i in dataset:
  print(f"{i}")
  for j in dataset[i]:
    print(f"\t{j}")
    for h in reversed(dataset[i][j]):
      #dataset[i][j][h]["x"] /= dataset[i][j][0]["x"]
      #dataset[i][j][h]["y"] /= dataset[i][j][0]["y"]
      print(f"\t\t{h}:{dataset[i][j][h]['x']}-{dataset[i][j][h]['y']}")


points=[".", "o","v","^","<",">",
             "s","+","x","*","d"] 


import matplotlib.pyplot as plt
import numpy as np

for v in [0.25, 0.5, 1]:
    for b in range(traces)[1:]:
        for a in range(traces)[b+1:]:
            xb = [dataset[v][b][0]["x"], dataset[v][b][1]["x"], dataset[v][b][2]["x"]]
            xa = [dataset[v][a][0]["x"], dataset[v][a][1]["x"], dataset[v][a][2]["x"]]
            yb = [dataset[v][b][0]["y"], dataset[v][b][1]["y"], dataset[v][b][2]["y"]]
            ya = [dataset[v][a][0]["y"], dataset[v][a][1]["y"], dataset[v][a][2]["y"]]
            if min(ya) < min(yb):
                dataset[v][a][0]["x"] = xb[0]
                dataset[v][a][1]["x"] = xb[1]
                dataset[v][a][2]["x"] = xb[2]
                dataset[v][b][0]["x"] = xa[0]
                dataset[v][b][1]["x"] = xa[1]
                dataset[v][b][2]["x"] = xa[2]
                dataset[v][a][0]["y"] = yb[0]
                dataset[v][a][1]["y"] = yb[1]
                dataset[v][a][2]["y"] = yb[2]
                dataset[v][b][0]["y"] = ya[0]
                dataset[v][b][1]["y"] = ya[1]
                dataset[v][b][2]["y"] = ya[2]

for v in [0.25, 0.5, 1]:
    fig, ax = plt.subplots(figsize=(8, 4))
    for b in range(traces)[1:]:
        h=0
        for color in ['tab:blue', 'tab:orange', 'tab:green']:
            x = b #dataset[0.25][b][h]["x"]
            y = dataset[v][b][h]["x"]
            if b == 1:
                ax.scatter(x, y, c=color, label=h, edgecolors='none')
            else:
                ax.scatter(x, y, c=color, edgecolors='none')
            h+=1

    ax.legend()
    ax.set_ylabel('time (s)')
    ax.set_xlabel('trace (sorted by lowest y)')
    ax.grid(True)
    fig.suptitle(v)

    plt.savefig(f"v_{v}-time.pdf", dpi=300)


for v in [0.25, 0.5, 1]:
    for b in range(traces)[1:]:
        for a in range(traces)[b+1:]:
            xb = [dataset[v][b][0]["x"], dataset[v][b][1]["x"], dataset[v][b][2]["x"]]
            xa = [dataset[v][a][0]["x"], dataset[v][a][1]["x"], dataset[v][a][2]["x"]]
            yb = [dataset[v][b][0]["y"], dataset[v][b][1]["y"], dataset[v][b][2]["y"]]
            ya = [dataset[v][a][0]["y"], dataset[v][a][1]["y"], dataset[v][a][2]["y"]]
            if min(ya) < min(yb):
                dataset[v][a][0]["x"] = xb[0]
                dataset[v][a][1]["x"] = xb[1]
                dataset[v][a][2]["x"] = xb[2]
                dataset[v][b][0]["x"] = xa[0]
                dataset[v][b][1]["x"] = xa[1]
                dataset[v][b][2]["x"] = xa[2]
                dataset[v][a][0]["y"] = yb[0]
                dataset[v][a][1]["y"] = yb[1]
                dataset[v][a][2]["y"] = yb[2]
                dataset[v][b][0]["y"] = ya[0]
                dataset[v][b][1]["y"] = ya[1]
                dataset[v][b][2]["y"] = ya[2]

for v in [0.25, 0.5, 1]:
    fig, ax = plt.subplots(figsize=(8, 4))
    for b in range(traces)[1:]:
        h=0
        for color in ['tab:blue', 'tab:orange', 'tab:green']:
            x = b #dataset[0.25][b][h]["x"]
            y = dataset[v][b][h]["y"]
            if b == 1:
                ax.scatter(x, y, c=color, label=h, edgecolors='none')
            else:
                ax.scatter(x, y, c=color, edgecolors='none')
            h+=1

    ax.legend()
    ax.grid(True)
    fig.suptitle(v)
    ax.set_ylabel('energy (J)')
    ax.set_xlabel('trace (sorted by lowest y)')

    plt.savefig(f"v_{v}-energy.pdf", dpi=300)



for v in [0.25, 0.5, 1]:
    for b in range(traces)[1:]:
        for a in range(traces)[b+1:]:
            xb = [dataset[v][b][0]["x"], dataset[v][b][1]["x"], dataset[v][b][2]["x"]]
            xa = [dataset[v][a][0]["x"], dataset[v][a][1]["x"], dataset[v][a][2]["x"]]
            yb = [dataset[v][b][0]["y"], dataset[v][b][1]["y"], dataset[v][b][2]["y"]]
            ya = [dataset[v][a][0]["y"], dataset[v][a][1]["y"], dataset[v][a][2]["y"]]
            xya = [ xa[i]*ya[i]  for i in range(len(xa))]
            xyb = [ xb[i]*yb[i]  for i in range(len(xb))]
            if min(xya) < min(xyb):
                dataset[v][a][0]["x"] = xb[0]
                dataset[v][a][1]["x"] = xb[1]
                dataset[v][a][2]["x"] = xb[2]
                dataset[v][b][0]["x"] = xa[0]
                dataset[v][b][1]["x"] = xa[1]
                dataset[v][b][2]["x"] = xa[2]
                dataset[v][a][0]["y"] = yb[0]
                dataset[v][a][1]["y"] = yb[1]
                dataset[v][a][2]["y"] = yb[2]
                dataset[v][b][0]["y"] = ya[0]
                dataset[v][b][1]["y"] = ya[1]
                dataset[v][b][2]["y"] = ya[2]

for v in [0.25, 0.5, 1]:
    fig, ax = plt.subplots(figsize=(8, 4))
    for b in range(traces)[1:]:
        h=0
        for color in ['tab:blue', 'tab:orange', 'tab:green']:
            x = b #dataset[0.25][b][h]["x"]
            y = dataset[v][b][h]["x"]*dataset[v][b][h]["y"]
            if b == 1:
                ax.scatter(x, y, c=color, label=h, edgecolors='none')
            else:
                ax.scatter(x, y, c=color, edgecolors='none')
            h+=1

    ax.legend()
    ax.grid(True)
    fig.suptitle(v)
    ax.set_ylabel('energy*time (Js)')
    ax.set_xlabel('trace (sorted by lowest y)')

    plt.savefig(f"v_{v}-energydelay.pdf", dpi=300)


for v in [0.25, 0.5, 1]:
    for b in range(traces)[1:]:
        for a in range(traces)[b+1:]:
            xb = [dataset[v][b][0]["x"], dataset[v][b][1]["x"], dataset[v][b][2]["x"]]
            xa = [dataset[v][a][0]["x"], dataset[v][a][1]["x"], dataset[v][a][2]["x"]]
            yb = [dataset[v][b][0]["y"], dataset[v][b][1]["y"], dataset[v][b][2]["y"]]
            ya = [dataset[v][a][0]["y"], dataset[v][a][1]["y"], dataset[v][a][2]["y"]]
            xya = [ xa[i]*xa[i]*ya[i]  for i in range(len(xa))]
            xyb = [ xb[i]*xb[i]*yb[i]  for i in range(len(xb))]
            if min(xya) < min(xyb):
                dataset[v][a][0]["x"] = xb[0]
                dataset[v][a][1]["x"] = xb[1]
                dataset[v][a][2]["x"] = xb[2]
                dataset[v][b][0]["x"] = xa[0]
                dataset[v][b][1]["x"] = xa[1]
                dataset[v][b][2]["x"] = xa[2]
                dataset[v][a][0]["y"] = yb[0]
                dataset[v][a][1]["y"] = yb[1]
                dataset[v][a][2]["y"] = yb[2]
                dataset[v][b][0]["y"] = ya[0]
                dataset[v][b][1]["y"] = ya[1]
                dataset[v][b][2]["y"] = ya[2]

for v in [0.25, 0.5, 1]:
    fig, ax = plt.subplots(figsize=(8, 4))
    for b in range(traces)[1:]:
        h=0
        for color in ['tab:blue', 'tab:orange', 'tab:green']:
            x = b #dataset[0.25][b][h]["x"]
            y = dataset[v][b][h]["x"]*dataset[v][b][h]["x"]*dataset[v][b][h]["y"]
            if b == 1:
                ax.scatter(x, y, c=color, label=h, edgecolors='none')
            else:
                ax.scatter(x, y, c=color, edgecolors='none')
            h+=1

    ax.legend()
    ax.grid(True)
    fig.suptitle(v)
    ax.set_ylabel('power*time (Js^2)')
    ax.set_xlabel('trace (sorted by lowest y)')

    plt.savefig(f"v_{v}-powerdelay.pdf", dpi=300)


for v in [0.25, 0.5, 1]:
    fig, ax = plt.subplots(figsize=(8, 4))
    for b in range(traces)[1:]:
        h=0
        for color in ['tab:blue', 'tab:orange', 'tab:green']:
            x = dataset[v][b][h]["x"]
            y = dataset[v][b][h]["y"]
            if b == 1:
                ax.scatter(x, y, c=color, label=h, edgecolors='none')
            else:
                ax.scatter(x, y, c=color, edgecolors='none')
            h+=1

    ax.legend()
    ax.grid(True)
    fig.suptitle(v)
    ax.set_ylabel('energy (J)')
    ax.set_xlabel('time (s)')

    plt.savefig(f"v_{v}-paretolike.pdf", dpi=300)
