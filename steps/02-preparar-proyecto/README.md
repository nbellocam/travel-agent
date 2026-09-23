# Paso 2 — Preparar el proyecto

> Paso 2 de 11 · [Índice del workshop](../../README.md)

Todo este workshop se puede hacer entero desde **Cloud Shell**, que ya trae `gcloud`, Python y `curl`. Abrilo desde el ícono de terminal en la consola de Google Cloud.

## Verificar cuenta y proyecto

```bash
gcloud auth list
```

Deberías ver tu cuenta marcada con un asterisco.

```bash
gcloud config list project
```

Si el proyecto no es el que querés usar:

```bash
gcloud config set project <YOUR_PROJECT_ID>
```

![Cloud Shell abierto con la salida de gcloud config list project](../../img/02-cloudshell.png)

> 📸 *Imagen provisoria del codelab original. Captura pendiente: `img/02-cloudshell.png` — Cloud Shell abierto con la salida de `gcloud config list project`.*

## Habilitar las APIs

```bash
gcloud services enable cloudresourcemanager.googleapis.com \
                       servicenetworking.googleapis.com \
                       run.googleapis.com \
                       cloudbuild.googleapis.com \
                       aiplatform.googleapis.com \
                       sqladmin.googleapis.com \
                       compute.googleapis.com
```

Al terminar:

```
Operation "operations/..." finished successfully.
```

Tarda un minuto largo. Qué habilita cada una:

| API | Para qué |
|---|---|
| `sqladmin` | Crear y administrar la instancia de Cloud SQL |
| `aiplatform` | Invocar el modelo Gemini desde el agente |
| `run`, `cloudbuild` | El deploy opcional del paso 9 |
| `compute`, `servicenetworking`, `cloudresourcemanager` | Dependencias de red y permisos de las anteriores |

> El codelab original también habilita `cloudfunctions.googleapis.com`, que no se usa en ningún paso. Acá está omitida.

## Guardar el proyecto en una variable

La vas a usar en varios pasos:

```bash
export PROJECT_ID=$(gcloud config get-value project)
echo $PROJECT_ID
```

---

[← Paso 1](../01-introduccion/README.md) · [Índice](../../README.md) · [Paso 3: Crear la instancia de Cloud SQL →](../03-cloud-sql/README.md)
