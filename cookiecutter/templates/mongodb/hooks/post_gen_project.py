
import os

def main():
    backup_base = "{{ cookiecutter._host_backup_path }}"
    project_slug = "{{ cookiecutter.project_slug }}"
    # MongoDB: No subfolder in docker-compose.yml
    backup_path = os.path.join(backup_base, project_slug)

    try:
        os.makedirs(backup_path, exist_ok=True)
        print(f"\n✅ Backup directory ensured: {backup_path}")
    except Exception as e:
        print(f"\n⚠️ WARNING: Could not create backup directory at '{backup_path}'.")
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
