import subprocess
import datetime

current_date = datetime.date.today().strftime("%d-%m-%Y")

subprocess.call(['7z', 'a', '-t7z', '-mx=9', '-mmt=on', '-x!_backups', '-x!.git', '-x!crashinfo.txt', '-x!*.7z', '-x!server_log.txt', '-x!*.log', '-r', '-y', f'_backups/nostalgia_{current_date}.7z', '.\\'])