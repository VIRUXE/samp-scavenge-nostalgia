import os

max_players = input("Quantos jogadores terá o servidor? ") or 40
max_players = int(max_players)

print(f"Definindo o número m�ximo de jogadores para {max_players}...")

files = []
# Procuramos por todos os arquivos de forma recursiva, exceto os que estão na pasta pawno
for root, dirs, filenames in os.walk('.'):
    if 'pawno' in root: continue

    for filename in filenames:
        # Queremos apenas os arquivos .pwn
        if filename.endswith('.pwn'):
            files.append(os.path.join(root, filename))

files_changed = 0

# Para cada arquivo .pwn, procuramos a linha que contém o define MAX_PLAYERS
for file in files:
    # print(f"Reading {file}...")

    with open(file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            if line.find('#define MAX_PLAYERS') != -1:
                linenumber = lines.index(line) + 1
                line = line.strip()
                curr_max_players = int(line[line.find('(') + 1:line.find(')')])
                
                if curr_max_players != max_players: # if the max players is different from the one we want
                    print(f"\033[1;31m{file}\033[0m ({linenumber}): {line}")
                    if input("Deseja alterar o número m�ximo de jogadores? [y/N] ") == 'y':
                        # Alteramos a linha com o define MAX_PLAYERS para o valor desejado
                        lines[linenumber - 1] = f"#define MAX_PLAYERS ({max_players})\n"

                        # Salvamos o arquivo com as alterações
                        with open(file, 'w') as f:
                            f.writelines(lines)
                            files_changed += 1
                            print(f"Arquivo {file} alterado com sucesso!")
                else:
                    print(f"\033[1;32m{file}\033[0m ({linenumber}): {line}")
                        

print(f"{len(files)} files read.")

gamemodes = [file for file in files if 'gamemodes' in file]
print(f"{len(gamemodes)} gamemode files.")

print(f"{files_changed} files changed.")