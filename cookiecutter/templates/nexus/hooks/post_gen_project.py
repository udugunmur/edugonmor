
import os

def main():
    backup_base = "{{ cookiecutter._host_backup_path }}"
    project_slug = "{{ cookiecutter.project_slug }}"
    
    # 1. Directories to ensure exist (bind mount targets on host)
    local_dirs = [
        "docker/volumes/nexus_data",
        "docker/secrets",
        "backups/nexus"
    ]
    
    print("\n[Hook] Creating local directories...")
    current_dir = os.getcwd()
    
    for d in local_dirs:
        try:
            path = os.path.join(current_dir, d)
            os.makedirs(path, exist_ok=True)
            # Set permissions to 777 to allow container (UID 200) to write
            os.chmod(path, 0o777)
            print(f"✅ Ensured directory (777): {d}")
        except Exception as e:
            print(f"⚠️ Warning: Could not create/chmod {d}: {e}")

if __name__ == "__main__":
    main()
