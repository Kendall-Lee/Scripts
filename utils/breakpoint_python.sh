def find_breakpoints(delta_file):
    breakpoints = []
    with open(delta_file, 'r') as file:
        in_alignment = False
        for line in file:
            if line.startswith('>'):
                in_alignment = True
                continue
            if in_alignment:
                if line.startswith('>') or line.startswith('<') or line.startswith('='):
                    in_alignment = False
                    continue
                data = line.strip().split()
                ref_start = int(data[0])
                ref_end = int(data[1])
                qry_start = int(data[2])
                qry_end = int(data[3])
                if ref_end != qry_end:
                    breakpoints.append((ref_end, qry_end))
    return breakpoints

# Usage example
delta_file = 'alignment.delta'
breakpoints = find_breakpoints(delta_file)

for breakpoint in breakpoints:
    print(f"Breakpoint: {breakpoint[0]} (Reference) - {breakpoint[1]} (Query)")
