# Paso 8 — Conectar el agente a las tools

> Paso 8 de 11 · [Índice del workshop](../../README.md)

Ahora equipamos al agente con las tools del MCP Toolbox.

## 8.1 El agente completo

Reemplazá `hotel_agent_app/agent.py` por esto ([`files/agent.py`](files/agent.py)):

```python
import os

# gemini-3.5-flash sólo existe en la location `global`. Local esto lo resuelve
# el .env, pero en Cloud Run el Dockerfile que genera ADK sobrescribe la
# variable con la región del servicio, así que la fijamos también acá.
# Detalle completo en docs/troubleshooting.md
os.environ['GOOGLE_CLOUD_LOCATION'] = 'global'

from google.adk.agents import Agent
from toolbox_core import ToolboxSyncClient

# Local: http://127.0.0.1:5000  (o el puerto que hayas usado)
# Cloud Run: la Service URL del paso 9, por ejemplo
#            https://toolbox-xxxxxxxx-uc.a.run.app
TOOLBOX_URL = os.environ.get('TOOLBOX_URL', 'http://127.0.0.1:5000')

toolbox = ToolboxSyncClient(TOOLBOX_URL)

# Una sola tool:
# tools = [toolbox.load_tool('search-hotels-by-location')]

# Todas las tools del toolset:
tools = toolbox.load_toolset('my_first_toolset')

root_agent = Agent(
    name='hotel_agent',
    model='gemini-3.5-flash',
    description=(
        'Agent to answer questions about hotels by name, by city or by country '
        'in Argentina, Uruguay and Chile.'
    ),
    instruction=(
        'You are a helpful agent who can answer user questions about hotels in '
        'Argentina, Uruguay and Chile. You can search by hotel name, by city or '
        'by country. Always use the tools to answer; never invent hotels. '
        'Answer in the same language the user writes in.'
    ),
    tools=tools,
)
```

Tres decisiones que vale la pena explicar:

- **`load_toolset('my_first_toolset')`** trae las tres tools de una. Si querés mostrar el caso de una sola, está la línea comentada con `load_tool`.
- **`TOOLBOX_URL` por variable de entorno** es un cambio respecto del codelab original, que hardcodea la URL y te hace editar el código entre local y Cloud Run. Así no editás nada: `export TOOLBOX_URL=https://...` y listo.
- **`os.environ['GOOGLE_CLOUD_LOCATION']`** es para que el deploy del paso 9 no vuelva a `us-central1`. Ver [T3](../../docs/troubleshooting.md#t3-en-cloud-run-el-modelo-vuelve-a-us-central1).

Y lo que **no** hay: ni SQL, ni credenciales, ni cliente de Postgres. Todo eso vive en el `tools.yaml`.

## 8.2 Probar

**Terminal 1** — el Toolbox, desde `mcp-toolbox`:

```bash
./toolbox --config "tools.yaml"
```

**Terminal 2** — el agente, desde `my-agents` con el venv activo:

```bash
adk run hotel_agent_app/
```

Una conversación de ejemplo:

```
Running agent hotel_agent, type exit to exit.
[user]: ¿qué podés hacer?
[hotel_agent]: Puedo buscar hoteles por nombre, por ciudad o por país en
Argentina, Uruguay y Chile.
[user]: ¿qué hoteles hay en Mendoza?
[hotel_agent]: En Mendoza tengo estas opciones, de menor a mayor precio:

*   Hotel Argentino Mendoza (Midscale)
*   Diplomatic Hotel Mendoza (Upscale)
*   Park Hyatt Mendoza (Luxury)
[user]: ¿y en Uruguay?
[hotel_agent]: En Uruguay hay 6 hoteles, por ciudad:

Colonia del Sacramento: Charco Hotel (Upscale)
Montevideo: Ibis Montevideo (Midscale), Radisson Montevideo (Upper Upscale),
            Sofitel Montevideo Casino Carrasco (Luxury)
Punta del Este: Enjoy Punta del Este (Upper Upscale), Hotel Fasano Las Piedras (Luxury)
```

Los datos y el orden salen de la base: ese `Midscale → Upscale → Luxury` es el `ORDER BY CASE` del `tools.yaml`, no una decisión del modelo.

También funciona con `adk web --allow_origins '*'`, donde además podés abrir la pestaña de eventos y ver **qué tool eligió, con qué parámetros y qué devolvió**. Para un workshop, eso es lo que mejor muestra la idea.

![La pestaña de eventos con la llamada a search-hotels-by-location y su respuesta](../../img/08-adk-web-tool-call.png)

> 📸 *Imagen provisoria del codelab original. Captura pendiente: `img/08-adk-web-tool-call.png` — la pestaña de eventos con la llamada a `search-hotels-by-location` y su respuesta.*

## 8.3 Cosas para probar en vivo

| Pregunta | Qué demuestra |
|---|---|
| `¿qué hoteles hay en Bariloche?` | Elección de tool por ciudad |
| `contame del Llao Llao` | `search-hotels-by-name` con match parcial |
| `¿qué opciones tengo en Chile?` | `search-hotels-by-country`, agrupado por ciudad |
| `¿cuál es el más barato de Buenos Aires?` | El modelo razona sobre el resultado ya ordenado por SQL |
| `¿qué hoteles hay en Tokio?` | No hay datos: el agente lo dice en lugar de inventar |

La última es la más interesante para mostrar por qué la instrucción dice *"never invent hotels"*.

## 8.4 Cambiar una query sin tocar el agente

Demostración de un minuto que deja claro el valor del Toolbox:

1. Editá el `ORDER BY` de `search-hotels-by-location` en `tools.yaml` para invertir el orden (de más caro a más barato).
2. Reiniciá **sólo** el Toolbox.
3. Volvé a preguntar por Mendoza en el agente, que **no se reinició ni se modificó**.

El resultado cambia. Eso es el control plane del que habla la documentación.

---

[← Paso 7](../07-agente-adk/README.md) · [Índice](../../README.md) · [Paso 9: Deploy a Cloud Run →](../09-cloud-run/README.md)
