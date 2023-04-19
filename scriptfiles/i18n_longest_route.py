import json

def walk_json(json_obj, path=[]): 
    longest_path = path
    for key, value in json_obj.items(): 
        current_path = path + [key]
        if isinstance(value, dict): 
            candidate_longest_path = walk_json(value, current_path)
            if len(candidate_longest_path) > len(longest_path): 
                longest_path = candidate_longest_path
    return longest_path

with open("i18n.json", "r") as f: 
    data = json.load(f)

longest_route     = walk_json(data)
longest_route_str = '/'.join(longest_route)
print(f"Longest route: {longest_route_str}")
print(f"Length (number of keys): {len(longest_route)}")
print(f"String length: {len(longest_route_str)}")
