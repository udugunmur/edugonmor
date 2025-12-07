
import os

def main():
    backup_base = "{{ cookiecutter._host_backup_path }}"
    project_slug = "{{ cookiecutter.project_slug }}"
    # MariaDB subfolder
    backup_path = os.path.join(backup_base, project_slug, "mariadb")

    if not os.path.isabs(backup_path):
        # If relative, we assume it's relative to the CWD where cookiecutter was run?
        # Or maybe just create it. Cookiecutter changes CWD to the generated project!
        # So we must be careful. _host_backup_path is usually absolute or relative.
        pass

    try:
        os.makedirs(backup_path, exist_ok=True)
        print(f"\n✅ Backup directory ensured: {backup_path}")
    except Exception as e:
        print(f"\n⚠️ WARNING: Could not create backup directory at '{backup_path}'.")
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
