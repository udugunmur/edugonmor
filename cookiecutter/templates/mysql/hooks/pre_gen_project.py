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
    project_name = context.get('_project_name', 'UNKNOWN')

    print("\n" + "="*40)
    print(f"RESUMEN DE CONFIGURACIÓN - {project_name}")
    print("="*40)
    print(f"Project Name:      {context.get('_project_name')}")
    print(f"Project Slug:      {context.get('project_slug')}")
    print(f"DB Root Password:  {context.get('_db_root_password')}")
    print(f"Backup Retention:  {context.get('_backup_retention')}")
    print(f"Cron Schedule:     {context.get('_cron_schedule')}")
    print(f"Network Name:      {context.get('_network_name')}")
    print(f"Host Backup Path:  {context.get('_host_backup_path')}")
    print("="*40 + "\n")

    print("Generando proyecto de forma silenciosa...")

if __name__ == "__main__":
    main()
