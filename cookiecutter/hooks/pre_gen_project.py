import os
import sys

OUTPUT_DIR = os.getcwd()

if "output" not in OUTPUT_DIR:
    print("ERROR: You must generate the project inside an 'output' directory.")
    sys.exit(1)
