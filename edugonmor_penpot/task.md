# 📋 Task List: Penpot Integration

- [x] **Analysis & Planning**
    - [x] Create implementation plan with 3 options.
    - [x] Select Option 1 (Full Integration).

- [x] **Implementation**
    - [x] Configure PostgreSQL user (`init-data.json`).
    - [x] Create Penpot `docker-compose.yml` and `.env`.
    - [x] Configure Rclone backup.
    - [x] Integrate centralized Redis (`edugonmor_redis`).
    - [x] Configure Nginx Reverse Proxy (`penpot.conf`).
    - [x] Update DNS (`edugonmor_ovh_updater`).

- [/] **Verification & Debugging**
    - [x] Verify Nginx access (`penpot.edugonmor.com`).
    - [x] Verify local access (`IP:9001`).
    - [/] **Debug 502 Bad Gateway (Frontend -> Backend)** <!-- CURRENT FOCUS -->
        - [ ] Check Backend logs for errors.
        - [ ] Verify internal port/host configuration.
    - [ ] Final Verification (Login/Create Project).

- [ ] **Documentation & Handover**
    - [ ] Create Walkthrough artifact.
    - [ ] Final `make stable` sync.
