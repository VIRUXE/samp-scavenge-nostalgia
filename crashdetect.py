import re
import json

result = {}
current_event = None

with open("crashdetect.log", "r") as file:
    for line in file:
        function_match = re.search(r"\[\d{2}:\d{2}:\d{2}\] .*? in (\w+)(?: \((.*?)\))? at (.+?):(\d+)", line)
        event_match = re.search(r"\[\d{2}:\d{2}:\d{2}\] (Long callback execution detected|Server received interrupt signal)", line)
        backtrace_match = re.search(r"\[\d{2}:\d{2}:\d{2}\] AMX backtrace:", line)

        if event_match:
            current_event = {
                "timestamp": line[1:9],
                "backtrace": []
            }
        elif backtrace_match:
            continue
        elif function_match and current_event:
            name, parameters, file_path, line_number = function_match.groups()
            
            info = {
                "name": name,
            }
            
            if parameters:
                parameters = re.findall(r"(\w+)=([^\s,]+)", parameters)
                info["parameters"] = dict(parameters)
            
            if file_path and line_number:
                info["file"] = {
                    "path": file_path,
                    "line": int(line_number)
                }

            current_event["backtrace"].append(info)

        elif not (function_match or event_match or backtrace_match) and current_event:
            if current_event["backtrace"]:
                first_function = current_event["backtrace"][0]["name"]
                if first_function not in result:
                    result[first_function] = {
                        "first-occurred": current_event["timestamp"],
                        "occurrences": 1,
                        "backtrace": current_event["backtrace"]
                    }
                else:
                    result[first_function]["occurrences"] += 1

            current_event = None

# Sort the results by occurrences in descending order
sorted_result = sorted(result.items(), key=lambda x: x[1]['occurrences'], reverse=True)

# Print out the results
for item in sorted_result:
    print(f"{item[0]}: {item[1]['occurrences']} occurrences, first occurred at {item[1]['first-occurred']}")
    
# Save the results to a JSON file
with open("crashdetect.json", "w") as outfile:
    json.dump(result, outfile, indent=4)
