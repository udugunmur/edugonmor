import re
import sys

MODULE_REGEX = r'^[_a-zA-Z][_a-zA-Z0-9]+$'

project_slug = '{{ cookiecutter.project_slug }}'

if not re.match(MODULE_REGEX, project_slug):
    print('ERROR: The project slug (%s) is not a valid Python module name. Please do not use a - and use _ instead' % project_slug)
    sys.exit(1)

# Validate mongo_version
valid_versions = ['6.0', '7.0', '8.0']
mongo_version = '{{ cookiecutter._mongo_version }}'
if mongo_version not in valid_versions:
    print('ERROR: mongo_version (%s) is not valid. Use one of: %s' % (mongo_version, ', '.join(valid_versions)))
    sys.exit(1)
