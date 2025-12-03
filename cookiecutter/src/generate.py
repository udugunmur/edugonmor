import os
import sys
import json
from cookiecutter.main import cookiecutter

def main():
    template_key = os.environ.get('TEMPLATE', 'mysql')
    config_file = os.environ.get('CONFIG_FILE', '/config/example.json')
    output_dir = os.environ.get('OUTPUT_DIR', '/output')

    templates = {
        'mysql': os.environ.get('TEMPLATE_PATH_MYSQL', '/templates/mysql'),
        'mariadb': os.environ.get('TEMPLATE_PATH_MARIADB', '/templates/mariadb')
    }

    template_path = templates.get(template_key)
    if not template_path:
        print(f"Error: Unknown template '{template_key}'. Available: {list(templates.keys())}")
        sys.exit(1)

    if not os.path.exists(config_file):
        print(f"Error: Config file not found at {config_file}")
        sys.exit(1)

    print(f"Loading configuration from {config_file}...")
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
    except Exception as e:
        print(f"Error loading config: {e}")
        sys.exit(1)

    print(f"Generating project from {template_path}...")
    print(f"Output directory: {output_dir}")

    try:
        cookiecutter(
            template_path,
            no_input=True,
            extra_context=config,
            output_dir=output_dir
        )
        print("Generation successful.")
    except Exception as e:
        print(f"Generation failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
