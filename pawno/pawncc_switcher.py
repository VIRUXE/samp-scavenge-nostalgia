# Troca entre o arquivos de compilador russo e o original

import os

if os.path.exists("pawncc.exe_ru"):
    os.rename("pawncc.exe", "pawncc.exe_orig")
    os.rename("pawnc.dll", "pawnc.dll_orig")

    os.rename("pawncc.exe_ru", "pawncc.exe")
    os.rename("pawnc.dll_ru", "pawnc.dll")

    print("Switched to Russian compiler")
else:
    os.rename("pawncc.exe", "pawncc.exe_ru")
    os.rename("pawnc.dll", "pawnc.dll_ru")

    os.rename("pawncc.exe_orig", "pawncc.exe")
    os.rename("pawnc.dll_orig", "pawnc.dll")

    print("Switched to Original compiler")