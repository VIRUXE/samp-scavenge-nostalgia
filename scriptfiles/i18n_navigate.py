import json
import sys
import curses
import pyperclip
from pathlib import Path

def show_instructions(stdscr):
    _, width = stdscr.getmaxyx()
    instructions = "Setas: Navegar | s: Pesquisar | c: Copiar | Esc: Sair"
    start_x = max(width - len(instructions), 0)
    stdscr.addstr(0, start_x, instructions[:width - start_x])

def copy_to_clipboard(stdscr, current_path, selected_node=""):
    if current_path:
        path_str = "/".join(current_path)
        if selected_node:
            path_str += f"/{selected_node}"
        pyperclip.copy(path_str)
        message = "Caminho copiado para a área de transferência."
    else:
        message = "Não é possível copiar a rota da raiz."

    height, width = stdscr.getmaxyx()

    start_x = max(width - len(message), 0)
    stdscr.addstr(height - 2, start_x, message[:width - start_x])
    stdscr.refresh()
    stdscr.getch()

def search_json(data, query, current_path):
    results = []
    if isinstance(data, dict):
        for key, value in data.items():
            new_path = current_path + [key]
            if query.lower() in key.lower():
                results.append(new_path)
            results.extend(search_json(value, query, new_path))
    elif isinstance(data, list):
        for idx, item in enumerate(data):
            new_path = current_path + [str(idx)]
            if query.lower() in str(item).lower():
                results.append(new_path)
            results.extend(search_json(item, query, new_path))

    return results

def navigate_json(data, stdscr, current_path):
    height, width = stdscr.getmaxyx()

    if isinstance(data, dict):
        idx = 0
        keys = list(data.keys())
        scroll_offset = 0

        while True:
            stdscr.clear()
            
            show_instructions(stdscr)

            selected_node = keys[idx] if len(keys) > 0 else ""
            selected_node_type = "no" if isinstance(data.get(selected_node), dict) else "texto"
            current_path_str = f"Rota atual: {'/'.join(current_path)}/{selected_node} ({selected_node_type})" if len(current_path) else f"Rota atual: {selected_node} ({selected_node_type})"
            stdscr.addstr(0, 0, current_path_str[:width - 1])

            for i, key in enumerate(keys[scroll_offset:]):
                if i + 2 >= height:
                    break

                if i + scroll_offset == idx:
                    stdscr.addstr(i + 2, 0, f"> {key}"[:width - 1], curses.A_REVERSE)
                else:
                    stdscr.addstr(i + 2, 0, f"  {key}"[:width - 1])

            stdscr.refresh()
            key = stdscr.getch()

            if key == curses.KEY_DOWN:
                if idx + 1 < len(keys):
                    idx += 1
                if idx - scroll_offset > height - 4:
                    scroll_offset += 1
            elif key == curses.KEY_UP:
                if idx > 0:
                    idx -= 1
                if idx - scroll_offset < 0 and scroll_offset > 0:
                    scroll_offset -= 1
            elif key == curses.KEY_RIGHT:
                current_path.append(keys[idx])
                navigate_json(data[keys[idx]], stdscr, current_path)
                current_path.pop()
            elif key == curses.KEY_LEFT:
                return
            elif key == 27: # ESC
                sys.exit(0)
            elif key == ord('c'):
                copy_to_clipboard(stdscr, current_path, keys[idx])
            elif key == ord('s'):
                stdscr.clear()
                stdscr.addstr(0, 0, "Digite sua consulta de pesquisa e pressione Enter:")
                curses.echo()
                query = stdscr.getstr(1, 0, 20).decode('utf-8')
                curses.noecho()

                search_results = search_json(data, query, [])

                if search_results:
                    idx = 0
                    while True:
                        stdscr.clear()
                        
                        show_instructions(stdscr)
            
                        stdscr.addstr(0, 0, f"Resultados da pesquisa para '{query}':")
                        for i, path in enumerate(search_results):
                            if i + 2 >= height:
                                break
                            
                            if i == idx:
                                stdscr.addstr(i + 2, 0, f"> {'/'.join(path)}", curses.A_REVERSE)
                            else:
                                stdscr.addstr(i + 2, 0, f"  {'/'.join(path)}")

                        stdscr.refresh()
                        key = stdscr.getch()

                        if key == curses.KEY_DOWN and idx + 1 < len(search_results):
                            idx += 1
                        elif key == curses.KEY_UP and idx > 0:
                            idx -= 1
                        elif key == curses.KEY_RIGHT:
                            selected_path = search_results[idx]
                            selected_data = data
                            for key in selected_path:
                                selected_data = selected_data[key]
                            navigate_json(selected_data, stdscr, selected_path)
                        elif key == curses.KEY_LEFT:
                            break

                else:
                    stdscr.clear()
                    stdscr.addstr(0, 0, f"Nenhum resultado encontrado para '{query}'. Pressione qualquer tecla para continuar.")
                    stdscr.refresh()
                    stdscr.getch()

    elif isinstance(data, list):
        stdscr.clear()
        stdscr.addstr(0, 0, f"Rota atual: {'/'.join(current_path)}")

        for i, item in enumerate(data):
            if i + 3 >= height:
                stdscr.addstr(i + 2, 0, "[...]")
                break
            prefix = "Desconhecido"
            if i == 0:
                prefix = "Português"
            elif i == 1:
                prefix = "Inglês"

            item_str = f"{prefix}: {item}"
            stdscr.addstr(i + 2, (width - len(item_str)) // 2, item_str)
            
        show_instructions(stdscr)
        stdscr.refresh()

        key = stdscr.getch()
        if key == ord('c'):
            copy_to_clipboard(stdscr, current_path)
        elif key == 27:
            sys.exit(0)
    else:
        stdscr.clear()
        value_str = f"Valor: {data}"
        stdscr.addstr(0, (width - len(value_str)) // 2, value_str)
        stdscr.refresh()
        stdscr.getch()

def main(stdscr):
    if len(sys.argv) != 2:
        sys.stderr.write("Uso: python i18n_navigate.py <caminho_para_arquivo_json>\n")
        sys.exit(1)

    json_file_path = Path(sys.argv[1])
    if not json_file_path.is_file():
        sys.stderr.write(f"Erro: Arquivo '{json_file_path}' não encontrado.\n")
        sys.exit(1)

    with json_file_path.open() as f:
        data = json.load(f)

    current_path = []
    navigate_json(data, stdscr, current_path)

if __name__ == "__main__":
    curses.wrapper(main)
