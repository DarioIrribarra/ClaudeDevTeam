# equipo — skill de Claude Code

**Versión 1.0.0** · Sopytec · requiere Windows + PowerShell

Equipo de agentes de desarrollo con control estricto de tokens. Un Jefe de
Operaciones ubica el trabajo una vez y delega en especialistas solo cuando la
delegación se paga.

## Estado

**No probada todavía.** El diseño está completo y razonado, pero no se ha corrido en
un proyecto real. Antes de repartirla al equipo conviene estrenarla en un proyecto de
verdad y corregir lo que aparezca.

## Qué instala

| Pieza | Dónde | Cuándo se carga |
|---|---|---|
| `SKILL.md` | `~/.claude/skills/equipo/` | Al escribir `/equipo` |
| `instalar.md` | `~/.claude/skills/equipo/` | Una vez por proyecto, en el primer `/equipo` |
| 8 agentes | `.claude/agents/` del proyecto | Solo nombre y descripción; el cuerpo, dentro del subagente |
| `.ai-team/` | Raíz del proyecto | `ESTADO_PROYECTO.md` en cada invocación |
| `permissions.deny` | `.claude/settings.json` del proyecto | Siempre, y también en subagentes |

## Repositorio

<https://github.com/DarioIrribarra/ClaudeDevTeam>

Es la fuente única. Cualquier falla o mejora va ahí, no en copias locales.

Primera vez, en cada computador:

```powershell
git clone https://github.com/DarioIrribarra/ClaudeDevTeam.git; cd ClaudeDevTeam; .\instalar.ps1
```

Para actualizar, desde la carpeta clonada:

```powershell
git pull; .\instalar.ps1
```

`instalar.ps1` sobreescribe los archivos instalados, así que correrlo de nuevo es la
forma normal de actualizar. No hay que desinstalar nada.

## Instalación

Desde esta carpeta:

```powershell
.\instalar.ps1
```

O a mano:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills\equipo"; Copy-Item .\SKILL.md,.\instalar.md "$env:USERPROFILE\.claude\skills\equipo\"
```

Después, en cualquier proyecto: `/equipo`. La primera vez monta el equipo; de ahí en
adelante enruta tareas.

## Cómo repartirla al equipo

Hoy: **el repositorio de arriba.** `git clone` una vez, `git pull` + `instalar.ps1`
para actualizar.

Sube la **versión** de este README en cada cambio. En cuanto hay varias personas
usándola, un "a mí me funciona distinto" sin número de versión es imposible de
diagnosticar.

Si esto se vuelve estándar interno, el paso siguiente es publicarla como **plugin con
marketplace** (`claude plugin marketplace add DarioIrribarra/ClaudeDevTeam`), que hace
llegar las actualizaciones sin que nadie copie nada. Requiere estructura de plugin
además de la skill: no vale la pena antes de estrenarla.

## Advertencias para quien la instale

- **`arquitecto` corre en `opus`.** Si tu plan no da Opus a subagentes, baja ese
  `model:` a `sonnet` en `.claude/agents/arquitecto.md`. El esquema sigue
  funcionando: el reproceso lo corta la compuerta de la Fase 1, no el modelo.
- **El paso de higiene de `CLAUDE.md` toca tus archivos de instrucciones.** La skill
  está escrita para medir, proponer y **esperar confirmación**. Si alguna vez mueve
  algo sin preguntar, es un error: repórtalo.
- **Caveman es opcional.** La skill pide voz telegráfica por instrucción, no por
  dependencia. Funciona igual sin el plugin instalado.
- **Los cambios de configuración invalidan la caché de prompt.** Instala la skill y
  ajusta `CLAUDE.md` y `settings.json` todo junto, al arranque de una sesión, no de a
  uno a mitad del trabajo.
- **Sopytec es el valor por omisión, no un requisito.** Otro stack se detecta y se
  respeta tal cual; la skill no propone migrar nada.

## Archivos de esta carpeta

- `SKILL.md` — la skill. Se instala.
- `instalar.md` — el montaje por proyecto. Se instala.
- `instalar.ps1` — copia los dos anteriores a `~/.claude/skills/equipo/`.
- `PROMPT_EQUIPO.md` — el prompt consolidado, para arrancar una cuenta que todavía no
  tiene la skill, y la tabla de decisiones de diseño. **No se instala.**
- `README.md` — este archivo. No se instala.
