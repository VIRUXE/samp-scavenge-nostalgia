import sys
import json

def walk_json(json_data, depth=0):
    max_depth = depth
    max_key_length = 0
    
    if isinstance(json_data, dict):
        for key, value in json_data.items():
            if isinstance(key, str):
                max_key_length = max(max_key_length, len(key))
                
            child_depth, child_key_length = walk_json(value, depth + 1)
            max_depth = max(max_depth, child_depth)
            max_key_length = max(max_key_length, child_key_length)
    elif isinstance(json_data, list):
        for item in json_data:
            child_depth, child_key_length = walk_json(item, depth + 1)
            max_depth = max(max_depth, child_depth)
            max_key_length = max(max_key_length, child_key_length)

    return max_depth, max_key_length

if len(sys.argv) != 2:
    print("Usage: python json_array_sizes.py <input_file>")
    sys.exit(1)

with open(sys.argv[1], 'r') as f:
    json_data = json.load(f)

max_depth, max_key_length = walk_json(json_data)

print("Max depth:", max_depth)
print("Max key length:", max_key_length)
