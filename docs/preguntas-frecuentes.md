# Preguntas frecuentes

Preguntas que suelen aparecer durante el workshop. [Volver al índice](../README.md).

## Conceptos

**¿Qué diferencia hay entre MCP y darle function calling directo al agente?**
Function calling es el mecanismo por el que el modelo pide ejecutar una función. MCP es un protocolo estándar para *exponer* esas funciones. Con MCP las definís una vez y las consume cualquier cliente: ADK, Claude Code, Codex, Antigravity. Eso es lo que muestra el paso 6.

**¿Por qué no dejar que el modelo escriba el SQL (text-to-SQL)?**
Por control. Con queries fijas en el `tools.yaml` sabés exactamente qué se puede ejecutar, no hay inyección y el resultado se puede reproducir. Text-to-SQL sirve para explorar datos; en producción abre mucha superficie de riesgo.

**¿Cómo decide el modelo qué tool usar?**
Solo lee el nombre, la `description` y los parámetros. Por eso la `description` funciona como prompt, no como documentación. Por ejemplo, la de `search-hotels-by-country` le dice explícitamente cuándo usarla.

**¿Qué pasa si dos tools se parecen mucho?**
El modelo se confunde. Hay que escribir descripciones que no se pisen, o juntar las dos en una sola tool con más parámetros.

## Seguridad

**La password está en texto plano en el `tools.yaml`. ¿Eso está bien?**
Solo para la demo. En Cloud Run el `tools.yaml` completo va como secreto en Secret Manager y no queda dentro de la imagen. En producción, además, conviene un usuario de base con permisos mínimos (solo `SELECT`) en lugar de `postgres`, y autenticación IAM.

**¿Hay riesgo de inyección SQL desde el chat?**
No. Los parámetros se *bindean* (`$1`) y nunca se concatenan en el string de la query. El usuario puede escribir cualquier cosa: siempre llega como valor.

**¿El Toolbox en Cloud Run queda público?**
Sí, por el `--allow-unauthenticated`. Se acepta con datos ficticios. En un caso real sacás ese flag y autenticás al que llama, por ejemplo con la service account del agente.

**¿Cómo manejo permisos por usuario final?**
Con `authServices` del Toolbox: la tool recibe la identidad del usuario (por ejemplo, un token de Google) y puede filtrar según ella.

## Arquitectura y operación

**Si cambio una query, ¿tengo que redeployar el agente?**
No. Actualizás el `tools.yaml` (o el secreto en Cloud Run) y reiniciás el Toolbox. El agente no se toca.

**¿Funciona con otras bases además de Postgres?**
Sí: MySQL, AlloyDB, Spanner, BigQuery, SQLite y más. El `tools.yaml` tiene la misma forma; solo cambia el `source`.

**¿Puedo escribir en la base, por ejemplo para reservar un hotel?**
Sí, una tool puede ejecutar un `UPDATE`. Ahí aparecen temas más delicados: permisos, confirmación del usuario antes de ejecutar e idempotencia. Está propuesto como ejercicio en el [cierre](../steps/11-cierre/README.md).

**¿Qué pasa si la query devuelve miles de filas?**
Todas van al contexto del modelo, lo que sale caro y lento. Poné `LIMIT` en el SQL o agregá paginación como parámetro.

**¿Por qué el ordenamiento por precio está en SQL y no se lo pido al modelo?**
Porque es determinístico: gasta menos tokens, tiene menos chance de error y da siempre el mismo resultado.

## ADK y modelos

**¿ADK solo funciona con Gemini?**
No. Gemini es lo nativo, pero ADK soporta otros modelos vía LiteLLM. El Toolbox no depende del modelo que uses.

**¿Por qué `gemini-3.5-flash` con location `global`?**
Porque ese modelo solo está disponible en `global`. Por eso separamos la región de Cloud Run (`us-central1`) de la location del modelo. Ver [T2](troubleshooting.md#t2-404-not_found-publisher-model--was-not-found) y [T3](troubleshooting.md#t3-en-cloud-run-el-modelo-vuelve-a-us-central1).

**¿Qué diferencia hay entre `adk web` y `adk run`?**
Es el mismo agente con dos interfaces. `adk web` es una UI que muestra la traza de las llamadas a tools, ideal para debug. `adk run` es la versión de terminal.

**¿Se pueden combinar varios agentes?**
Sí. ADK permite componer agentes (sub-agentes, flujos secuenciales o paralelos) y todos pueden compartir el mismo toolset.

**¿Puedo hacer este workshop en otro lenguaje que no sea Python?**
Sí. ADK existe en Python, TypeScript, Go, Java y Kotlin. Los pasos 1 a 6 no cambian, porque son base de datos, Toolbox y CLIs. Lo que cambia es el agente (pasos 7 a 9):

| Lenguaje | ADK | Cliente del Toolbox | CLI local (`web` / `run`) | Deploy a Cloud Run |
|---|---|---|---|---|
| Python | `google-adk` | `toolbox-core` | `adk web`, `adk run` | `adk deploy cloud_run --with_ui` |
| TypeScript | `@google/adk` | `@toolbox-sdk/adk` | `npx adk web`, `npx adk run` | `npx adk deploy cloud_run --with_ui` |
| Go | `google.golang.org/adk/v2` | `mcp-toolbox-sdk-go` (paquete `tbadk`) | launcher con web UI | `adkgo deploy cloudrun --webui` |
| Java | `com.google.adk:google-adk` | SDK Java del Toolbox (Maven) o `McpToolset` | web UI vía dependencias en el `pom.xml` | `gcloud run deploy --source .` con Dockerfile |
| Kotlin | `google-adk-kotlin-core` | igual que Java (JVM) | igual que Java | igual que Java |

En cualquier lenguaje también podés saltear el SDK del Toolbox y conectarte como cliente MCP genérico a `http://127.0.0.1:5000/mcp/my_first_toolset`.

El workshop está escrito en Python porque ahí está todo más probado. Para TypeScript y Go el recorrido es prácticamente el mismo. En Java y Kotlin el deploy es más manual. Kotlin es el más nuevo de todos, así que verificá sus versiones antes de usarlo en vivo.

## Costos y práctica

**¿Cuánto me cuesta hacer esto?**
Poco, siempre que limpies al terminar. Lo más caro es la instancia de Cloud SQL encendida; para eso está el [paso 10](../steps/10-limpieza/README.md). No la dejes corriendo.

**¿Lo puedo correr local sin Cloud SQL?**
Sí. Cambiás el `source` a un Postgres local, o incluso a SQLite, y todo lo demás queda igual.

**Me dio un 404 del modelo / página en blanco en `adk web` / el deploy quedó colgado.**
Todo eso está en [troubleshooting.md](troubleshooting.md) (T1 a T7), con causa y solución.
