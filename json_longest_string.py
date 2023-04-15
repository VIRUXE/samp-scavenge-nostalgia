import argparse
import json


def walk_json(node, max_length, max_string):
    """
    Recursively walks through a JSON object and checks if any of its values are arrays or strings.
    If a string is found, its length is compared to the current max_length and updated if necessary.
    If an array is found, each of its elements is walked recursively.

    :param node: a JSON object or value
    :param max_length: the length of the longest string found so far
    :param max_string: the string of the longest string found so far
    :return: a tuple containing the new max_length and max_string after walking through the node
    """
    if isinstance(node, str):
        # If node is a string, update max_length and max_string if necessary
        node_length = len(node)
        if node_length > max_length:
            max_length = node_length
            max_string = node
    elif isinstance(node, list):
        # If node is a list, walk through each of its elements recursively
        for i, element in enumerate(node):
            max_length, max_string = walk_json(element, max_length, max_string)
    elif isinstance(node, dict):
        # If node is a dictionary, walk through each of its values recursively
        for value in node.values():
            max_length, max_string = walk_json(value, max_length, max_string)
    return max_length, max_string


# Create an argument parser to accept the JSON file as an argument
parser = argparse.ArgumentParser(description='Find the longest string inside arrays in a JSON file and its line number.')
parser.add_argument('filename', help='the name of the JSON file to read')
args = parser.parse_args()

# Open the JSON file
with open(args.filename) as f:
    data = json.load(f)

# Walk through the JSON object recursively to find the longest string inside arrays
max_length, max_string = walk_json(data, 0, '')

# Find the line number of the longest string inside arrays
with open(args.filename) as f:
    lines = f.readlines()
for i, line in enumerate(lines, start=1):
    if max_string in line:
        line_number = i
        break

print(f"The longest string inside arrays in the JSON file is '{max_string}' (length: {max_length}) on line {line_number}.")
