# Converte os acentos para um simbolo que consiga ser visivel em Textdraws
# Nao aparenta funcionar

accents = {
    "â": "",
    "ã": "",
    "á": "",
    "é": "",
    "ú": "",
    "ó": "¦",
    "ê": "",
    "í": "¢",
    "ç": "",
    "ô": "§",
}

portugues = open("Portugues", "r", encoding="utf-8").readlines()

for line in portugues:
    try:
        if any(acc in line for acc in accents):
            for acc in accents:
                line = line.replace(acc, accents[acc])
                print(f"\033[32m{line}\033[0m", end="")
    except UnicodeDecodeError:
        print(f"\033[31mError: {line}\033[0m", end="")
        pass

open(file="Portugues", mode="w", encoding="utf-8").writelines(portugues)
