def read_file(file):
    new_dict = dict()

    entries = 0

    with open(file, "r", encoding="utf-8") as f:
        for line in f:
            # Ignore any lines that don't start with an uppercase letter
            if not line[0].isupper(): continue

            delimiter = line.find("=", 0)

            key = line[:delimiter]
            value = line[delimiter + 1:]

            new_dict[key] = value

            entries += 1

    print(f"\033[32m\n{entries} entries found in {file}\033[0m")

    return new_dict

English   = read_file("English")
Portugues = read_file("Portugues")

missing = set(English.keys()) - set(Portugues.keys())

extra = set(Portugues.keys()) - set(English.keys())

shared = set(English.keys()) & set(Portugues.keys())

for key in missing:
    Portugues[key] = English[key]

for key in extra:
    English[key] = Portugues[key]

English   = dict(sorted(English.items()))
Portugues = dict(sorted(Portugues.items()))

with open("English", "w", encoding="utf-8") as f:
    for key, value in English.items():
        f.write(f"{key}={value}")

with open("Portugues", "w", encoding="utf-8") as f:
    for key, value in Portugues.items():
        f.write(f"{key}={value}")