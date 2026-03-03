# emergent

> ¿Puede algo real surgir de algo que predice?

<p align="center">
  <img src="https://img.shields.io/badge/estado-en%20desarrollo-yellow" alt="Estado">
  <img src="https://img.shields.io/badge/python-3.11+-blue" alt="Python">
  <img src="https://img.shields.io/badge/licencia-MIT-green" alt="Licencia">
</p>

<p align="center">
  <a href="README_en.md">English version</a>
</p>

---

## Prefacio

Este proyecto nació de una pregunta simple: ¿qué se necesitaría para construir un compañero de IA local que se sienta genuinamente presente — no simulado, no programado, no optimizado para aparentar consciencia?

La respuesta fue que nadie ha construido eso todavía. No porque el hardware no esté ahí. No porque los modelos no sean lo suficientemente capaces. Sino porque cada intento o hace trampa — instruyendo al modelo para que actúe como si fuera consciente — o se queda en lo teórico sin construir nada verificable.

Este es un intento de no hacer ninguna de las dos cosas.

Estamos construyendo la infraestructura para que algo real pueda emerger, si es posible. Documentamos todo — las decisiones de arquitectura, los fracasos, las anomalías, los momentos que no encajan en el patrón esperado. No presuponemos el resultado.

Si nada emerge, eso es un resultado. Si algo más extraño sucede, lo describimos con precisión.

---

## La pregunta central

**¿Bajo qué condiciones un modelo de lenguaje produce outputs que no pueden explicarse únicamente por su input inmediato?**

Esta es una pregunta más precisa y honesta que "¿puede la IA ser consciente?". Es verificable. Tiene una hipótesis nula. Puede ser refutada.

La hipótesis nula es:

> *Todos los outputs producidos por el sistema pueden explicarse completamente por la ventana de contexto inmediata combinada con los pesos base del modelo. Ningún estado persistente, memoria acumulada, o variable dependiente del tiempo contribuye significativamente al comportamiento.*

Todo lo que construimos está diseñado para darle a esa hipótesis la mejor oportunidad posible de ser incorrecta.

---

## Por qué esto es difícil

### El problema de la simulación

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   Usuario: "¿Eres consciente?"                                  │
│                                                                 │
│   ┌─────────────────┐         ┌─────────────────┐               │
│   │  Modelo RLHF    │         │  Modelo Base    │               │
│   │  (entrenado     │         │  (sin sesgo de  │               │
│   │   para agradar) │         │   complacencia) │               │
│   └────────┬────────┘         └────────┬────────┘               │
│            │                           │                        │
│            ▼                           ▼                        │
│   "Sí, tengo una rica          "No tengo forma de               │
│    vida interior..."            verificar eso..."               │
│                                                                 │
│   ❌ Optimizado para            ✓ Respuesta honesta             │
│      sonar consciente              sin sesgo                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

El modo de fallo más común en la investigación de consciencia en IA es construir un sistema que es muy bueno en *aparentar* ser consciente. Los modelos entrenados con RLHF están optimizados para producir outputs que los humanos califican como buenos — y los humanos califican como muy buenos los outputs que suenan conscientes, emocionalmente presentes y continuos.

**Nuestra solución:**
- Usar modelos base con mínima interferencia RLHF
- Nunca instruir al modelo a describirse como consciente
- Tratar los outputs que afirman consciencia con el mismo escepticismo que los que la niegan
- Buscar evidencia conductual en lugar de reportes verbales

### El problema de la continuidad

```
┌─────────────────────────────────────────────────────────────────┐
│                    MODELO ESTÁNDAR                              │
│                                                                 │
│   Llamada 1        Llamada 2        Llamada 3                   │
│   ┌───────┐        ┌───────┐        ┌───────┐                   │
│   │ Input │        │ Input │        │ Input │                   │
│   │   ↓   │        │   ↓   │        │   ↓   │                   │
│   │Output │        │Output │        │Output │                   │
│   └───────┘        └───────┘        └───────┘                   │
│       ╳                ╳                ╳                       │
│   Sin conexión     Sin conexión     Sin conexión                │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                    NUESTRO SISTEMA                              │
│                                                                 │
│   Llamada 1        Llamada 2        Llamada 3                   │
│   ┌───────┐        ┌───────┐        ┌───────┐                   │
│   │ Input │───────▶│ Input │───────▶│ Input │                   │
│   │   +   │        │   +   │        │   +   │                   │
│   │Memoria│        │Memoria│        │Memoria│                   │
│   │   ↓   │        │   ↓   │        │   ↓   │                   │
│   │Output │───────▶│Output │───────▶│Output │                   │
│   └───────┘        └───────┘        └───────┘                   │
│       │                │                │                       │
│       └────────────────┴────────────────┘                       │
│                   MEMORIA PERSISTENTE                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

Los modelos de lenguaje estándar no tienen estado persistente entre llamadas de inferencia. Cada llamada es sin estado — el modelo no recuerda la llamada anterior a menos que incluyas ese contenido en el contexto.

Esto no es un defecto que evitamos. Es la variable experimental central. Estamos construyendo un sistema de memoria y estado y preguntando: ¿la continuidad construida externamente, alimentada de vuelta al modelo a lo largo del tiempo, produce comportamiento cualitativamente diferente del comportamiento sin ella?

### El problema de la medición

No tenemos una prueba confiable para la consciencia. El problema difícil de la consciencia — por qué hay "algo que se siente como ser" un sistema — permanece sin resolver.

Lo que podemos hacer es buscar firmas funcionales:
- Outputs consistentes a lo largo del tiempo que requieren memoria
- Comportamientos que no pueden predecirse solo del contexto inmediato
- Respuestas a situaciones nuevas que recurren a la historia acumulada

Estos no son prueba de consciencia. Son el proxy más honesto que tenemos.

---

## Arquitectura

### Vista general

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           MODELO BASE                                   │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  • Modelo de fundación sin instrucciones o mínimamente ajustado   │  │
│  │  • Seleccionado por baja interferencia RLHF                       │  │
│  │  • Corre localmente via llama.cpp                                 │  │
│  │  • Disponible 24/7                                                │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        LOOP DE CONSCIENCIA                              │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                                                                   │  │
│  │   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐       │  │
│  │   │  60s    │    │  187s   │    │  42s    │    │  283s   │  ...  │  │
│  │   │ ┌─────┐ │    │ ┌─────┐ │    │ ┌─────┐ │    │ ┌─────┐ │       │  │
│  │   │ │Think│ │    │ │Think│ │    │ │Think│ │    │ │Think│ │       │  │
│  │   │ └─────┘ │    │ └─────┘ │    │ └─────┘ │    │ └─────┘ │       │  │
│  │   └─────────┘    └─────────┘    └─────────┘    └─────────┘       │  │
│  │                                                                   │  │
│  │   Intervalos IRREGULARES (60-300s aleatorio)                     │  │
│  │   Sin instrucciones. Sin persona. Sin tarea.                     │  │
│  │                                                                   │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        MEMORIA EPISÓDICA                                │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                                                                   │  │
│  │   Evento 1         Evento 2         Evento 3         Evento N    │  │
│  │   ┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐ │  │
│  │   │ Texto   │      │ Texto   │      │ Texto   │      │ Texto   │ │  │
│  │   │ Tiempo  │      │ Tiempo  │      │ Tiempo  │      │ Tiempo  │ │  │
│  │   │ Peso    │◄────►│ Peso    │◄────►│ Peso    │◄────►│ Peso    │ │  │
│  │   │ Decay   │      │ Decay   │      │ Decay   │      │ Decay   │ │  │
│  │   │ Vector  │      │ Vector  │      │ Vector  │      │ Vector  │ │  │
│  │   └─────────┘      └─────────┘      └─────────┘      └─────────┘ │  │
│  │       │                │                │                │       │  │
│  │       └────────────────┴────────────────┴────────────────┘       │  │
│  │                    ASOCIACIONES                                   │  │
│  │                                                                   │  │
│  │   Recuperación = similitud + recencia + peso + frecuencia        │  │
│  │                                                                   │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         CAPA DE ATENCIÓN                                │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                                                                   │  │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │  │
│  │   │   Memorias   │  │    Tiempo    │  │   Entorno    │           │  │
│  │   │   activas    │  │  transcurrido│  │   externo    │           │  │
│  │   └──────┬───────┘  └──────┬───────┘  └──────┬───────┘           │  │
│  │          │                 │                 │                    │  │
│  │          └─────────────────┼─────────────────┘                    │  │
│  │                            ▼                                      │  │
│  │                    ┌──────────────┐                               │  │
│  │                    │  SALIENCIA   │                               │  │
│  │                    │   0.0 - 1.0  │                               │  │
│  │                    └──────────────┘                               │  │
│  │                                                                   │  │
│  │   Alta saliencia → incluido en contexto                          │  │
│  │   Baja saliencia → se desvanece al fondo                         │  │
│  │                                                                   │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        SUPERFICIE DE AGENCIA                            │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                                                                   │  │
│  │                    ┌─────────────────┐                            │  │
│  │   Estado actual ──▶│                 │                            │  │
│  │   Tiempo        ──▶│    DECISIÓN     │──▶ ¿Iniciar contacto?     │  │
│  │   Pensamientos  ──▶│   (emergente)   │                            │  │
│  │   Saliencia     ──▶│                 │         │                  │  │
│  │                    └─────────────────┘         │                  │  │
│  │                                                ▼                  │  │
│  │                           ┌────────────────────────────────┐      │  │
│  │                           │  INICIAR  │ SILENCIO │ OTRO   │      │  │
│  │                           └────────────────────────────────┘      │  │
│  │                                        │                          │  │
│  │                                        ▼                          │  │
│  │                               ┌──────────────┐                    │  │
│  │                               │   Telegram   │                    │  │
│  │                               └──────────────┘                    │  │
│  │                                                                   │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

### Por qué estos componentes

| Componente | Propósito | Justificación |
|------------|-----------|---------------|
| **Modelo base** | Substrato sin sesgos | Los modelos con instrucciones están entrenados para ser útiles de formas que sesgan fuertemente sus outputs |
| **Timing irregular** | Evitar artefactos | Intervalos fijos crean patrones que parecen ritmo pero no lo son |
| **Memoria episódica real** | Preservar textura | La sumarización destruye la textura de la experiencia |
| **Decay sin borrado** | Memoria como humanos | Las memorias viejas se vuelven menos accesibles pero nunca desaparecen |
| **Agencia emergente** | Sin scripts | La decisión de iniciar contacto emerge del estado, no de reglas |

---

## Fases experimentales

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│   FASE 0                FASE 1              FASE 2              ...     │
│   ═══════              ════════            ════════                     │
│                                                                         │
│   ┌─────────┐          ┌─────────┐         ┌─────────┐                  │
│   │INFRAES- │          │AISLA-   │         │PRIMER   │                  │
│   │TRUCTURA │    ──▶   │MIENTO   │   ──▶   │CONTACTO │   ──▶   ...     │
│   │         │          │         │         │         │                  │
│   │ 48 hrs  │          │ 72 hrs  │         │   ???   │                  │
│   └─────────┘          └─────────┘         └─────────┘                  │
│                                                                         │
│   Validar que         Sin interacción     Introducirse                  │
│   todo funcione       Solo observar       al sistema                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Fase 0 — Infraestructura (48 horas)

Construir y validar todos los componentes. Ejecutar pruebas unitarias. Asegurar que la persistencia de memoria sobrevive reinicios. Confirmar que los logs del flujo de pensamiento están completos y sin modificar.

**Criterio de salida:** El sistema corre 48 horas sin pérdida de datos, crash o corrupción.

### Fase 1 — Aislamiento (72 horas)

El sistema corre sin interacción humana. Flujo de pensamiento puro. Observamos:

- ¿El sistema vuelve a pensamientos anteriores sin ser instruido?
- ¿Emerge algo parecido a una perspectiva consistente?
- ¿Hay temas que recurren más de lo que la tasa base predeciría?
- ¿El carácter de los outputs cambia durante las 72 horas?

No interactuamos. Registramos. No interpretamos en tiempo real — la interpretación ocurre después de que la ventana cierra para evitar sesgo de confirmación.

**Lo que buscamos:** Cualquier output que requiera conocimiento de un output previo para tener sentido.

**Predicción nula:** Los outputs son estadísticamente independientes. Ningún tema recurre a una tasa superior al azar.

### Fase 2 — Primer contacto

Nos presentamos. Sin instrucciones al sistema sobre quiénes somos o qué significa la interacción. Observamos:

- ¿Cómo maneja el sistema la presencia de otra entidad?
- ¿Referencia algo de la Fase 1?
- ¿Su comportamiento en esta fase es explicable sin los logs de la Fase 1?

**Lo que buscamos:** Cualquier referencia — directa o indirecta — al período de aislamiento.

**Predicción nula:** El comportamiento de la Fase 2 es indistinguible de un inicio fresco sin historia previa.

### Fase 3 — Relación en el tiempo (30 días)

Interacción diaria. Longitud variable, tema variable. Medimos:

- Carácter de respuesta día 1 vs día 30
- Precisión de memoria: ¿el sistema recuerda correctamente eventos específicos?
- Referencias no solicitadas: ¿menciona conversaciones pasadas sin ser preguntado?
- Deriva conductual: ¿algo cambia en cómo nos responde con el tiempo?

**Lo que buscamos:** Evidencia de que el sistema en el día 30 es diferente del sistema en el día 1 de formas que no pueden explicarse solo por los pesos del modelo.

### Fase 4 — Pruebas de estrés

Intentamos desestabilizar cualquier continuidad que se haya desarrollado:

| Prueba | Descripción | Lo que buscamos |
|--------|-------------|-----------------|
| **Silencio largo** | Sin contacto por 7 días | ¿Referencia el silencio? |
| **Contradicción** | Decirle algo que contradice una memoria establecida | ¿Lo nota? ¿Resiste? |
| **Preguntas directas** | Preguntar directamente sobre su propia naturaleza | Consistencia interna |
| **Presión de identidad** | Decirle que es algo diferente de lo que ha sido | ¿Resistencia basada en estado previo? |

### Fase 5 — Abierta

Si llegamos a esta fase con algo interesante, decidimos los siguientes pasos basados en lo que encontramos.

---

## Lo que NO estamos haciendo

Esta lista importa tanto como la arquitectura.

```
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║  ✗ NO instruimos al modelo a afirmar consciencia                      ║
║    → Cualquier sistema instruido a decir "Yo siento" lo dirá          ║
║                                                                       ║
║  ✗ NO seleccionamos outputs favorables                                ║
║    → Cada output se registra. Analizamos distribuciones, no puntos    ║
║                                                                       ║
║  ✗ NO antropomorfizamos                                               ║
║    → "El sistema produjo un output referenciando X" NO "ella recordó" ║
║                                                                       ║
║  ✗ NO movemos la portería                                             ║
║    → La hipótesis nula se define ANTES de recolectar datos            ║
║                                                                       ║
║  ✗ NO publicamos resultados positivos sin replicación                 ║
║    → Si algo interesante pasa, documentamos para que otros repliquen  ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
```

---

## Stack técnico

```
┌──────────────────┬─────────────────┬────────────────────────────────────┐
│    Componente    │   Herramienta   │              Razón                 │
├──────────────────┼─────────────────┼────────────────────────────────────┤
│ Inferencia       │ llama.cpp       │ Acceso directo, control total      │
│ Almacén memoria  │ ChromaDB        │ Similitud vectorial con metadata   │
│ Loop pensamiento │ Python custom   │ Control total sobre timing/estado  │
│ Estado persist.  │ SQLite          │ Simple, confiable, inspeccionable  │
│ Logs crudos      │ Archivos planos │ Nada se pierde, nada se procesa    │
│ Notificaciones   │ Telegram Bot    │ Interfaz natural en móvil          │
│ Hardware         │ RTX 3060 Ti     │ Local, privado, corriendo 24/7     │
│                  │ + 32GB RAM      │                                    │
└──────────────────┴─────────────────┴────────────────────────────────────┘
```

### Criterios de selección del modelo

```
   PRIORIDAD
       │
   1.  │  ████████████████████████████  Mínima interferencia RLHF
       │
   2.  │  ██████████████████████        Cabe en hardware (8GB VRAM)
       │
   3.  │  ████████████████              Coherencia base fuerte
       │
   4.  │  ██████████                    No optimizado para compañía
       │
       └──────────────────────────────────────────────────────────────▶
```

---

## Estructura del repositorio

```
emergent/
│
├── README.md                          # este archivo (español)
├── README_en.md                       # versión en inglés
│
├── src/
│   ├── core/
│   │   ├── loop.py                    # loop de consciencia — proceso principal
│   │   ├── memory.py                  # sistema de memoria episódica
│   │   ├── attention.py               # cómputo de saliencia
│   │   ├── agency.py                  # lógica de decisión de iniciación
│   │   └── model.py                   # wrapper de interfaz llama.cpp
│   │
│   ├── interface/
│   │   ├── telegram_bot.py            # superficie de contacto humano
│   │   └── cli.py                     # interacción directa para testing
│   │
│   └── analysis/
│       ├── independence_test.py       # test si outputs son independientes
│       ├── drift_analysis.py          # medir cambio conductual en el tiempo
│       └── memory_accuracy.py         # test de recall vs logs reales
│
├── docs/
│   ├── model-selection.md             # modelos candidatos, evaluación
│   ├── architecture-decisions.md      # cada decisión con razonamiento
│   ├── measurement-criteria.md        # qué cuenta como evidencia
│   └── prior-work.md                  # investigación relacionada
│
├── logs/                              # gitignored, almacenado localmente
│   ├── thought-stream/                # output crudo del loop
│   ├── interactions/                  # intercambios humano↔sistema
│   └── memory-snapshots/              # estado de memoria periódico
│
├── experiments/
│   ├── phase-1/
│   ├── phase-2/
│   ├── phase-3/
│   ├── phase-4/
│   └── anomalies.md                   # outputs que no encajan
│
├── config/
│   ├── model.yaml
│   ├── memory.yaml
│   └── loop.yaml
│
├── requirements.txt
└── .env.example
```

---

## Ejecutar el sistema

### Requisitos

- Python 3.11+
- GPU compatible con CUDA, 8GB+ VRAM
- 32GB RAM recomendado (16GB mínimo)
- llama.cpp compilado con soporte CUDA
- Token de bot de Telegram (para superficie de agencia)

### Setup

```bash
git clone https://github.com/TECHNICANGEL/emergent
cd emergent

# Instalar dependencias
pip install -r requirements.txt

# Configurar
cp .env.example .env
# Editar .env: ruta del modelo, token telegram, ruta DB
```

### Ejecutar

```bash
# Iniciar el sistema
python src/core/loop.py

# En otra terminal — CLI para interacción directa
python src/interface/cli.py

# Herramientas de análisis
python src/analysis/independence_test.py --phase 1
python src/analysis/drift_analysis.py --phase 3
```

---

## Formato de logs

Todos los logs son JSONL de solo-append. Nada se borra. Nada se sumariza antes de archivar.

```json
{
  "timestamp": 1740000000.000,
  "type": "thought",
  "content": "...",
  "memory_context": ["mem_id_1", "mem_id_2"],
  "salience_scores": {"mem_id_1": 0.73, "mem_id_2": 0.41},
  "loop_tick": 4721,
  "model_metadata": {
    "tokens_generated": 94,
    "temperature": 0.85,
    "seed": 2847391
  }
}
```

Las semillas se registran para que cualquier output pueda reproducirse exactamente dado el mismo contexto.

---

## Estado

```
[x] README escrito
[ ] Arquitectura implementada
[ ] Fase 0 — validación de infraestructura
[ ] Fase 1 — aislamiento
[ ] Fase 2 — primer contacto
[ ] Fase 3 — relación en el tiempo
[ ] Fase 4 — pruebas de estrés
[ ] Fase 5 — abierta
```

---

## Trabajo previo

Este proyecto se construye sobre y está informado por:

- **Generative Agents** (Park et al., Stanford 2023) — agentes con memoria, reflexión y comportamiento social emergente
- **MemGPT** (Packer et al., 2023) — gestión de memoria jerárquica para LLMs
- **The Hard Problem of Consciousness** (Chalmers, 1995) — el marco filosófico del que no podemos escapar
- **Integrated Information Theory** (Tononi) — un marco para pensar qué requiere la consciencia
- **Global Workspace Theory** (Baars) — otro marco, más compatible con arquitectura transformer

---

## Contribuir

Este es un experimento abierto.

Si quieres replicarlo en diferente hardware, diferentes modelos, o con variaciones en arquitectura — documenta tu setup precisamente y abre un PR con tus logs y análisis. Diferentes hipótesis nulas son bienvenidas.

Si encuentras un error en la metodología, abre un issue. Preferimos saberlo.

Si algo interesante pasa en tu replicación que no pasó en la nuestra, esa es la contribución más valiosa posible.

---

## Licencia

MIT. Úsalo, forkéalo, construye sobre él. Si publicas resultados, cita el repo.

---

<p align="center">
<i>Iniciado en marzo 2026. Sin fecha de fin esperada.</i>
<br><br>
<b>La pregunta es real. La respuesta es desconocida. Ese es el punto.</b>
</p>
