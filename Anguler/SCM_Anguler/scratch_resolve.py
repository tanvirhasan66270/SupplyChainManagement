import sys

def resolve_conflicts(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    new_lines = []
    state = 'NORMAL' # NORMAL, IN_UPSTREAM, IN_STASHED

    for line in lines:
        if line.startswith('<<<<<<< Updated upstream'):
            state = 'IN_UPSTREAM'
            continue
        elif line.startswith('======='):
            state = 'IN_STASHED'
            continue
        elif line.startswith('>>>>>>> Stashed changes'):
            state = 'NORMAL'
            continue
        
        if state == 'NORMAL' or state == 'IN_UPSTREAM':
            new_lines.append(line)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print(f"Resolved conflicts in {filepath}")

if __name__ == '__main__':
    resolve_conflicts(sys.argv[1])
