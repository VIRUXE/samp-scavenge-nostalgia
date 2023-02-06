# This script watches ScavengeSurvive.amx for changes and restarts the server when it detects a change.
# Nota: inicia o servidor numa nova janela

import os
import time
import subprocess
import psutil # pip install psutil

amx_path = "gamemodes/ScavengeSurvive.amx"

last_size = os.path.getsize(amx_path)

print(f"\033[1;32;40mWatching ScavengeSurvive.amx for changes\033[0m")
print(f"\033[1;32;40mInitial size: {last_size} bytes\033[0m")

if not "samp-server.exe" in (p.name() for p in psutil.process_iter()):
    print(f"\033[1;32;40mStarting server\033[0m")
    subprocess.call("start samp-server.exe", shell=True)

while True:
    time.sleep(1)

    if not os.path.exists(amx_path): continue

    curr_size = os.path.getsize(amx_path)
    if curr_size != last_size:
        # print(f"\033[1;33;40mSize changed from {last_size} to {curr_size}\033[0m")
        last_size = curr_size

        if curr_size == 0: # If the file is empty, it's probably being compiled
            print(f"\033[1;33;40mScavengeSurvive.amx is being compiled. Waiting...\033[0m")
            continue
        
        # print(f"\033[1;31;40mDetected change in ScavengeSurvive.amx\033[0m")

        if curr_size < 44830000: continue

        # Kill the sa-mp server process and start it again
        subprocess.call("taskkill /f /im samp-server.exe", shell=True)
        subprocess.call("start samp-server.exe", shell=True)

        print(f"\033[1;32;40mRestarted server\033[0m")
