# Descobre quais as keys do arquivo Portugues que possuem acentos

Portugues = dict()

accents = list()

with open("Portugues", "r", encoding="utf-8") as f:
    for line in f.readlines():
        delimiter = line.find("=")

        if delimiter == -1: continue

        key   = line[:delimiter].strip()
        value = line[delimiter+1:].strip()

        Portugues[key] = value

        # Find out if the value string has any accents
        if any([ord(c) > 127 for c in value]): accents.append(key)

for key in accents:
    if key in Portugues:
        value = Portugues[key]
        print(key, "=", value)