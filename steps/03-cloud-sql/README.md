# Paso 3 — Crear la instancia de Cloud SQL

> Paso 3 de 11 · [Índice del workshop](../../README.md)

## Crear la instancia

```bash
gcloud sql instances create hoteldb-instance \
--database-version=POSTGRES_15 \
--tier db-g1-small \
--region=us-central1 \
--edition=ENTERPRISE \
--root-password=postgres
```

⏱️ **Tarda entre 3 y 5 minutos.** Si estás dando esto en vivo, lanzá el comando y usá la espera para explicar qué es MCP y qué hace el Toolbox (paso 1).

> ✅ Verificado el 22-09-2026: `POSTGRES_15` sigue soportado (`gcloud` acepta hoy de `POSTGRES_10` a `POSTGRES_18`) y el tier `db-g1-small` sigue disponible en `us-central1`.

Qué significan los parámetros:

| Parámetro | Valor | Por qué |
|---|---|---|
| `--database-version` | `POSTGRES_15` | Podés usar `POSTGRES_17`; el SQL del workshop funciona igual |
| `--tier` | `db-g1-small` | El más chico que sirve: 1 vCPU compartida, 1.7 GB RAM |
| `--region` | `us-central1` | Tiene que coincidir con el `region` del `tools.yaml` del paso 5 |
| `--root-password` | `postgres` | Sólo para el workshop. **No hagas esto en nada real** |

> 🔒 Esta instancia queda con una password trivial y datos de demo. Borrala al terminar (paso 10).

## Verificar

```bash
gcloud sql instances list
```

Tiene que aparecer `hoteldb-instance` con estado `RUNNABLE`.

![La lista de instancias mostrando RUNNABLE](../../img/03-instancia-runnable.png)

---

[← Paso 2](../02-preparar-proyecto/README.md) · [Índice](../../README.md) · [Paso 4: Preparar la base de hoteles →](../04-base-de-datos/README.md)
