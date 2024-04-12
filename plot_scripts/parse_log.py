import pandas as pd
import re
import sys

log_path = sys.argv[1]
res_file = log_path.replace('.txt','.processed.txt')
data = []
background_phase = sys.argv[2]  # Assume 0 for COLD, switch to 1 for HOT

print(log_path, res_file)

in_challenge = False
y_value = 0
x_value = 0
line_style = 0

last_before_challenge = [0,0,0,0]
data.append(last_before_challenge)

with open(log_path, 'r') as file:
    for line in file:
        if "Starting challenge" in line:
            in_challenge = True
        elif "the challenge is completed" in line:
            in_challenge = False
            data.append(last_before_challenge)
        elif "ENTER COLD PHASE" in line:
            background_phase = 0
            data.append([x_value, y_value, line_style, background_phase])
        elif "ENTER HOT PHASE" in line:
            background_phase = 1
            data.append([x_value, y_value, line_style, background_phase])
        elif "GPU GVT" in line or "CPU GVT" in line:
            if in_challenge:
                continue
            # Extract GVT data
            #print(line)
            line = line.replace(',', '.').replace('. ', ', ')
            #line = line.split("GVT")[0]+"GVT "+' '.join(line.split("GVT")[1].split(' ')[-2:])
            line = " ".join(line.split(",")[0].split(" ")[0:2]+[",".join(line.split(",")[-2:])])
            #print(line)

            match = re.search(r'GVT\s+(\d+\.\d+),\s*(\d+\.\d+)', line)
            if match:
                # We need a line with previous datapoints to avoid spaces in the plot, but with updated linestyle
                line_style = 1 if "GPU GVT" in line else 0  # 1 for dashed (GPU), 0 for solid (CPU)
                data.append([x_value, y_value, line_style, background_phase])

                y_value = float(match.group(1))
                x_value = float(match.group(2))
                # Append the extracted data along with the current background phase
                last_before_challenge = [x_value, y_value, line_style, background_phase]
                data.append(last_before_challenge)
            else:
                data.append(last_before_challenge)

# Create a pandas DataFrame
df = pd.DataFrame(data, columns=['x', 'y', 'line_style', 'background_phase'])

# Save the DataFrame to a text file
df.to_csv(res_file, sep=' ', index=False, header=False)
print(f"Data has been written to {res_file}")
