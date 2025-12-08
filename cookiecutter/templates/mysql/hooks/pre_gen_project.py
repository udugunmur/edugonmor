import sys
import os
from collections import OrderedDict

def main():
    # Validar directorio de salida
    current_dir = os.getcwd()
    parent_dir = os.path.dirname(current_dir)
    grandparent_dir = os.path.dirname(parent_dir)

    if os.path.basename(parent_dir) != 'output' or os.path.basename(grandparent_dir) != 'cookiecutter':
        print("\n" + "!"*60)
        print("ERROR CRÍTICO: Ubicación de salida no permitida.")
        print(f"Ruta actual: {current_dir}")
        print("POLÍTICA ESTRICTA: La generación DEBE realizarse en '.../cookiecutter/output/'.")
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
