# Paso 10 — Limpieza

> Paso 10 de 11 · [Índice del workshop](../../README.md)

Importante: la instancia de Cloud SQL factura por hora **esté o no en uso**. Si hiciste el workshop para probar, borrá todo.

```bash
export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-central1
```

## Los servicios de Cloud Run

```bash
gcloud run services delete toolbox \
  --platform=managed --region=$REGION --project=$PROJECT_ID --quiet

gcloud run services delete hotels-service \
  --platform=managed --region=$REGION --project=$PROJECT_ID --quiet
```

## La instancia de Cloud SQL

```bash
gcloud sql instances delete hoteldb-instance --project=$PROJECT_ID
```

Es el recurso más caro de todos: no te lo saltees.

## El secreto y la service account

```bash
gcloud secrets delete tools --project=$PROJECT_ID --quiet

gcloud iam service-accounts delete \
  toolbox-identity@$PROJECT_ID.iam.gserviceaccount.com --quiet
```

## La configuración local del CLI

Según el que hayas usado en el paso 6:

```bash
agy mcp remove MCPToolbox
claude mcp remove MCPToolbox -s local
codex mcp remove MCPToolbox
```

## Verificar que no quedó nada

```bash
gcloud run services list --project=$PROJECT_ID
gcloud sql instances list --project=$PROJECT_ID
```

Las dos listas tienen que volver vacías (o sin los recursos del workshop).

---

[← Paso 9](../09-cloud-run/README.md) · [Índice](../../README.md) · [Paso 11: Cierre →](../11-cierre/README.md)
