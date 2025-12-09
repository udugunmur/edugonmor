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

    context = {{ cookiecutter }}

    project_name = context.get('_project_name', 'UNKNOWN')

    print("\n" + "="*40)
    print(f"RESUMEN DE CONFIGURACIÓN - {project_name}")
    print("="*40)
    print(f"Project Name:      {context.get('_project_name')}")
    print(f"Project Slug:      {context.get('project_slug')}")
    print(f"Penpot Version:    {context.get('_penpot_version')}")
    print(f"Public URI:        {context.get('_penpot_public_uri')}")
    print(f"Penpot Port:       {context.get('_penpot_port')}")
    print(f"Postgres Host:     {context.get('_postgres_host')}")
    print(f"Postgres User:     {context.get('_postgres_user')}")
    print(f"Redis Host:        {context.get('_redis_host')}")
    print(f"Backup Retention:  {context.get('_backup_retention')}")
    print(f"Cron Schedule:     {context.get('_cron_schedule')}")
    print(f"Network Name:      {context.get('_network_name')}")
    print(f"Host Backup Path:  {context.get('_host_backup_path')}")
    print("="*40 + "\n")

    print("Generando proyecto de forma silenciosa...")

if __name__ == "__main__":
    main()
