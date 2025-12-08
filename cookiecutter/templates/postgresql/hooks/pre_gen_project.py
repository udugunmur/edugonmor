import re
import sys
import os

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

MODULE_REGEX = r'^[_a-zA-Z][_a-zA-Z0-9]+$'

project_slug = '{{ cookiecutter.project_slug }}'

if not re.match(MODULE_REGEX, project_slug):
    print('ERROR: The project slug (%s) is not a valid Python module name. Please do not use a - and use _ instead' % project_slug)
    #Exit to cancel project
    sys.exit(1)

if __name__ == "__main__":
    main()
