import math
import sys

fi = open(sys.argv[1])
fo = open(sys.argv[2], "w")

min_par = float(sys.argv[3])
max_par = float(sys.argv[4])
a = float(sys.argv[5])
b = float(sys.argv[6])
c = float(sys.argv[7])

cnt=0
fo.write("static double load_trace[] = {\n")

trace = []

for line in fi.readlines():
  if cnt == 0: 
    cnt+=1
    continue
  line = line.strip().split(",")
  gpu_speed = float(line[2])  
  cpu_speed = float(line[1])
  gpu_speed_up = gpu_speed/cpu_speed
  gpu_speed_up = min(gpu_speed_up, 10)
  gpu_speed_up = max(gpu_speed_up, 0.2727272727)
  x1 = -b + math.sqrt(b*b -4*a*(c-gpu_speed_up))
  x1 /= 2*a
  x2 = -b - math.sqrt(b*b -4*a*(c-gpu_speed_up))
  x2 /= 2*a
  if x1 < min_par or x1 > max_par:
    x = x2
  else:
    x = x1
  #print(a,b,c,cpu_speed, gpu_speed, gpu_speed_up, c-gpu_speed_up, x1, x2, x)
  #print(gpu_speed_up, x)
  trace+=[str(x)]

#trace = trace[:32]
while len(trace) > 16:
  compress_trace = []
  for i in range(int(len(trace)/2)):
    compress_trace += [str( (float(trace[i])+float(trace[i+1]))/2 )]
  trace = compress_trace[:]
  break

#trace = trace[:32]


string = ",\n".join(trace)
fo.write(f'{string}\n')

fo.write("};\n")

fi.close()
fo.close()    
