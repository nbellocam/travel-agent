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
