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

    context = {{ cookiecutter }}

    project_name = context.get('_project_name', 'UNKNOWN')

    print("\n" + "="*40)
    print(f"RESUMEN DE CONFIGURACIÓN - {project_name}")
    print("="*40)
    print(f"Project Name:      {context.get('_project_name')}")
    print(f"Project Slug:      {context.get('project_slug')}")
    print(f"Nexus Version:     {context.get('_nexus_version')}")
    print(f"Nexus User:        {context.get('_nexus_user')}")
    print(f"Nexus Password:    {context.get('_nexus_password')}")
    print(f"Nexus Port:        {context.get('_nexus_port')}")
    print(f"Backup Retention:  {context.get('_backup_retention')}")
    print(f"Cron Schedule:     {context.get('_cron_schedule')}")
    print(f"Network Name:      {context.get('_network_name')}")
    print(f"Host Backup Path:  {context.get('_host_backup_path')}")
    print("="*40 + "\n")

    print("Generando proyecto de forma silenciosa...")

if __name__ == "__main__":
    main()
