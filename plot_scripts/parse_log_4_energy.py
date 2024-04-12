import sys

log_path = sys.argv[1]

def find_last_nonempty_line(file_path):
    with open(file_path, 'rb') as file:
        file.seek(0, 2)
        file_size = file.tell()
        buffer_size = 1024
        buffer = bytearray()
        position = file_size

        while position >= 0:
            position = max(0, position - buffer_size)  # Calculate the next position to read from
            file.seek(position)
            chunk = file.read(min(buffer_size, file_size - position))
            buffer[0:0] = chunk  # Prepend the read chunk to the buffer
            lines = buffer.splitlines(True)  # Keep the line breaks
            
            # Iterate through the lines in reverse order looking for a non-empty line
            for line in reversed(lines):
                if line.strip():  # Found the last non-empty line
                    return line.decode('utf-8').strip()
                    
            # If no non-empty line is found in the current buffer, continue with the next chunk
            buffer = bytearray(lines[0]) if lines else bytearray()  # Keep the first (incomplete) line in the buffer
        return None

def get_cpu_gpu_energy(line):
    tokens = line.split(',')
    return tokens[2].strip(), tokens[1].strip()


files = {
    "CPU Only": "1.txt",
    "GPU Only": "2.txt",
    "FTL": "3.txt"
}

output=""

for scenario, file_name in files.items():
    path = f"{log_path}/{file_name}"
    last_line = find_last_nonempty_line(path)
    if last_line:
        cpu, gpu = get_cpu_gpu_energy(last_line)
        output += f"\"{scenario}\"\t{cpu}\t{gpu}\n"

with open(f"{log_path}.energy.txt", "w") as file:
    file.write(output)
