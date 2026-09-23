# Troubleshooting

Todos estos problemas aparecieron de verdad preparando el workshop, en Cloud Shell y en macOS, entre el 21 y el 22 de septiembre de 2026. Cada uno tiene la causa verificada, no una conjetura.

> Si el workshop es tuyo y lo vas a dar en vivo: **T1, T2 y T6 son los que te van a pasar seguro**. Los otros aparecen recién en el paso 9.

| | Síntoma | Aparece en |
|---|---|---|
| [T1](#t1-adk-web-en-cloud-shell-página-en-blanco-y-403-en-los-js) | `adk web` en Cloud Shell: página en blanco y `403` en los `.js` | Paso 7 |
| [T2](#t2-404-not_found-publisher-model--was-not-found) | `404 NOT_FOUND: Publisher model ... was not found` | Paso 7 |
| [T3](#t3-en-cloud-run-el-modelo-vuelve-a-us-central1) | En Cloud Run el modelo vuelve a `us-central1` | Paso 9 |
| [T4](#t4-error-no-such-option---env) | `Error: no such option: --env` | Paso 9 |
| [T5](#t5-la-revisión-de-cloud-run-nunca-queda-ready) | La revisión de Cloud Run nunca queda `Ready` | Paso 9 |
| [T6](#t6-pip-install-google-adk-me-dejó-una-versión-vieja) | `pip install google-adk` me dejó una versión vieja | Paso 7 |
| [T7](#t7-macos-el-puerto-5000-devuelve-403) | macOS: el puerto 5000 devuelve `403` | Paso 5 |

---

## T1. adk web en Cloud Shell: página en blanco y 403 en los .js

**Síntoma.** Levantás `adk web`, abrís el Web Preview y la página queda en blanco. En el log, un patrón muy característico: el HTML, el CSS y el favicon dan `200 OK` y **todos los `.js` dan `403 Forbidden`**.

```
INFO:  127.0.0.1:53910 - "GET /dev-ui/ HTTP/1.1" 200 OK
INFO:  127.0.0.1:53910 - "GET /dev-ui/styles-4R3GDHUZ.css HTTP/1.1" 200 OK
INFO:  127.0.0.1:53922 - "GET /dev-ui/chunk-PDRDFWTH.js HTTP/1.1" 403 Forbidden
INFO:  127.0.0.1:53952 - "GET /dev-ui/main-GL7MLWNX.js HTTP/1.1" 403 Forbidden
INFO:  127.0.0.1:53932 - "GET /dev-ui/adk_favicon.svg HTTP/1.1" 200 OK
```

**Causa.** ADK 2.x incorporó un middleware ASGI (`_OriginCheckMiddleware`, en `google/adk/cli/api_server.py`) con protección anti DNS-rebinding. Si el server está bindeado a loopback y no configuraste orígenes permitidos, exige que el header `Origin` de cada request también sea de loopback. El Web Preview sirve la página desde `https://8000-....cloudshell.dev`, que no es loopback.

¿Y por qué **sólo** los `.js`? Porque la UI de ADK es una app Angular que carga con `<script type="module">`, y los módulos ES **siempre se piden en modo CORS**, o sea con header `Origin`. En cambio `<link rel="stylesheet">` y `<img>` se piden en modo *no-cors*, **sin** `Origin`. El middleware sólo rechaza lo que trae un `Origin` ajeno. Sin JavaScript, la página queda en blanco.

El wheel de `google-adk==1.39.1` no tiene ese middleware: por eso el codelab original funcionaba y hoy no.

**Solución.**

```bash
adk web --allow_origins '*'
```

Es la única variante que funciona en Cloud Shell. El `*` es un caso especial en el código: además de aceptar cualquier `Origin`, es el único valor que desactiva también el guard de `Host` (`_get_allowed_request_hosts` devuelve `None`). Cualquier otro valor deja al menos uno de los dos guards activo y el proxy del Web Preview choca con alguno.

| Comando | En Cloud Shell |
|---|---|
| `adk web --allow_origins '*'` | ✅ Funciona |
| `adk web` | 🔴 `403 origin not allowed` |
| `adk web --allow_origins "<origen del preview>"` | 🔴 No alcanza contra el proxy real |
| `adk web --allow_origins 'regex:https://.*\.cloudshell\.dev'` | 🔴 Una entrada `regex:` no avala ningún host → `host not allowed` |
| `adk web --host 0.0.0.0` | 🔴 El proxy termina TLS; el origen calculado queda en `http://` y no matchea el `https://` del browser |

**Qué implica el `*`.** Desactiva la protección anti DNS-rebinding de un servidor de desarrollo que además no tiene autenticación. En Cloud Shell el riesgo es acotado, porque el puerto se expone sólo a través del Web Preview, detrás de tu sesión autenticada de Google. No uses el flag en una máquina en red compartida ni con datos que no sean de demo.

**Para diagnosticar**, el cuerpo del 403 dice cuál de los dos guards te frenó:

```bash
curl -H "Origin: https://ejemplo.cloudshell.dev" http://127.0.0.1:8000/dev-ui/main-GL7MLWNX.js
# → Forbidden: origin not allowed   |   Forbidden: host not allowed
```

**Plan B**: `adk run hotel_agent_app` corre el agente entero en la terminal, sin browser ni middleware. Para demostrar las tools alcanza perfecto.

---

## T2. 404 NOT_FOUND: Publisher model ... was not found

**Síntoma.** La UI carga, mandás el primer mensaje y el agente responde con un error:

```
errorCode: "NOT_FOUND"
errorMessage: "404 NOT_FOUND. {'error': {'code': 404, 'message': 'Publisher model
  `projects/YOUR_PROJECT/locations/us-central1/publishers/google/models/gemini-3.5-flash`
  was not found or your project does not have access to it. ...', 'status': 'NOT_FOUND'}}"
```

**Causa.** El modelo no está disponible en la **location** configurada. Los Gemini 3.x se sirven desde el endpoint `global`, no desde las regiones individuales. Fijate en el mensaje: dice `locations/us-central1`.

**Matriz verificada** con llamadas reales a `:generateContent`:

| Modelo | `us-central1` | `global` |
|---|---|---|
| `gemini-3.5-flash` | 🔴 404 | ✅ 200 |
| `gemini-flash-latest` | 🔴 404 | ✅ 200 |
| `gemini-2.5-flash` | ✅ 200 | ✅ 200 |
| `gemini-2.5-pro` | ✅ 200 | ✅ 200 |
| `gemini-2.5-flash-lite` | ✅ 200 | ✅ 200 |
| `gemini-3-flash` / `gemini-3-pro` | 🔴 404 | 🔴 404 |
| `gemini-2.0-flash` | 🔴 404 | 🔴 404 |

**Solución.** En `hotel_agent_app/.env`, location en `global`:

```
GOOGLE_GENAI_USE_ENTERPRISE=1
GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID
GOOGLE_CLOUD_LOCATION=global
```

Cortá y relanzá `adk web` (el `.env` se lee al arrancar). Sólo afecta al endpoint del modelo: Cloud SQL y el Toolbox siguen en `us-central1`.

**Alternativa conservadora.** Si preferís no tocar la location, usá `model='gemini-2.5-flash'` con `GOOGLE_CLOUD_LOCATION=us-central1`. Funciona hoy, pero **`gemini-2.5-flash` se retira alrededor del 16-20 de octubre de 2026**.

**Chequeá qué tenés habilitado vos** (el acceso a modelos varía por proyecto; esto pide 1 token de salida):

```bash
TOK=$(gcloud auth print-access-token)
P=$(gcloud config get-value project)
B='{"contents":[{"role":"user","parts":[{"text":"hi"}]}],"generationConfig":{"maxOutputTokens":1}}'

for LOC in us-central1 global; do
  HOST=$([ "$LOC" = global ] && echo aiplatform.googleapis.com || echo "$LOC-aiplatform.googleapis.com")
  for M in gemini-3.5-flash gemini-2.5-flash gemini-flash-latest; do
    printf "%-12s %-20s " "$LOC" "$M"
    curl -s -o /dev/null -w "%{http_code}\n" -X POST \
      -H "Authorization: Bearer $TOK" -H "x-goog-user-project: $P" \
      -H "Content-Type: application/json" -d "$B" \
      "https://$HOST/v1/projects/$P/locations/$LOC/publishers/google/models/${M}:generateContent"
  done
done
```

`200` = disponible, `404` = no existe en esa location para tu proyecto.

> **Dos trampas de zsh** al armar este chequeo, que me costaron un diagnóstico falso: `${M}:generateContent` necesita las llaves, porque `$M:...` se interpreta como modificador de expansión; y zsh **no** hace word-splitting de variables sin comillas, así que `cmd $par` con dos palabras adentro pasa un solo argumento.

---

## T3. En Cloud Run el modelo vuelve a us-central1

**Síntoma.** Local funciona perfecto. Deployás a Cloud Run y el servicio te da el mismo `404 NOT_FOUND` de [T2](#t2-404-not_found-publisher-model--was-not-found), aunque tu `.env` diga `global`.

**Causa.** El Dockerfile que genera `adk deploy cloud_run` escribe `ENV GOOGLE_CLOUD_LOCATION=<region>`: **fuerza la location del modelo a la región de Cloud Run**. Y si tu `.env` trae `GOOGLE_CLOUD_LOCATION` mientras pasás `--region`, ADK lo ignora con un warning (`Ignoring GOOGLE_CLOUD_LOCATION in .env as --region was...`). O sea: **el `.env` no viaja al contenedor**. Verificado en ADK 2.6.2 y 2.9.2: las dos escriben ese `ENV`.

Encima, la región de Cloud Run y la location del modelo no pueden ser el mismo valor: Cloud Run necesita una región real, el modelo necesita `global`. Por eso el workshop usa dos variables separadas (`CLOUD_RUN_REGION` y `MODEL_LOCATION`) en lugar de la única `GOOGLE_CLOUD_LOCATION` del codelab original.

**Solución 1 — en el código del agente (funciona en cualquier versión de ADK).** Al principio de `agent.py`, antes de crear el `Agent`:

```python
import os

os.environ['GOOGLE_CLOUD_LOCATION'] = 'global'
```

Asignación directa, **no** `setdefault`: la variable ya viene seteada por el `ENV` del Dockerfile y hay que pisarla. Funciona porque el cliente de `google-genai` se construye recién en la primera request (`api_client` es un `cached_property`), así que lee el valor nuevo. Verificado en 2.6.2 y 2.9.2: el cliente resuelve `location: global` y `base_url: https://aiplatform.googleapis.com/` aunque el entorno diga `us-central1`. Es la opción que usa este workshop, porque viaja con el código.

**Solución 2 — flag `--env` (requiere ADK ≥ 2.9.0).**

```bash
adk deploy cloud_run ... --env GOOGLE_CLOUD_LOCATION=global hotel_agent_app/
```

Se traduce a `gcloud run deploy --update-env-vars`, que se aplica sobre el servicio y gana sobre el `ENV` de la imagen. Ver [T4](#t4-error-no-such-option---env) si el flag no existe en tu versión.

**Solución 3 — después del deploy.**

```bash
gcloud run services update hotels-service \
  --region=us-central1 \
  --update-env-vars GOOGLE_CLOUD_LOCATION=global
```

**Vía alternativa documentada por ADK** (está en el docstring de `google/adk/models/google_llm.py`), más explícita que mutar `os.environ`:

```python
from functools import cached_property
from google.adk.models import Gemini
from google.genai import Client

class GlobalGemini(Gemini):
  @cached_property
  def api_client(self) -> Client:
    return Client(vertexai=True, location="global")

root_agent = Agent(model=GlobalGemini(model="gemini-3.5-flash"), ...)
```

Verificada en 2.6.2 y 2.9.2.

---

## T4. Error: no such option: --env

**Causa.** El flag `--env` de `adk deploy cloud_run` **se agregó en `google-adk` 2.9.0**. Verificado wheel por wheel:

| Versión | `--env` |
|---|---|
| `1.39.1` | 🔴 No |
| `2.8.0` | 🔴 No |
| `2.9.0` | ✅ Sí |
| `2.9.2` | ✅ Sí |

**Solución.** Actualizá:

```bash
pip install -U google-adk
adk --version      # tiene que decir 2.9.2 o superior
```

Si el número no cambia, es [T6](#t6-pip-install-google-adk-me-dejó-una-versión-vieja).

Si no querés o no podés actualizar, usá la **solución 1 o 3** de [T3](#t3-en-cloud-run-el-modelo-vuelve-a-us-central1), que no dependen del flag.

---

## T5. La revisión de Cloud Run nunca queda Ready

**Síntoma.** `adk deploy cloud_run` se queda esperando para siempre en "Creating Revision". Borrás el servicio, lo volvés a crear, y lo mismo.

**Cómo confirmar qué está pasando** (esto vale para cualquier deploy trabado):

```bash
gcloud run services list --format="table(metadata.name,status.url,status.conditions[0].status)"

gcloud run revisions describe <REVISION> --region us-central1 \
  --format="yaml(status.conditions, spec.containers)"

# ¿el contenedor arrancó alguna vez?
gcloud logging read \
  'resource.type="cloud_run_revision" AND resource.labels.revision_name="<REVISION>"' \
  --limit 20 --freshness=1h --format="value(timestamp,textPayload)"
```

En el caso real que motivó esta entrada, la revisión mostraba:

```
ContainerReady    True     Container image import completed in 16.04s.
ContainerHealthy  Unknown
Ready             Unknown  The service has encountered an internal error. Please try again later
Retry             True     WaitingForOperation
```

y **cero logs de aplicación**: la imagen se construyó e importó bien, pero el contenedor nunca arrancó. Si no hay logs de aplicación, tu código no es el problema — nunca se ejecutó.

**Causa probable.** En el spec de la revisión aparecían `sandboxLauncher: true` y `launch-stage: BETA`. Salen de ADK: hasta las versiones 2.6.x, `cli_deploy.py` invoca **siempre** `gcloud beta run deploy ... --sandbox-launcher`, sin condición. En 2.9.x eso pasó a ser opt-in detrás de `--with_cloud_run_sandbox` (default `False`), y el track `beta` se usa sólo si lo pedís. O sea: las versiones viejas te deployan siempre contra una feature beta de Cloud Run.

**Solución.**

```bash
gcloud run services delete hotels-service --region us-central1 --quiet   # cortá el retry loop
pip install -U google-adk                                                # → 2.9.2
# y redeployás normalmente
```

Si no querés actualizar, generá las fuentes con ADK y deployá con `gcloud` a mano, sin beta ni sandbox:

```bash
adk deploy cloud_run ... --temp_folder ./deploy_src
gcloud run deploy hotels-service --source ./deploy_src --region us-central1 \
  --port 8000 --allow-unauthenticated \
  --set-env-vars GOOGLE_CLOUD_LOCATION=global,GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT,GOOGLE_GENAI_USE_VERTEXAI=True
```

> **Otra causa posible del mismo síntoma**, que conviene descartar: si `agent.py` sigue apuntando a `http://127.0.0.1:5000`, la línea `ToolboxSyncClient(...)` hace una llamada HTTP **en el import**, contra un localhost que dentro del contenedor no tiene nada. Ahí el arranque sí se cuelga por tu código — y, a diferencia del caso de arriba, **vas a ver logs de aplicación**. Por eso este workshop lee la URL de `TOOLBOX_URL`.

---

## T6. pip install google-adk me dejó una versión vieja

**Síntoma.** Seguiste los pasos, corriste `pip install google-adk`, y `adk --version` te devuelve algo viejo (por ejemplo `2.6.2`, del 4 de agosto de 2026) en lugar de la última.

**Causa.** No es caché de paquetes ni un límite de Python: todas las versiones 2.6→2.9.2 piden sólo Python ≥3.10 y ninguna está yanked, así que un `pip install` limpio resuelve la última. Lo que pasa es que **el `$HOME` de Cloud Shell es persistente**: si instalaste ADK en una sesión anterior, quedó en `~/.local/lib/python3.x/site-packages`. Si después corrés `pip install google-adk` sin el venv activo — o con un venv creado con `--system-site-packages` — pip contesta *"Requirement already satisfied"* y no actualiza nada.

**Diagnóstico.**

```bash
which adk && adk --version
pip show google-adk | grep -E "Version|Location"
ls ~/.local/lib/python3*/site-packages | grep -i adk
echo "VIRTUAL_ENV=$VIRTUAL_ENV"
```

Si `Location` apunta a `~/.local/...` en vez de a tu `.venv`, era esto.

**Solución.**

```bash
deactivate 2>/dev/null; rm -rf .venv
python3 -m venv .venv && source .venv/bin/activate
pip install -U pip && pip install google-adk toolbox-core
which adk && adk --version      # .venv/bin/adk y 2.9.2
```

O, si preferís arreglar el de usuario: `pip install --user --upgrade google-adk`.

> Para un workshop, pineá las versiones en `requirements.txt` (`google-adk==2.9.2`, `toolbox-core==1.4.0`). Así el ensayo y la charla corren lo mismo.

---

## T7. macOS: el puerto 5000 devuelve 403

**Síntoma.** En macOS, tu cliente MCP no se conecta al Toolbox en `localhost:5000`, o devuelve `403`, y el log del Toolbox **no registra ni una request**.

**Causa.** En macOS el puerto 5000 lo ocupa **AirPlay Receiver** (proceso `ControlCenter`). Y `localhost` resuelve a `::1`, donde responde AirPlay. Tu cliente recibe un 403 que no viene del Toolbox.

Verificación:

```bash
lsof -nP -iTCP:5000 -sTCP:LISTEN
# ControlCe  772 usuario  12u  IPv4 ... TCP *:5000 (LISTEN)

curl -o /dev/null -w "%{http_code} (%{remote_ip})\n" -X POST http://localhost:5000/mcp   # 403 (::1)
curl -o /dev/null -w "%{http_code} (%{remote_ip})\n" -X POST http://127.0.0.1:5000/mcp   # 200 (127.0.0.1)
```

**Solución.** Levantá el Toolbox en otro puerto y usá la IP literal, no `localhost`:

```bash
./toolbox --config tools.yaml --port 7000
# y en el cliente / en agent.py: http://127.0.0.1:7000
```

O desactivá AirPlay Receiver en Ajustes → General → AirDrop y Handoff.

En Cloud Shell y Linux no pasa nada de esto.

---

⬅️ [Volver al índice](../README.md)
