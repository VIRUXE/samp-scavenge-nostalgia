# Upload gamemodes/ScavengeSurvive.amx via sftp

import pysftp as sftp
import time
import os

# Get the current directory
dir = os.path.dirname(os.path.realpath(__file__))
# Get the gamemode file
file = os.path.join(dir, 'gamemodes', 'ScavengeSurvive.amx')

fileSize = os.path.getsize(file)
print('Tamanho do Gamemode: ' + str(fileSize * 0.000001)  + 'MB')

cnopts = sftp.CnOpts()
cnopts.hostkeys = None

# Connect to the server
with sftp.Connection('sv.scavengenostalgia.fun', username=input('Usuário: '), password=input('Chave: '), cnopts=cnopts) as sftp:
    print('Ligaçao estabelecida.')
    sftp.cwd('samp/nostalgia/gamemodes')
    
    if sftp.exists('ScavengeSurvive.amx'):
        gamemode = sftp.stat("ScavengeSurvive.amx")
        if gamemode:
            print('Tamanho na VPS: ' + str(gamemode.st_size * 0.000001)  + 'MB')

    print('Enviando arquivo...')
    start = time.time()
    sftp.put(file)
    end = time.time()

    elapsed = end - start

    if elapsed > 60: # If it took more than 60 seconds
        elapsed = str(round(elapsed / 60, 2)) + ' minutos'
    else:
        elapsed = str(round(elapsed, 2)) + ' segundos'

    print('Arquivo enviado com sucesso! Demorou: ' + elapsed)