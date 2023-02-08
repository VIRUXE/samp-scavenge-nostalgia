import os

max_players = int(input("Quantos jogadores terá o servidor?"))

max_players_line = f"#define MAX_PLAYERS {max_players}"

files = []
for root, dirs, filenames in os.walk('.'):
    if 'pawno' in root: continue

    for filename in filenames:
        if filename.endswith('.pwn'):
            files.append(os.path.join(root, filename))

for file in files:
    # print(f"Reading {file}...")

    with open(file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            if line.find('#define MAX_PLAYERS') != -1:
                linenumber = lines.index(line) + 1
                print(f"\033[1;31m{file}\033[0m ({linenumber}): {line.strip()}")

print(f"{len(files)} files read.")

gamemodes = [file for file in files if 'gamemodes' in file]
print(f"{len(gamemodes)} gamemode files.")