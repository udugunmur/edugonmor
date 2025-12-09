import sys
import json
from collections import OrderedDict

def main():
    print("Running pre-gen hook for GitLab template")

    # Cookiecutter renders the context as a Python dictionary string here
    context = {{ cookiecutter }}

    # We can't easily json.dumps an OrderedDict if it contains complex objects,
    # but for simple config it should be fine if we convert to dict or use default=str
    print("\n--- Configuration Summary ---")
    # Convert to standard dict for clean JSON printing if needed, or just print keys
    try:
        print(json.dumps(context, indent=2, default=str))
    except Exception as e:
        print(f"Could not pretty print context: {e}")
        print(context)

    print("-----------------------------\n")

if __name__ == "__main__":
    main()
