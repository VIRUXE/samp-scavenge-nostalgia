import os
import re
import json

admin_levels = {1: 'moderator', 2: 'administrador', 3: 'lead', 4: 'dev', 5: 'secret'}
commands_by_level = {name: [] for name in admin_levels.values()}

for root, _, files in os.walk(os.getcwd()):
    for file in files:
        if file.endswith('.pwn'):
            with open(os.path.join(root, file), 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                matches = re.findall(r'ACMD:([a-zA-Z0-9_]+)\[(\d+)\]\(playerid, params\[\]\)', content)
                for cmd, level in matches:
                    level_name = admin_levels.get(int(level))
                    if level_name: commands_by_level[level_name].append(cmd)

with open('commands_by_level.json', 'w') as f:
    json.dump(commands_by_level, f)
