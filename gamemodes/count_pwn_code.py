# Conta todas as linhas de código em todos os arquivos .pwn
# Num formato JSON e salva em um arquivo chamado linecount.json

import os
import json

def is_pwn_file(file_name):
    return file_name.endswith('.pwn')

def is_actual_code(line):
    stripped_line = line.strip()
    return len(stripped_line) > 0 and not stripped_line.startswith('//')

def count_lines_of_code(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
        return sum(1 for line in lines if is_actual_code(line))


def insert_file(tree, parts, lines_of_code):
    if len(parts) == 1:
        tree[parts[0]] = lines_of_code
    else:
        if parts[0] not in tree:
            tree[parts[0]] = {}
        insert_file(tree[parts[0]], parts[1:], lines_of_code)

def check_differences(tree, old_tree):
    differences = {}
    
    for key, value in tree.items():
        if key not in old_tree:
            differences[key] = value
        elif isinstance(value, dict) and isinstance(old_tree[key], dict):
            nested_differences = check_differences(value, old_tree[key])
            if nested_differences:
                differences[key] = nested_differences
        elif value != old_tree[key]:
            if isinstance(value, int) and isinstance(old_tree[key], int):
                differences[key] = value - old_tree[key]
            else:
                differences[key] = value
            
    return differences

folders_to_exclude  = set(['world-bs', 'world-wasteland'])
total_lines_of_code = 0
dir_structure       = {}

for root, dirs, files in os.walk(os.getcwd()):
    dirs[:] = [d for d in dirs if d not in folders_to_exclude]  # Exclude specified folders
    for file_name in files:
        if is_pwn_file(file_name):
            file_path              = os.path.join(root, file_name)
            lines_of_code          = count_lines_of_code(file_path)
            total_lines_of_code   += lines_of_code
            relative_path          = os.path.relpath(file_path, os.getcwd())
            parts                  = relative_path.split(os.sep)
            file_name_without_ext  = os.path.splitext(parts[-1])[0]
            parts[-1]              = file_name_without_ext
            insert_file(dir_structure, parts, lines_of_code)

print(f'Total lines of code in all .pwn files: {total_lines_of_code}')

# Load previous JSON
try:
    with open('linecount.json', 'r', encoding='utf-8') as file:
        old_dir_structure = json.load(file)
except FileNotFoundError:
    old_dir_structure = {}

# Check for differences
differences = check_differences(dir_structure, old_dir_structure)

# Save to JSON
with open('linecount.json', 'w', encoding='utf-8') as file:
    json.dump(dir_structure, file, indent=4)

if differences:
    print("Differences found:")
    print(json.dumps(differences, indent=4))
else:
    print("No differences found.")