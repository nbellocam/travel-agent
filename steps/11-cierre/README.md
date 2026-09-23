# Paso 11 — Cierre

> Paso 11 de 11 · [Índice del workshop](../../README.md)

## Qué construiste

Un agente que responde preguntas sobre 32 hoteles de Argentina, Uruguay y Chile consultando PostgreSQL, **sin una sola query en su código**. Y las mismas tres tools las consumiste desde Antigravity CLI, Claude Code o Codex sin cambiar nada del servidor.

Eso es el punto de MCP: el acceso a datos se define una vez y lo consume cualquier cliente.

## Las ideas que quedan

**El `tools.yaml` es el contrato.** Las queries, los parámetros y las descripciones viven ahí. Cambiás una query, reiniciás el Toolbox, y todos los agentes ven el cambio sin redeploy.

**La `description` de cada tool es prompt, no documentación.** Es lo único que el modelo lee para decidir qué usar. Es el lugar donde más rinde invertir tiempo.

**Los parámetros se bindean, no se interpolan.** No hay inyección SQL posible desde el prompt del usuario.

**El SQL hace el trabajo determinístico.** Ordenar por precio es un `ORDER BY`, no algo que le pedís al modelo. Menos tokens, menos error, resultado reproducible.

**Las credenciales nunca están en el agente.** El Toolbox habla con la base; el agente habla MCP.

## Por dónde seguir

- **Más tools**: agregá una que filtre por disponibilidad usando `booked`, `checkin_date` y `checkout_date`. El dataset ya tiene tres hoteles con `booked = B'1'`.
- **Escribir en la base**: una tool que marque un hotel como reservado. Ahí aparecen los temas interesantes de permisos y confirmación.
- **Autenticación**: el Toolbox soporta `authServices` para tools que requieren identidad del usuario final.
- **Otras fuentes**: el mismo Toolbox soporta BigQuery, AlloyDB, Spanner, MySQL, SQLite y más. La forma del `tools.yaml` es la misma.
- **Agentes múltiples**: ADK permite composición de agentes; el toolset se comparte entre todos.

## Referencias

- [MCP Toolbox for Databases](https://github.com/googleapis/mcp-toolbox) · [releases](https://github.com/googleapis/mcp-toolbox/releases)
- [Agent Development Kit](https://google.github.io/adk-docs/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Antigravity CLI](https://antigravity.google/docs/getting-started?tab=cli) · [MCP en Antigravity](https://antigravity.google/docs/mcp/)
- [Codelab original](https://codelabs.developers.google.com/travel-agent-mcp-toolbox-adk)

## Gracias

Si diste este workshop y algo no funcionó como está escrito, abrí un issue: la idea es que el material se mantenga al día. Todo lo que ya se rompió está en [docs/troubleshooting.md](../../docs/troubleshooting.md).

---

[← Paso 10](../10-limpieza/README.md) · [Índice](../../README.md)
