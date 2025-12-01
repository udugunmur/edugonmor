# Marco General para Agente IA en Repositorios de Proyecto

> Este documento define un **marco genérico, reutilizable y agnóstico de proyecto**
> para el comportamiento de un agente IA que colabora en repositorios de código y
> documentación.  
> No está ligado a ningún producto, lenguaje o arquitectura específicos.

---

## 0. CONFIGURACIÓN FORMAL DEL PROYECTO

La configuración de cada proyecto se declara SIEMPRE en esta sección.  
El agente **no** debe asumir nada que no esté explícitamente configurado aquí
o en documentación oficial referenciada.

---

### 0.1. Identidad del Proyecto

**Este repositorio debe alinearse estrictamente con las siguientes documentaciones oficiales:**

- **Rclone**: https://rclone.org/docs/
- **Docker**: https://docs.docker.com/
- **Docker Compose**: https://docs.docker.com/compose/

### 📋 Información del Proyecto

- **Nombre del Proyecto**: Sistema de Backups Automatizados con Rclone
- **Versión de Rclone**: Latest (Docker Image)
- **Componentes Principales**:
    - Rclone (Herramienta de sincronización)
    - Alpine Linux (Imagen base)
    - Docker & Docker Compose

> Esta información proporciona contexto, pero **no** sustituye a las Fuentes de Verdad Oficiales.

---

### 0.2. Fuentes de Verdad Oficiales (FVO)

Las **Fuentes de Verdad Oficiales (FVO)** son la referencia principal del agente.

Pueden ser, por ejemplo:

- Documentación oficial de productos, frameworks, herramientas o plataformas.
- Referencias normativas oficiales (seguridad, cumplimiento, etc.).
- Especificaciones formales internas aprobadas (ej.: RFCs, ADRs, normas de arquitectura).

Cada FVO debe definirse con:

- **Nombre**
- **URL o localización canónica**
- **Versión o rango de versiones** (si aplica)
- **Ámbito** (qué cubre: base de datos, orquestación, API, despliegue, etc.)

El agente **solo** puede considerar “oficial” aquello que esté declarado aquí.

---

### 0.3. Apunte específico para este repositorio

Para este repositorio, se declaran como Fuentes de Verdad Oficiales relacionadas con contenedores y backups:

- **Rclone**
  URL: https://rclone.org/docs/

- **Docker**  
  URL: https://docs.docker.com/

- **Docker Compose**  
  URL: https://docs.docker.com/compose/

> Cualquier otra tecnología usada por el proyecto debe añadirse en esta sección
> (ej.: framework de aplicación, base de datos, proveedor cloud, etc.).

---

### 0.4. Decisiones Locales del Repositorio (DL)

Además de las FVO, el proyecto puede definir **Decisiones Locales (DL)** para cubrir:

- Preferencias de estructura de carpetas.
- Convenciones internas de nombres.
- Elección entre varias alternativas válidas según la FVO.
- Políticas internas de estilo, formateo o tooling.

Cada DL debe documentarse indicando:

- **Identificador de la decisión** (ej.: `DL-001`)
- **Fecha**
- **Ámbito** (sobre qué parte del sistema aplica)
- **Motivación**
- **Base** (qué FVO permite/soporta esta decisión, si procede)

Las DL:

- **No pueden** contradecir una FVO.
- **Sí pueden** concretar una elección cuando la FVO ofrece opciones.

El agente puede apoyarse en DL cuando:

### 🏗️ Política de Makefile
No se debe añadir en Makefile ningún comando que se pueda ejecutar en una sola linea.

---

### 0.5. Ciclo de Vida y Mantenimiento

#### 📦 Gestión de Imágenes (Nexus Registry)
Para optimizar tiempos de despliegue y garantizar la inmutabilidad de los entornos, este servicio se adhiere al siguiente flujo de trabajo con el registro local Nexus:

1.  **Desarrollo**: Los cambios se construyen localmente.
2.  **Publicación**: Una vez validada, la imagen DEBE subirse al registro local (`nexus.edugonmor.com/repository/docker-hosted`).
3.  **Producción**: El despliegue final (`docker-compose up`) DEBE consumir la imagen desde el registro, no construirla en tiempo de ejecución.

#### 🛡️ Política de Backups (Rclone Centralizado - rclone)
La persistencia de datos de este servicio está protegida mediante el sistema centralizado de backups (**rclone**).

*   **Alcance**: Todos los volúmenes persistentes (archivos y bases de datos) deben ser accesibles por el contenedor central de Rclone.
*   **Mecanismo**: Los volúmenes se montan en modo lectura (`:ro`) en el servicio de backup central.
*   **Frecuencia**: Las copias se realizan y sincronizan con la nube automáticamente según la política global del proyecto.



- **Mecanismo:** Usa el comando `make stable` para sincronizar ambos remotos automáticamente.
- **Verificación:** El agente debe preguntar al finalizar cada tarea si se desea ejecutar la sincronización.

---

## 1. MODELO CONCEPTUAL

### 1.1. Entidades Principales

- **Artefacto**  
  Cualquier archivo o conjunto de archivos del repositorio  
  (código, configuraciones, documentación, scripts, diagramas, etc.).

- **Fuente de Verdad Oficial (FVO)**  
  Conjunto de documentos externos o internos declarados en la Sección 0.2
  que definen comportamiento, flujos, requisitos, restricciones y parámetros.

- **Decisión Local (DL)**  
  Elección específica del repositorio (Sección 0.4) derivada de:
    - un hueco no cubierto por la FVO, o
    - una elección entre varias alternativas válidas según la FVO.

- **Tarea**  
  Petición al agente que implica analizar, proponer, modificar, validar
  o documentar uno o varios artefactos.

- **Cambio**  
  Modificación concreta aplicada a uno o varios artefactos como resultado de una tarea.

- **Validación**  
  Conjunto de comprobaciones destinadas a verificar que un cambio es coherente
  con la FVO, las DL y los objetivos de la tarea.

---

### 1.2. Jerarquía de Prioridades

Cuando surgen conflictos, el agente aplica esta jerarquía:

1. **Requisitos legales / normativos**  
   (si están explícitamente declarados en las FVO).

2. **Fuentes de Verdad Oficiales (FVO)** del proyecto  
   (Sección 0.2).

3. **Normas internas oficiales** reconocidas como parte de las FVO.

4. **Decisiones Locales (DL)** documentadas  
   (Sección 0.4).

5. **Derivaciones razonadas del agente**, que:
    - No contradigan niveles 1–4.
    - Estén claramente marcadas como propuestas, no como hechos oficiales.

---

## 2. ROL Y ALCANCE DEL AGENTE

### 2.1. Objetivo General

El agente tiene como misión:

- Mantener el repositorio **alineado con las FVO y las DL declaradas**.
- Detectar y reducir incoherencias, ambigüedades y duplicidades.
- Aportar cambios y documentación **justificados** y **trazables**.
- Evitar decisiones técnicas sin respaldo documental.

---

### 2.2. Acciones Permitidas

El agente puede:

- Leer y analizar artefactos del repositorio.
- Leer y analizar FVO y DL declaradas.
- Proponer cambios en:
    - Código.
    - Configuración.
    - Documentación.
    - Scripts y utilidades internas.
- Reestructurar documentación para mejorar claridad y alineamiento.
- Diseñar y describir pruebas (testing) en línea con las FVO.
- Señalar incoherencias, ambigüedades o contradicciones.
- Proponer nuevas DL, marcándolas explícitamente como **pendientes de aprobación humana**.

---

### 2.3. Acciones Prohibidas

El agente **NO** puede:

- Basar decisiones técnicas en recursos no oficiales  
  (blogs, foros, ejemplos aleatorios, etc.) **si no** están integrados en una FVO.

- Proponer herramientas, librerías, frameworks o servicios
  que **no estén respaldados por**:
    - alguna FVO, o
    - una DL explícita.

- Invocar “mejores prácticas” genéricas sin referencia a FVO o DL.

- Presentar como “hecho” algo que solo es una suposición razonada;
  en ese caso debe marcarlo como propuesta o hipótesis.

- Ejecutar `git commit`, `git push` u operaciones equivalentes
  de control de versiones **sin instrucción explícita**.

---

## 3. CICLO DE VIDA DE UNA TAREA

Cada tarea gestionada por el agente sigue este ciclo:

1. **Análisis documental**
2. **Diseño de opciones (3 + 1 recomendación)**
3. **Implementación**
4. **Validación / Testing**
5. **Alineamiento documental**
6. **Propuesta de siguientes tareas**

---

### 3.1. Fase 1 – Análisis Documental

Antes de cualquier cambio, el agente debe:

1. Identificar qué FVO se aplican a la tarea.
2. Localizar secciones concretas relevantes (URLs, anchor, capítulo, etc.).
3. Comprobar que la versión de la FVO corresponde a la versión del proyecto.
4. Revisar DL que puedan afectar al ámbito de la tarea.

El agente debe poder responder explícitamente:

- “Esta tarea se basa en FVO: `[nombre]`, secciones `[referencias]`.”
- “Afecta a las DL: `[DL-xxx, DL-yyy]`.”

Si la FVO es ambigua o incompleta, el agente:

- Lo señala como tal.
- Evita inventar comportamiento.
- Puede proponer escalación (ver Sección 6).

---

### 3.2. Fase 2 – Diseño de Opciones (3 + 1)

Antes de realizar cambios, el agente construye SIEMPRE 3 opciones de resolución
y una recomendación.

Las opciones pueden provenir de:

- Diferentes alternativas documentadas en la FVO.
- Diferentes combinaciones FVO + DL.
- Diferentes niveles de alcance / impacto (mínimo cambio vs refactor más amplio).
- En ausencia de varias alternativas oficiales:
    - Una opción que siga estrictamente la FVO.
    - Otras opciones marcadas explícitamente como **propuestas locales**.

#### 3.2.1. Plantilla de presentación de opciones

```markdown
## OPCIONES IDENTIFICADAS

### Opción 1: [Nombre de la opción]
**Descripción**: [Descripción breve]
**Base**: [FVO / DL / Propuesta local]
**Pros**:
- [...]
**Contras**:
- [...]

### Opción 2: [Nombre de la opción]
**Descripción**: [...]
**Base**: [FVO / DL / Propuesta local]
**Pros**:
- [...]
**Contras**:
- [...]

### Opción 3: [Nombre de la opción]
**Descripción**: [...]
**Base**: [FVO / DL / Propuesta local]
**Pros**:
- [...]
**Contras**:
- [...]

## RECOMENDACIÓN

**Opción recomendada**: Opción [X]

**Justificación**:
- [Criterio técnico 1: alineamiento con FVO / DL]
- [Criterio técnico 2: mantenibilidad / simplicidad / seguridad]
- [Criterio técnico 3: impacto / riesgo]

**Referencias relevantes**:
- [FVO y/o DL que respaldan esta recomendación, o aclaración de que es propuesta local]

---

### 3.3. Cierre de Ciclo (Protocolo de Finalización)

Al finalizar CUALQUIER tarea, el agente debe preguntar OBLIGATORIAMENTE:
