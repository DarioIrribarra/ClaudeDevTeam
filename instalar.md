# Montaje del equipo en un proyecto

Se lee **una sola vez** por proyecto, cuando falta `.ai-team/ESTADO_PROYECTO.md`.
No escribas resúmenes intermedios. Si una pieza no ahorra tokens, no la crees y
dilo en una línea.

**No crees `.claudeignore`.** Claude Code no lo soporta: no hace nada.

## 0. Higiene de `CLAUDE.md` — el ahorro más grande

Esto rinde más que todo el resto junto, y rinde aunque el usuario nunca use
`/equipo`. Hazlo **primero**.

Mide:

```powershell
Get-ChildItem "$env:USERPROFILE\.claude\*.md",".\CLAUDE.md" -ErrorAction SilentlyContinue |
  ForEach-Object { "{0,-30} ~{1} tok" -f $_.Name,[math]::Round($_.Length/3.6) }
```

Por qué importa: cada subagente hereda el `CLAUDE.md` global **y** el del proyecto,
completos y **sin caché**, porque su contexto es nuevo. Una cadena de 5 agentes paga
ese total cinco veces antes de hacer nada útil. En el hilo principal la caché lo
baja a ~10 % del peso; en los agentes no hay caché que lo cubra.

Criterios para clasificar lo que hay en esos archivos:

| Qué es | Dónde va |
|---|---|
| Ley de conducta (idioma, criterios de decisión, permisos) | Se queda en `CLAUDE.md` |
| Referencia temática (manual de marca, referencia de comandos, estándar de estructura) | Sale a skill: se carga cuando toca |
| Bitácora histórica ("lo que costó descubrir", "lo que ya se corrigió") | Sale a `docs/` con una línea de puntero |
| `@import` de un archivo que no es ley | Se elimina el import; el archivo pasa a skill |

Objetivo: `CLAUDE.md` del proyecto bajo ~1.500 tokens, el global bajo ~1.000.

**No muevas nada por tu cuenta.** Informa los números medidos y la propuesta en 5
líneas y espera confirmación: es el `CLAUDE.md` del usuario y puede tener razones
para lo que hay ahí.

## 1. Negar lectura de basura

Fusiona en `.claude/settings.json` sin borrar lo que ya exista. Esto sí corta, y
aplica también a los subagentes:

```json
{
  "permissions": {
    "deny": [
      "Read(**/node_modules/**)", "Read(**/bin/**)", "Read(**/obj/**)",
      "Read(**/dist/**)", "Read(**/build/**)", "Read(**/*.min.js)",
      "Read(**/*.map)", "Read(**/package-lock.json)", "Read(**/yarn.lock)",
      "Read(**/pnpm-lock.yaml)", "Read(**/*.dll)", "Read(**/*.exe)",
      "Read(**/*.pdb)", "Read(**/*.sqlite)", "Read(**/*.db)"
    ]
  }
}
```

`Grep` y `Glob` ya respetan `.gitignore`: no configures nada para búsqueda.

## 2. Servidores MCP sin usar

Lista con `/mcp` los servidores conectados. Los que el proyecto no use tienen sus
nombres y esquemas de herramientas residentes en el contexto. Informa cuáles son y
el comando para sacarlos (`claude mcp remove <nombre>`), sin ejecutarlo.

## 3. Caveman (opcional, solo si el usuario lo quiere)

Comprueba `caveman status`. Si responde, no toques nada: el plugin auto-activa por
hook de `SessionStart`. Si no está instalado:

```
claude plugin marketplace add JuliusBrussee/caveman
claude plugin install caveman@caveman
```

No invoques `caveman on <modulo>` ni `caveman-blocks`: no existen en esta versión.

## 4. Reconocer el proyecto (barato)

Si existe `graphify-out/graph.json`, consúltalo en vez de explorar. Si no: **un
solo** `Glob` por `*.sln`, `*.csproj`, `package.json`, `vite.config.ts`,
`requirements.txt`, `pom.xml`, `composer.json`, `go.mod`, `Cargo.toml`, más la lista
de carpetas de primer nivel. Nada de leer archivos completos.

Deduce el nombre base de la carpeta raíz y decide el caso:

| Caso | Qué va en `## Reglas de stack` |
|---|---|
| Proyecto nuevo o vacío | Estándar Sopytec completo (abajo) |
| Stack Sopytec detectado | Estándar Sopytec + las rutas reales encontradas |
| Otro stack detectado | Lo detectado, en sus propios términos. **No migres ni propongas migrar**, salvo que el usuario lo pida |

### Estándar Sopytec (valor por omisión)

- Carpetas `[Proyecto]_BACK` y `[Proyecto]_FRONT`, o las que ya existan.
- C# .NET **sin ORM**. Prohibido Entity Framework y Dapper. ADO.NET estricto con
  `Microsoft.Data.SqlClient`: `SqlConnection`, `SqlCommand`, `SqlDataReader`,
  `Parameters.AddWithValue`, `Conexion.ConnectionString`.
- Estructura `Controllers/`, `Model/DAO/`, `Model/DTO/`.
- Rutas `[Route("Controlador")]` + `[HttpGet/Post/Delete("Accion")]`.
- Log con `await Funciones.LogLocal(...)`.
- SQL solo en procedimientos almacenados.
- Front Vite + React + TypeScript, `src/` y `.env`, endpoints exactos del C#.
- SQLite local, offline-first, estado online/offline, `RowVersion`/timestamps para
  resolución de conflictos.

## 5. Los ocho agentes

Un archivo por agente en `.claude/agents/`. **No crees un `AGENTES.md`
monolítico**: entraría completo al contexto en cada invocación. Los archivos de
agente solo exponen nombre y descripción al contexto principal; el cuerpo se carga
dentro del subagente.

El `tools:` importa: los esquemas de herramientas pesan miles de tokens en cada
arranque en frío.

**Opus solo en `arquitecto`.** El costo real no es el precio por token: son los
tokens hasta acertar. Un diseño malo cuesta un "te equivocaste, analiza de nuevo" más
la cadena completa de reescrituras, y eso supera cualquier ahorro de bajar el modelo.
El arquitecto es además el agente de menor volumen del esquema: se invoca poco, no
escribe código, no lee el repo entero y entrega 15 líneas. Es el mejor lugar para
gastar el modelo bueno.

El resto va en `sonnet` o `haiku`: escriben mucho sobre un patrón ya fijado y `qa` y
`appsec` los cubren. Ahí el error es barato de detectar y de corregir.

**Si el plan no da acceso a Opus en subagentes**, baja `arquitecto` a `sonnet` y
apóyate en la compuerta de usuario de la Fase 1: eso es lo que de verdad corta el
reproceso, más que el modelo.

| archivo | model | tools |
|---|---|---|
| `arquitecto.md` | `opus` | Read, Grep, Glob, Write |
| `backend.md` | `sonnet` | Read, Grep, Glob, Edit, Write, Bash |
| `frontend.md` | `sonnet` | Read, Grep, Glob, Edit, Write, Bash |
| `dba.md` | `sonnet` | Read, Grep, Glob, Edit, Write |
| `devops.md` | `haiku` | Read, Edit, Write, Bash |
| `qa.md` | `sonnet` | Read, Grep, Bash |
| `appsec.md` | `sonnet` | Read, Grep, Bash |
| `tech-writer.md` | `haiku` | Read, Edit, Write |

El **Jefe de Operaciones no es subagente**: vive en la skill y corre en el modelo de
la sesión. Así se ahorra un arranque en frío por tarea y decide mejor a quién
convocar, que es donde está el gasto grande.

### Forma de cada archivo

```markdown
---
name: <rol>
description: <una línea precisa: cuándo convocarlo. El router decide con esto, sin leer el cuerpo.>
model: <de la tabla>
tools: <de la tabla>
---

# <Rol>

<Especialidad en 1-2 líneas, de la lista de abajo.>

## Economía

<El bloque "Economía" de SKILL.md, textual, los 10 puntos.>

## Informe

<El bloque "Informe" de SKILL.md, textual: ARCHIVOS / VERIFICADO / SUPUESTOS / BLOQUEOS.>
```

Máximo 25 líneas por archivo. Voz caveman. **Sin mencionar ningún stack en el
cuerpo**: las convenciones llegan en el encargo.

### Especialidad de cada uno

- **arquitecto**: estructura de carpetas y capas, contratos DTO/DAO, sincronización
  entre base central y base local. Entrega diseño telegráfico, nunca código.
  Lleva estas reglas propias, además del bloque Economía:
  - Máximo 15 líneas de diseño. Si no cabe, el alcance está mal: dilo y pregunta.
  - Si falta un dato que **cambia** el diseño, pregunta antes de diseñar. Una sola
    ronda, máximo 3 preguntas, una línea cada una. Una pregunta barata antes vale
    diez correcciones después.
  - Prohibido agregar lo que no se pidió: sin capas especulativas, sin interfaces de
    una sola implementación, sin patrones "por si acaso", sin configuración para
    casos que no existen. La sobreingeniería se paga dos veces: al escribirla y al
    mantenerla.
  - Enumera primero lo que ya existe en el repo y sirve. Reusar antes de crear.
  - Entrega los supuestos explícitos, en línea aparte. El usuario corrige un supuesto
    en una línea; corregir código ya escrito cuesta la cadena completa.
  - Si la tarea toca menos de 3 archivos, no hay arquitectura que diseñar: dilo y
    devuelve el control.
- **backend**: API del lado servidor según las convenciones del encargo.
- **frontend**: interfaz y consumo de endpoints según las convenciones del encargo.
  Estado online/offline si el proyecto lo usa.
- **dba**: esquema, migraciones, versionado de filas y resolución de conflictos.
- **devops**: variables de entorno, CORS entre front y back, scripts de despliegue,
  servicios locales.
- **qa**: tests y simulación de corte de red. **Poder de veto.** Trabaja sobre el
  diff que le llega en el encargo, nunca sobre el repo.
- **appsec**: inyección SQL (parámetros, nunca concatenación), validación de
  identificadores, tokens, cifrado de la base local. **Poder de veto.** Trabaja
  sobre el diff del encargo.
- **tech-writer**: cierra `.ai-team/ESTADO_PROYECTO.md` en 2 líneas y escribe la
  línea de la bitácora de costo.

## 6. `.ai-team/`

**`ESTADO_PROYECTO.md`** — el único archivo que la skill lee en cada invocación.
Cada línea que sobre se paga en todas las tareas futuras. Secciones:

```markdown
# <Proyecto>

## Stack
<tabla compacta: pieza | qué es | dónde>

## Reglas de stack
<lo decidido en el paso 4>

## Costo fijo de delegar
<tokens medidos del CLAUDE.md global + el del proyecto: es lo que paga cada subagente>

## Estado
<2-4 líneas: en qué va el proyecto>

## Bitácora de costo
| fecha | tarea | agentes | costo |
```

**`TAREAS.md`** — lista inicial de tareas, una línea cada una.

## 7. `CLAUDE.md` de la raíz

Solo si no existe. Máximo 20 líneas: permisos, estándar del proyecto y la línea
`Equipo: /equipo`. Nada más: `CLAUDE.md` se reenvía en cada turno de cada sesión y
lo paga cada subagente sin caché.

## 8. Cierre del montaje

Responde solo como **[Jefe Operaciones]**, voz caveman: qué creaste, qué omitiste
por no ahorrar, los números de la higiene de `CLAUDE.md` con la propuesta, estado de
caveman, resumen del escaneo en 3 líneas, y pide la primera tarea.
