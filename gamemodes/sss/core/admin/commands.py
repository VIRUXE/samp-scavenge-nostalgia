import os
import re

def find_commands_and_levels():
    commands = {}

    staff_level_names = [
        "NONE",
        "GAME_MASTER",
        "MODERATOR",
        "ADMINISTRATOR",
        "LEAD",
        "DEVELOPER",
        "SECRET"
    ]

    for root, dirs, files in os.walk(os.getcwd()):
        for file in files:
            if file.endswith(".pwn"):
                file_path = os.path.join(root, file)
                with open(file_path, "r") as f:
                    lines = f.readlines()
                    for line in lines:
                        # Skip commented lines
                        if line.startswith("//"):
                            continue

                        match_command = re.search(r'ACMD:(\w+)\[(\w+)\]\((\w+),\s*params(?:\[\])?\)', line)

                        if match_command:
                            command_name = match_command.group(1)
                            access_level = match_command.group(2)
                            level_name = staff_level_names[int(access_level)]
                            if level_name not in commands:
                                commands[level_name] = []
                            commands[level_name].append(command_name)
    return commands

result_commands = find_commands_and_levels()

# Write the commands by access level name to a Markdown file
with open("commands.md", "w") as f:
    for access_level, commands in result_commands.items():
        f.write(f"\n# {access_level}\n")
        for command in commands:
            f.write(f"- {command}\n")
