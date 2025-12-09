# Master Protocol (AGENTS.md)

## Scope
This protocol applies to the `{{cookiecutter.project_slug}}` project.

## Standards
1.  **Docker First**: All operations must be containerized.
2.  **Naming Convention**:
    *   Services: `{{cookiecutter.project_slug}}_*`
    *   Volumes: `{{cookiecutter.project_slug}}_*`
3.  **Backups**: Ensure backup volumes are mapped correctly to the host rclone path.
