
import os
import shutil

def main():
    project_slug = "{{ cookiecutter.project_slug }}"
    
    # 1. Directories to ensure exist (bind mount targets on host)
    local_dirs = [
        "docker/volumes/config",
        "docker/volumes/logs",
        "docker/volumes/data",
        "scripts",
        "{{ cookiecutter._host_backup_path }}"
    ]
    
    print("\n[Hook] Creating local directories...")
    current_dir = os.getcwd()
    
    for d in local_dirs:
        try:
            path = os.path.join(current_dir, d)
            os.makedirs(path, exist_ok=True)
            # Set permissions to 777 to allow container to write
            os.chmod(path, 0o777)
            print(f"✅ Ensured directory (777): {d}")
        except Exception as e:
            print(f"⚠️ Warning: Could not create/chmod {d}: {e}")

    # Remove AGENTS.md if it exists as it is not part of standard structure
    if os.path.exists("AGENTS.md"):
        os.remove("AGENTS.md")
        print("🗑️ Removed AGENTS.md")

if __name__ == "__main__":
    main()
