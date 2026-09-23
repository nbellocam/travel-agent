# Capturas del workshop

Por ahora, casi todos los PNG de esta carpeta son **imágenes provisorias tomadas del [codelab original](https://codelabs.developers.google.com/travel-agent-mcp-toolbox-adk)**: muestran el dataset suizo, Gemini CLI en vez de `agy`, etc. Cada paso las marca con un bloque `📸 *Imagen provisoria del codelab original. Captura pendiente: ...*`.

Para actualizar una: sobrescribí el PNG con el mismo nombre y borrá el bloque `📸` que está debajo de la imagen en el paso. La única que falta del todo es `09-toolbox-cloudrun.png` (el original no tenía una equivalente): ahí el paso 9 todavía tiene sólo el texto `📸 *Captura sugerida: ...*`, así que además de agregar el PNG hay que insertar la línea `![...](../../img/09-toolbox-cloudrun.png)`.

## Checklist

| Archivo | Paso | Qué mostrar | Estado |
|---|---|---|---|
| `02-cloudshell.png` | 2 | Cloud Shell con la salida de `gcloud config list project` | ⏳ provisoria (original) |
| `03-instancia-runnable.png` | 3 | `gcloud sql instances list` con estado `RUNNABLE` | ⏳ provisoria (original) |
| `04-cloudsql-studio-login.png` | 4 | El login de Cloud SQL Studio | ⏳ provisoria (original) |
| `04-select-hotels.png` | 4 | El `SELECT * FROM hotels` con las 32 filas | ⏳ provisoria (original) |
| `05-toolbox-ui.png` | 5 | La UI del Toolbox ejecutando `search-hotels-by-location` con `Mendoza` | ⏳ provisoria (original) |
| `06-agy-mcp.png` | 6 | El MCP Manager de `agy` con MCPToolbox conectado | ⏳ provisoria (original) |
| `07-adk-web.png` | 7 | La UI de ADK respondiendo, antes de tener tools | ⏳ provisoria (original) |
| `08-adk-web-tool-call.png` | 8 | La pestaña de eventos con la llamada a la tool y su respuesta | ⏳ provisoria (original) |
| `09-toolbox-cloudrun.png` | 9 | El servicio `toolbox` en la consola de Cloud Run | ❌ falta |
| `09-hotels-service.png` | 9 | El agente corriendo en Cloud Run | ⏳ provisoria (original) |

## Ya incluido

- `arquitectura.svg` — el diagrama del README y del paso 1. Es un SVG editable a mano, sin dependencias.

## Sugerencias

- Recortá al área útil: las capturas de consola completas se leen mal en el README.
- Si la captura muestra tu project ID, no pasa nada grave, pero tapalo si preferís.
- PNG para capturas de pantalla; el SVG queda para diagramas.
