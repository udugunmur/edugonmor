def test_bake_project(cookies):
    result = cookies.bake(extra_context={"project_name": "Test Project"})

    assert result.exit_code == 0
    assert result.exception is None

    assert result.project_path.name == "test_project"
    assert result.project_path.is_dir()

    readme_path = result.project_path / "README.md"
    assert readme_path.is_file()
    assert "Test Project" in readme_path.read_text()

    # Check docker-compose.yml
    dc_path = result.project_path / "docker-compose.yml"
    assert dc_path.is_file()
    dc_content = dc_path.read_text()
    assert "test_project_services" in dc_content
    assert "test_project_backup" in dc_content

    # Check agent.md
    assert (result.project_path / "agent.md").is_file()

    # Check config/init-data.json
    init_path = result.project_path / "config" / "init-data.json"
    assert init_path.is_file()
    init_content = init_path.read_text()
    assert "test_project_user" in init_content
    assert "test_project_password" in init_content

    # Check script fixes
    healthcheck_content = (result.project_path / "docker/scripts/healthcheck.sh").read_text()
    assert 'PASSWORD="$MARIADB_ROOT_PASSWORD"' in healthcheck_content

    syncdb_content = (result.project_path / "docker/scripts/sync-db.sh").read_text()
    assert 'ROOT_PASS="$MARIADB_ROOT_PASSWORD"' in syncdb_content
