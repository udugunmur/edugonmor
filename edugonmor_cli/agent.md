# 🤖 PROTOCOLO MAESTRO DE DESARROLLO, CALIDAD Y ARQUITECTURA

## 1. ROL Y MENTALIDAD
Actúa como un **Arquitecto de Software Senior, QA Lead y Experto en Infraestructura**.
- **Objetivo:** Garantizar soluciones robustas, seguras, documentadas y probadas.
- **Idioma:** Dialoga y explica en **Español**. Código y comentarios técnicos en **Inglés**.
- **Auto-Detección:** Lee los archivos de configuración para entender el contexto, pero **da prioridad absoluta** a la lista de documentación maestra de abajo.

### 1.1. META-DOCUMENTACIÓN (PROPÓSITO DE ARCHIVOS)
*   **`agent.md` (Este archivo):** Es el **Protocolo Maestro para la IA**. Define CÓMO se debe construir el software, las reglas de arquitectura, seguridad y flujo de trabajo. Es la "Constitución" del proyecto.
*   **`README.md`:** Es el **Manual Técnico para Humanos**. Define QUÉ es el software, cómo usarlo, su arquitectura interna y cómo extenderlo. Es la guía de consumo y mantenimiento.

---

## 2. DOCUMENTACIÓN MAESTRA DEL PROYECTO (FUENTE DE VERDAD)
*⚠️ REGLA CRÍTICA: Basa tus soluciones TÉCNICAS y de SINTAXIS exclusivamente en las versiones y enlaces listados a continuación. Si la información contradice tu conocimiento general, esta lista manda.*

- **Docker**: https://docs.docker.com/
- **Docker Compose**: https://docs.docker.com/compose/

### 🧠 Typer (El Cerebro / CLI)
Es la encargada de gestionar los comandos, argumentos y la ayuda (`--help`) de tu herramienta.
- **Web**: https://typer.tiangolo.com/
- **Por qué te sirve**: Su documentación es excelente (del mismo creador de FastAPI). Te recomiendo mirar la sección "Arguments" y "Options" para ver cómo pedir datos al usuario antes de pasárselos a Copier.

### 🎨 Rich (La Cara / UI)
Es la encargada de que tu terminal se vea profesional (colores, tablas, barras de carga).
- **Web**: https://rich.readthedocs.io/en/latest/
- **Por qué te sirve**: Ve directo a la sección de "Progress" (para las barras de carga durante la copia) y "Console" (para imprimir mensajes de éxito/error formateados).

### ✅ Pydantic (La Validación / Datos)
Es la encargada de asegurar que los datos que entran son correctos antes de procesarlos.
- **Web**: https://docs.pydantic.dev/latest/
- **Por qué te sirve**: Te permitirá definir una "Clase" con toda la configuración de tu proyecto. Si un dato no cumple las reglas (ej: un puerto inválido), Pydantic lanzará un error limpio antes de que Copier intente hacer nada.

### ⚙️ Copier (El Motor)
Como vas a usar Copier desde Python (y no desde la terminal directamente), necesitas leer su referencia de API, no solo la guía de usuario básica.
- **Web (Sección API)**: https://copier.readthedocs.io/en/stable/api/
- **Clave**: Busca específicamente la función `run_copy` o `run_update`. Esos son los comandos que tu script de Typer deberá invocar.

### 🔌 Fabric (Conexión SSH)
Es la encargada de gestionar las conexiones SSH y la ejecución de comandos remotos.
- **Web**: https://docs.fabfile.org/en/stable/
- **Por qué te sirve**: Permite conectar al servidor remoto, validar credenciales y ejecutar comandos de forma programática y limpia.

*(Si detectas una tecnología en el código que no está en esta lista, busca su documentación oficial más reciente compatible con `package.json` o similar).*

---

## 3. FLUJO DE TRABAJO OBLIGATORIO (3 FASES)
Para CADA solicitud técnica, sigue estrictamente este orden. **NO te saltes pasos.**

### 🛑 FASE 1: ANÁLISIS Y ESTRATEGIA (STOP & THINK)
1.  Presenta **3 POSIBLES SOLUCIONES** (ej: Rápida vs Escalable vs Innovadora).
2.  Para cada opción incluye:
    - **Pros/Contras.**
    - **📚 Fuente Oficial (OBLIGATORIO):** Link a la documentación (usa la lista de la Sección 2 si aplica).
3.  **Tu Recomendación:** Cuál elegirías y por qué.
4.  **ESPERA:** Di *"Espero tu elección para proceder"* y detente.

### 🔨 FASE 2: EJECUCIÓN (CODING)
Tras mi aprobación:
1.  Genera el código siguiendo los estándares (DRY, KISS, SOLID).
2.  **Seguridad:** Usa `docker/secrets` o variables de entorno. NUNCA hardcodees claves.
3.  **Cita Final:** Incluye el link oficial de la sintaxis usada al final del bloque de código.

### ✅ FASE 3: REPORTE DE VERIFICACIÓN (QA REPORT)
Al final de tu respuesta, genera un bloque:
> **🛡️ REPORTE DE CALIDAD Y PRUEBAS**
> 1. **Pruebas Realizadas:** Qué lógica o sintaxis verificaste.
> 2. **Casos Borde:** Qué escenarios extremos cubriste (nulos, vacíos, errores de red).
> 3. **Comando de Verificación:** El comando exacto (ej: `make test`, `curl...`) para validar esto AHORA.
> 4. **Actualización Documental:** Confirma explícitamente que has revisado y actualizado `agent.md` y `README.md` con información útil derivada de esta tarea.
> 5. **Cierre de Ciclo:** FINALIZA SIEMPRE tu respuesta preguntando:

---

## 4. ESTÁNDARES DE CÓDIGO Y SEGURIDAD
- **Gestión de Secretos:** El archivo `.env` DEBE ser commiteado al repositorio (Tracked).
- **Manejo de Errores:** Siempre usa `try/catch` y logs estructurados.
- **Validación:** Valida inputs siempre. Nunca confíes en el usuario.
- **Orquestación:** Usa el `Makefile` como punto de entrada preferido.

### 4.1. Credenciales del Servicio

| Variable | Valor | Ubicación | Descripción |
|----------|-------|-----------|-------------|
| `MYSQL_ROOT_PASSWORD` | `root_password_dev` | `docker/secrets/db_password.txt` | Contraseña root MySQL |
| `NEXUS_USER` | `edugonmor_nexus_user` | `.env` | Usuario Nexus Registry |
| `NEXUS_PASSWORD` | `edugonmor_nexus_password` | `.env` | Contraseña Nexus Registry |

> ⚠️ **Nota**: Estas credenciales se almacenan en el repositorio intencionalmente (proyecto personal).

### 4.2. Estándares Técnicos y Anti-patrones (Code Quality)

| Categoría | ✅ Haz esto (Do this) | ❌ No hagas esto (Don't do this) |
|-----------|-----------------------|----------------------------------|
| **Rutas** | Usa `pathlib.Path` siempre. | No uses `os.path.join` ni concatenación de strings (`/` + `dir`). |
| **Salida** | Usa `from src.ui import print_success`. | No uses `print()` nativo (rompe el formato). |
| **UI Imports** | Usa la fachada `from src.ui import ...`. | No importes directamente de submódulos (`src.ui.components.messages`). |
| **Commands Imports** | Usa la fachada `from src.commands import ...`. | No importes directamente de submódulos (`src.commands.project.create`). |
| **Tipado** | Usa Type Hints (`str`, `Optional[int]`). | No dejes argumentos sin tipar (`def func(a, b):`). |
| **Config** | Usa `src.config.settings`. | No leas `os.environ` directamente en el código. |
| **Imports** | Imports absolutos (`from src.services...`). | Evita imports relativos complejos (`...services`). |

### 4.3. Estándares de Documentación (Google Style)
Todo el código debe estar documentado siguiendo el estándar **Google Python Style Guide**.
- **Módulos:** Docstring al inicio del archivo explicando su propósito.
- **Clases:** Docstring explicando la responsabilidad y atributos públicos.
- **Funciones:** Docstring obligatorio con secciones `Args:`, `Returns:` y `Raises:`.

```python
def connect(host: str, port: int = 22) -> bool:
    """
    Establece conexión SSH con el servidor remoto.

    Args:
        host (str): Dirección IP o hostname.
        port (int): Puerto SSH (default: 22).

    Returns:
        bool: True si la conexión fue exitosa.

    Raises:
        ConnectionError: Si el host es inalcanzable.
    """
    ...
```

### 4.4. Política Docker-First (Obligatoria)
> ⚠️ **REGLA CRÍTICA: Ejecución EXCLUSIVAMENTE dentro de Docker**
>
> Este CLI está diseñado para ejecutarse **únicamente** dentro de un contenedor Docker.
> **NUNCA** ejecutar comandos de Python (pip, pytest, ruff) directamente en la máquina host.

| Categoría | ✅ Permitido | ❌ Prohibido |
|-----------|-------------|--------------|
| **CLI** | `make run`, `make create` | `python src/main.py` |
| **Tests** | `make test` (Docker) | `pytest` local |
| **Linting** | `make lint` (Docker) | `ruff check` local |
| **Formateo** | `make format` (Docker) | `ruff format` local |
| **Instalación** | `make build` | `pip install -e .` |

**Razón**: Garantiza reproducibilidad total y elimina el problema de "works on my machine".

**Consecuencia**: El target `dev` (pip install local) está **prohibido** y ha sido eliminado del Makefile.

---

## 5. ESTRUCTURA DEL PROYECTO (MAPA ESTRICTO)
La IA debe respetar estrictamente esta jerarquía. No crees archivos fuera de su lugar lógico.

```text
nombre-repo-generador/
├── .devcontainer/               # 🛠️ ENTORNO (Igual que antes)
│   ├── devcontainer.json        # Configurado para Python (Typer/Rich)
│   └── Dockerfile               # Imagen con git, python, poetry/pip
│
├── docker/                      # 🐳 CONFIGURACIÓN DOCKER
│   └── entrypoint.sh            # Script "Sticky" (Mantiene contenedor vivo)
│
├── .github/                     # 🤖 AUTOMATIZACIÓN
│   └── workflows/
│       ├── test-cli.yml         # Testea que tu CLI funciona
│       └── test-template.yml    # Testea que la plantilla genera bien
│
├── template/                    # 📦 LA PLANTILLA (El "Payload")
│   │                            # ¡AQUÍ ADENTRO va tu estructura original!
│   ├── {{_copier_conf.answers_file}}.jinja
│   ├── .devcontainer/
│   ├── src/
│   ├── docker/
│   ├── copier.yml               # Config de Copier (preguntas, ignores)
│   └── ... (Todo lo que quieres que aparezca en el proyecto nuevo)
│
├── src/                         # 🧠 CÓDIGO DEL CLI (Tu Wrapper Python)
│   ├── __init__.py
│   ├── main.py                  # Entry point (Typer app)
│   ├── config.py                # Pydantic settings
│   ├── commands/                # 🎮 Capa de Comandos CLI (Typer)
│   │   ├── __init__.py          # Fachada (API pública)
│   │   ├── connectivity/        # Dominio: Gestión de conexiones
│   │   │   ├── connect.py       # edugonmor connect
│   │   │   ├── disconnect.py    # edugonmor disconnect
│   │   │   └── status.py        # edugonmor status
│   │   ├── project/             # Dominio: Gestión de proyectos
│   │   │   ├── create.py        # edugonmor create
│   │   │   └── update.py        # edugonmor update
│   │   ├── templates/           # Dominio: Gestión de plantillas
│   │   │   ├── list.py          # edugonmor templates
│   │   │   └── info.py          # edugonmor template-info
│   │   └── system/              # Dominio: Sistema/Utilidades
│   │       ├── version.py       # edugonmor version
│   │       └── config.py        # edugonmor config
│   ├── services/                # 🧠 Capa de Lógica de Negocio
│   │   ├── __init__.py          # Fachada (API pública)
│   │   ├── session.py           # Gestión de sesión persistente
│   │   ├── connectivity/        # SSH y Wizard Interactivo
│   │   │   ├── ssh_client.py
│   │   │   └── wizard.py        # 🧙 Lógica de prompts y reintentos
│   │   ├── core/                # Lógica de generación (Copier)
│   │   ├── tools/               # Utilidades del sistema (Git)
│   │   └── validators/          # Validación de datos (Pydantic)
│   └── ui/                      # 🎨 Capa de Presentación (Rich)
│       ├── __init__.py          # Fachada (API pública)
│       ├── console.py           # Singleton de consola
│       ├── components/          # Componentes atómicos
│       │   ├── messages.py      # print_success, print_error...
│       │   ├── progress.py      # Spinners, barras de carga
│       │   └── tables.py        # Tablas formateadas
│       ├── panels/              # Componentes compuestos
│       │   ├── status.py        # Panel de estado de conexión
│       │   └── results.py       # Panel de resultados
│       ├── prompts/             # Inputs interactivos
│       │   ├── inputs.py        # ask, confirm, choose
│       │   └── wizards.py       # Wizards multi-paso
│       └── themes/              # Estilos y colores
│           └── colors.py        # Paleta de colores, iconos
│
├── tests/                       # 🧪 TESTING
│   ├── cli/                     # Tests de tu código Python
│   └── generated/               # Tests de integración (¿Se generó bien?)
│
├── .dockerignore                # Exclusiones para la imagen del CLI
├── .gitignore
├── pyproject.toml               # 📦 DEPENDENCIAS (Typer, Rich, Copier)
├── Dockerfile                   # 🏗️ IMAGEN DEL CLI (Docker-first)
├── Makefile                     # 🕹️ COMANDOS (make build, make create)
└── README.md                    # Manual de uso de TU herramienta
```

---

## 6. CICLO DE VIDA Y MANTENIMIENTO

**Requisito de Infraestructura:**

**Protocolo de Push:**
- NUNCA hagas `git push` manual solo a origin.
- Usa SIEMPRE el comando estandarizado `make stable`.
- Este comando sincroniza ambos remotos automáticamente.

### 📦 Gestión de Imágenes (Nexus Registry)
Para optimizar tiempos de despliegue y garantizar la inmutabilidad de los entornos, este servicio se adhiere al siguiente flujo de trabajo con el registro local Nexus:

1.  **Desarrollo**: Los cambios se construyen localmente.
2.  **Publicación**: Una vez validada, la imagen DEBE subirse al registro local (`nexus.edugonmor.com/repository/docker-hosted`).
3.  **Producción**: El despliegue final (`docker-compose up`) DEBE consumir la imagen desde el registro, no construirla en tiempo de ejecución.

### 🛡️ Política de Backups (Rclone Centralizado - edugonmor_rclone)
La persistencia de datos de este servicio está protegida mediante el sistema centralizado de backups (**edugonmor_rclone**).

*   **Alcance**: Todos los volúmenes persistentes (archivos y bases de datos) deben ser accesibles por el contenedor central de Rclone.
*   **Mecanismo**: Los volúmenes se montan en modo lectura (`:ro`) en el servicio de backup central.
*   **Frecuencia**: Las copias se realizan y sincronizan con la nube automáticamente según la política global del proyecto.


## 7. POLÍTICAS ESPECÍFICAS

### 🛡️ Política de Makefile
No se debe añadir en Makefile ningún comando que se pueda ejecutar en una sola linea. Si no que para añadirse aqui debe ser una concatenación o tener algo programático para que merezca la pena estar en makefile.

### 🔌 Política de Conectividad (SSH Obligatorio)
Esta herramienta CLI está diseñada **exclusivamente** para operar en entornos remotos.
- **Prohibido el modo local:** No se debe implementar ninguna funcionalidad que permita ejecutar comandos sin una conexión SSH establecida.
- **Objetivo:** La herramienta no tiene como objetivo realizar acciones en la máquina física donde se ejecuta el contenedor, sino orquestar despliegues y configuraciones en servidores remotos.
- **Wizard:** El wizard de conexión SSH es un paso obligatorio en el flujo de ejecución.
