import io
import os
import re
import json
from colorama import init, Fore, Style

init(autoreset=True)

routes_found = 0

provided_routes = {}

def process_content(content, file_path):
    global routes_found
    global provided_routes
    function_pattern = r'(?:ls|ChatMsgLang)\(\s*playerid\s*,\s*(?:[A-Z_]+\s*,\s*)?(".*?")\s*(?:,\s*[A-Z_]+)?\)'
    lines = content.splitlines()
    modified_lines = []

    for line_number, line in enumerate(lines, start=1):
        match = re.search(function_pattern, line)
        if match:
            search_key = match.group(1).strip('"')
            value = search_value_in_language_file(search_key, 'Portugues')
            if value:
                route = find_route_in_json(value)
                if route:
                    route_str = '/'.join(route)
                    print(f"{Fore.GREEN}{file_path}:{line_number} -> Key: '{search_key}', Value: '{value}' - Route: {route_str}")
                    routes_found += 1
                else:
                    print(f"{Fore.YELLOW}{file_path}:{line_number} -> Key: '{search_key}', Value: '{value}' - Route not found")
                    if search_key in provided_routes:
                        route_str = provided_routes[search_key]
                    else:
                        route_str = input(f"Provide the route to replace the key (leave blank to keep): ")
                        if route_str:
                            provided_routes[search_key] = route_str
                            create_nodes_in_json(route_str, search_key)
                        else:
                            continue

                line = line.replace(search_key, route_str)
                print(f"{Fore.CYAN}Replaced line: {line}")

        modified_lines.append(line)

    updated_content = "\n".join(modified_lines)
    with io.open(file_path, 'w', encoding='windows-1252', errors='ignore') as pwn_file:
        pwn_file.write(updated_content.rstrip('\n'))
        
def search_value_in_language_file(search_key, language):
    with open(f'scriptfiles/languages/{language}', 'r') as language_file:
        for line in language_file:
            if not line.strip() or '=' not in line:
                continue
            key, value = line.strip().split('=', maxsplit=1)
            if key == search_key:
                return value
    return None

def create_nodes_in_json(route_str, search_key):
    route = route_str.split('/')
    with open('scriptfiles/i18n.json', 'r') as json_file:
        json_data = json.load(json_file)

    current_node = json_data
    parent_node = None
    for key in route:
        parent_node = current_node
        if key not in current_node:
            current_node[key] = {}
        current_node = current_node[key]

    if not isinstance(current_node, list):
        pt_value = search_value_in_language_file(search_key, 'Portugues') or ""
        en_value = search_value_in_language_file(search_key, 'English') or ""
        new_node = [pt_value, en_value]
        parent_node[route[-1]] = new_node

        with open('scriptfiles/i18n.json', 'w') as json_file:
            json.dump(json_data, json_file, ensure_ascii=False, indent=2)

def find_route_in_json(value):
    with open('scriptfiles/i18n.json', 'r') as json_file:
        json_data = json.load(json_file)
        return find_route_recursive(json_data, value, [])

def find_route_recursive(json_data, value, current_route):
    for key, item in json_data.items():
        if isinstance(item, dict):
            new_route = current_route + [key]
            route = find_route_recursive(item, value, new_route)
            if route:
                return route
        elif isinstance(item, list) and len(item) >= 2:
            if item[1].lower() == value.lower():
                return current_route + [key]
    return None

for root, _, files in os.walk("gamemodes"):
    for file in files:
        if file.endswith('.pwn'):
            file_path = os.path.join(root, file)
            with io.open(file_path, 'r', encoding=None, errors='ignore') as pwn_file:
                content = pwn_file.read()
                process_content(content, file_path)
                
print(f"{Fore.CYAN}Total routes found: {routes_found}")