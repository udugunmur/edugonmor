import sys
import os
from collections import OrderedDict

def main():
    # Validar directorio de salida
    current_dir = os.getcwd()
    if "output" not in current_dir:
        print("\n" + "!"*60)
        print("ERROR CRÍTICO: Directorio de salida inválido.")
        print(f"Ruta actual: {current_dir}")
        print("La generación DEBE realizarse dentro de un directorio 'output/'.")
        print("Usa el flag '-o output' en tu comando cookiecutter.")
        print("!"*60 + "\n")
        sys.exit(1)

    # Cookiecutter renders this dict literal directly into the script
    # It might render as OrderedDict(...) so we import it.
    context = {{ cookiecutter }}

    # context is a dict or OrderedDict
    project_name = context.get('project_name', 'UNKNOWN')

    print("\n" + "="*40)
    print(f"RESUMEN DE CONFIGURACIÓN - {project_name}")
    print("="*40)
    print(f"Project Name:      {context.get('project_name')}")
    print(f"Project Slug:      {context.get('project_slug')}")
    print(f"DB Root Password:  {context.get('db_root_password')}")
    print(f"Backup Retention:  {context.get('backup_retention')}")
    print(f"Cron Schedule:     {context.get('cron_schedule')}")
    print(f"Network Name:      {context.get('network_name')}")
    print(f"Rclone Path:       {context.get('rclone_base_path')}")
    print("="*40 + "\n")

    try:
        if sys.stdin.isatty():
            confirm = input("¿Es correcta esta configuración? [y/N]: ").strip().lower()
            if confirm != 'y':
                print("Cancelando generación...")
                sys.exit(1)
        else:
            print("Ejecución no interactiva detectada. Omitiendo confirmación manual.")
    except Exception:
        pass

if __name__ == "__main__":
    main()
