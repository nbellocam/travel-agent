# Travel Agent con MCP Toolbox for Databases y ADK

Workshop práctico: construir un agente que responde preguntas sobre hoteles consultando una base de datos real, sin una sola línea de SQL en el código del agente.

> **Basado en el codelab oficial de Google** [*Build a Travel Agent using MCP Toolbox for Databases and Agent Development Kit (ADK)*](https://codelabs.developers.google.com/travel-agent-mcp-toolbox-adk).
>
> Esta versión lo actualiza a **septiembre de 2026** (versiones, herramientas y varios errores que el original todavía no contempla) y reemplaza el dataset suizo original por hoteles de **Argentina, Uruguay y Chile**. El detalle de cada cambio está en [Qué cambió respecto del original](#qué-cambió-respecto-del-original).

![Arquitectura del workshop](img/arquitectura.svg)

## Qué vas a construir

| Pieza | Rol |
|---|---|
| **Cloud SQL para PostgreSQL** | La base con la tabla `hotels` y 32 hoteles de la región |
| **MCP Toolbox for Databases** | Servidor que expone consultas SQL como *tools* MCP, definidas en un `tools.yaml` |
| **Un CLI con agente** | Antigravity CLI, Claude Code o Codex consumiendo esas tools sin escribir código |
| **Un agente con ADK** | Tu propio agente en Python, usando las mismas tools |
| **Cloud Run** (opcional) | Las dos piezas publicadas como servicios |

La idea de fondo: el acceso a datos se define **una vez**, en el `tools.yaml`, y se consume desde cualquier cliente MCP. Cambiás una query y no hay que redeployar ningún agente.

## Requisitos

- Un proyecto de Google Cloud con facturación habilitada.
- **Cloud Shell** (recomendado: ya trae `gcloud` y Python) o un entorno local con `gcloud` y **Python 3.10+**.
- Para el paso 6, al menos uno de: [Antigravity CLI](https://antigravity.google/docs/getting-started?tab=cli), [Claude Code](https://claude.com/claude-code) o [Codex CLI](https://developers.openai.com/codex).
- Duración estimada: **60-90 minutos** (la instancia de Cloud SQL sola tarda 3-5 minutos en crearse).

## Los pasos

| # | Paso | Qué hacés |
|---|---|---|
| 1 | [Introducción](steps/01-introduccion/README.md) | Qué es MCP, qué es el Toolbox y por qué no va SQL en el agente |
| 2 | [Preparar el proyecto](steps/02-preparar-proyecto/README.md) | `gcloud`, proyecto y APIs |
| 3 | [Crear la instancia de Cloud SQL](steps/03-cloud-sql/README.md) | PostgreSQL 15 en `us-central1` |
| 4 | [Preparar la base de hoteles](steps/04-base-de-datos/README.md) | Esquema + 32 hoteles de AR/UY/CL |
| 5 | [Setup del MCP Toolbox](steps/05-mcp-toolbox/README.md) | Binario, `tools.yaml`, 3 tools y la UI |
| 6 | [Usar las tools desde un CLI](steps/06-cli-agentes/README.md) | `agy`, Claude Code o Codex |
| 7 | [Escribir el agente con ADK](steps/07-agente-adk/README.md) | `adk create`, `adk web`, `adk run` |
| 8 | [Conectar el agente a las tools](steps/08-conectar-tools/README.md) | `toolbox-core` y el toolset completo |
| 9 | [Deploy a Cloud Run](steps/09-cloud-run/README.md) *(opcional)* | Las dos piezas en la nube |
| 10 | [Limpieza](steps/10-limpieza/README.md) | Borrar todo para no pagar de más |
| 11 | [Cierre](steps/11-cierre/README.md) | Qué te llevás y por dónde seguir |

➡️ **Empezá por el [Paso 1](steps/01-introduccion/README.md).**

## Si algo falla

Todo lo que se rompió durante la preparación de este workshop está documentado con causa y solución en **[docs/troubleshooting.md](docs/troubleshooting.md)**:

| Síntoma | Dónde |
|---|---|
| `adk web` en Cloud Shell: página en blanco, `403` en todos los `.js` | [T1](docs/troubleshooting.md#t1-adk-web-en-cloud-shell-página-en-blanco-y-403-en-los-js) |
| `404 NOT_FOUND: Publisher model ... was not found` | [T2](docs/troubleshooting.md#t2-404-not_found-publisher-model--was-not-found) |
| El deploy a Cloud Run funciona local y falla en la nube con el mismo 404 | [T3](docs/troubleshooting.md#t3-en-cloud-run-el-modelo-vuelve-a-us-central1) |
| `Error: no such option: --env` | [T4](docs/troubleshooting.md#t4-error-no-such-option---env) |
| La revisión de Cloud Run queda en *Provisioning* para siempre | [T5](docs/troubleshooting.md#t5-la-revisión-de-cloud-run-nunca-queda-ready) |
| `pip install google-adk` te deja una versión vieja | [T6](docs/troubleshooting.md#t6-pip-install-google-adk-me-dejó-una-versión-vieja) |
| En macOS el Toolbox en el puerto 5000 devuelve `403` | [T7](docs/troubleshooting.md#t7-macos-el-puerto-5000-devuelve-403) |

## Versiones fijadas

Verificadas el **21-22 de septiembre de 2026**. Si seguís el workshop mucho después, chequealas.

| Componente | Versión |
|---|---|
| MCP Toolbox for Databases | `1.12.0` |
| `google-adk` | `2.9.2` |
| `toolbox-core` | `1.4.0` |
| Modelo | `gemini-3.5-flash` (location `global`) |
| Cloud SQL | PostgreSQL 15, tier `db-g1-small` |
| Python | 3.10+ |

> ⚠️ **Sobre ADK**: usá **2.9.0 o superior**. Las versiones anteriores no tienen el flag `--env` en `adk deploy cloud_run` y deployan siempre contra una feature beta de Cloud Run que puede dejar la revisión colgada. Ver [T4](docs/troubleshooting.md#t4-error-no-such-option---env) y [T5](docs/troubleshooting.md#t5-la-revisión-de-cloud-run-nunca-queda-ready).

## Qué cambió respecto del original

| Paso | Cambio |
|---|---|
| 4 | **Dataset nuevo**: 32 hoteles de Argentina, Uruguay y Chile en 13 ciudades, con columna `country` (el original tenía 10 hoteles suizos) y fechas de octubre de 2026 |
| 5 | MCP Toolbox `1.1.0` → **`1.12.0`**. Tercera tool `search-hotels-by-country` para aprovechar el dataset regional |
| 6 | **Reescrito**: Gemini CLI se retiró el 18/06/2026 → Antigravity CLI (`agy`), con alternativas Claude Code y Codex |
| 7 | ADK 2.x: nuevo diálogo de `adk create`, `GOOGLE_GENAI_USE_ENTERPRISE`, modelo `gemini-3.5-flash` con location `global`, y `adk web` necesita `--allow_origins` en Cloud Shell |
| 8 | Modelo nuevo y `TOOLBOX_URL` por variable de entorno, para no editar el código entre local y Cloud Run |
| 9 | Región de Cloud Run y location del modelo **separadas**, y la location forzada dentro del contenedor |
| — | Sección de troubleshooting con 7 problemas reales, cada uno con su causa verificada |

## Estructura del repo

```
.
├── README.md                     este archivo
├── docs/troubleshooting.md       los 7 problemas y sus soluciones
├── img/arquitectura.svg          el diagrama de arriba
└── steps/
    ├── 01-introduccion/          … 11 carpetas, una por paso
    ├── 04-base-de-datos/sql/     01-schema.sql, 02-seed.sql, 03-consultas.sql
    ├── 05-mcp-toolbox/files/     tools.yaml
    ├── 07-agente-adk/files/      agent.py, __init__.py, .env.example
    └── 08-conectar-tools/files/  agent.py, requirements.txt
```

Cada carpeta de paso tiene su `README.md` y, cuando corresponde, los archivos listos para copiar. Podés copiarlos y pegarlos tal cual: el único valor a reemplazar es `YOUR_PROJECT_ID` en el `tools.yaml` y en el `.env`.

## Sobre los datos de ejemplo

Los nombres de los hoteles son reales para que el workshop se sienta familiar, pero **todo el resto del dato es ficticio**: categorías, fechas y disponibilidad están inventadas para la demo y no representan información de ningún establecimiento.

## Créditos

Material original: [Google Codelabs](https://codelabs.developers.google.com/travel-agent-mcp-toolbox-adk), bajo su propia licencia. Esta adaptación mantiene la estructura y los objetivos del codelab, actualiza las herramientas y regionaliza el contenido para **[Nerdearla](https://nerdear.la/)**.

Documentación de referencia:

- [MCP Toolbox for Databases](https://github.com/googleapis/mcp-toolbox) · [releases](https://github.com/googleapis/mcp-toolbox/releases)
- [Agent Development Kit](https://google.github.io/adk-docs/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
