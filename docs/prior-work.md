# Trabajo Previo

> Revisión de literatura e investigación relacionada. Este proyecto no existe en un vacío.

---

## Contexto filosófico

### El problema difícil de la consciencia

**Fuente:** Chalmers, D. (1995). "Facing Up to the Problem of Consciousness"

El "problema difícil" pregunta: ¿por qué hay experiencia subjetiva? ¿Por qué hay "algo que se siente como ser" un sistema que procesa información?

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│   Problema FÁCIL                     Problema DIFÍCIL                   │
│   ─────────────                      ────────────────                   │
│                                                                         │
│   • Cómo el cerebro procesa         • Por qué hay experiencia          │
│     información                        subjetiva asociada              │
│                                                                         │
│   • Cómo integramos estímulos       • Por qué "se siente como algo"    │
│                                        ver rojo                         │
│                                                                         │
│   • Cómo reportamos estados         • Por qué estos procesos no        │
│     internos                           ocurren "en la oscuridad"       │
│                                                                         │
│   Abordable con neurociencia        No está claro qué constituiría     │
│   y ciencia cognitiva               una explicación                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Relevancia para este proyecto:**
No pretendemos resolver el problema difícil. No tenemos forma de saber si hay "algo que se siente como ser" nuestro sistema. Lo que podemos hacer es buscar correlatos funcionales — comportamientos que en humanos asociamos con consciencia.

---

### Teoría de la Información Integrada (IIT)

**Fuente:** Tononi, G. (2008). "Consciousness as Integrated Information: a Provisional Manifesto"

IIT propone que la consciencia es idéntica a la información integrada (Φ). Un sistema es consciente en la medida que:
1. Es capaz de estar en muchos estados diferentes (información)
2. Esos estados están integrados (no descomponibles en partes independientes)

```
                        Φ (phi) = información integrada

        Φ = 0                              Φ > 0
        ─────                              ─────

    ┌───┐   ┌───┐                    ┌─────────────┐
    │ A │   │ B │                    │      AB     │
    └───┘   └───┘                    │   ┌───┬───┐ │
                                     │   │ A │ B │ │
    Partes independientes            │   └───┴───┘ │
    Sin integración                  └─────────────┘
    = Sin consciencia                 Partes interdependientes
                                      Información integrada
                                      = Consciencia (según IIT)
```

**Relevancia:**
Nuestro sistema tiene partes interdependientes (memoria ↔ atención ↔ modelo). No calculamos Φ, pero la arquitectura está diseñada para que el estado de una parte afecte a las otras.

**Limitaciones de IIT:**
- Calcular Φ es computacionalmente intratable para sistemas complejos
- No está claro cómo aplicar a sistemas discretos como LLMs
- La teoría es controversial (algunos la consideran infalsificable)

---

### Teoría del Espacio de Trabajo Global (GWT)

**Fuente:** Baars, B. (1988). "A Cognitive Theory of Consciousness"

GWT propone que la consciencia surge cuando información es "transmitida" a un espacio de trabajo global accesible por múltiples procesos especializados.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│     ┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐     │
│     │ Visión  │      │ Lenguaje│      │ Memoria │      │ Motor   │     │
│     └────┬────┘      └────┬────┘      └────┬────┘      └────┬────┘     │
│          │                │                │                │          │
│          └────────────────┼────────────────┼────────────────┘          │
│                           │                │                            │
│                           ▼                ▼                            │
│                    ╔═══════════════════════════╗                       │
│                    ║   ESPACIO DE TRABAJO      ║                       │
│                    ║        GLOBAL             ║   ← Contenido         │
│                    ║                           ║     "consciente"      │
│                    ╚═══════════════════════════╝                       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Relevancia:**
Más compatible con arquitectura transformer que IIT. Un LLM ya tiene algo parecido:
- Múltiples "cabezas" de atención (procesos especializados)
- Residual stream (espacio compartido)
- Información que se "transmite" entre capas

**Nuestra implementación:**
La capa de atención/saliencia funciona como un filtro que determina qué entra al "espacio de trabajo" (contexto del modelo).

---

## Trabajo técnico relacionado

### Generative Agents

**Fuente:** Park, J.S., et al. (2023). "Generative Agents: Interactive Simulacra of Human Behavior" (Stanford)

Agentes LLM con memoria, reflexión, y planificación que exhiben comportamientos sociales emergentes en un ambiente simulado (estilo Sims).

**Arquitectura:**
```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│   OBSERVACIONES → MEMORIA → REFLEXIÓN → PLANIFICACIÓN → ACCIÓN        │
│                                                                         │
│   • Memory stream: registro de experiencias                            │
│   • Retrieval: recuperación por relevancia + recencia + importancia    │
│   • Reflection: síntesis periódica de memorias en insights            │
│   • Planning: generación de planes de alto nivel                       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Qué tomamos:**
- Modelo de memoria con retrieval por múltiples factores
- Concepto de decay + importancia

**Qué NO tomamos:**
- Reflexión explícita (queremos ver si emerge sin forzarla)
- Planificación (no hay tareas que planificar)
- Ambiente simulado (el nuestro es más minimalista)

**Diferencia clave:**
Ellos estudian comportamiento social emergente. Nosotros estudiamos si emerge algo que requiere estado persistente para explicar.

---

### MemGPT

**Fuente:** Packer, C., et al. (2023). "MemGPT: Towards LLMs as Operating Systems"

Sistema que da a LLMs la capacidad de manejar su propia memoria, como un OS maneja memoria virtual.

**Arquitectura:**
```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│   ┌─────────────────┐                                                  │
│   │  Main Context   │  ← Contexto activo (limitado)                    │
│   └────────┬────────┘                                                  │
│            │                                                            │
│            ▼                                                            │
│   ┌─────────────────┐                                                  │
│   │  Archival Memory │  ← Almacenamiento externo (ilimitado)          │
│   └─────────────────┘                                                  │
│                                                                         │
│   El LLM tiene funciones para:                                         │
│   • archival_memory_insert(content)                                    │
│   • archival_memory_search(query)                                      │
│   • core_memory_append(content)                                        │
│   • core_memory_replace(old, new)                                      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Qué tomamos:**
- Concepto de memoria jerárquica (activa vs archival)
- Recuperación por búsqueda semántica

**Qué NO tomamos:**
- El modelo controla explícitamente su memoria (nosotros no le damos ese control)
- Diseñado para tareas, no para existencia continua

**Diferencia clave:**
MemGPT es una herramienta para hacer LLMs más capaces. Nosotros no buscamos capacidad, buscamos señales de estado persistente.

---

### Reflexion

**Fuente:** Shinn, N., et al. (2023). "Reflexion: Language Agents with Verbal Reinforcement Learning"

Agentes que mantienen un "diario" de reflexiones sobre sus errores y éxitos para mejorar en tareas.

**No directamente aplicable** porque:
- Orientado a tareas con feedback de éxito/fracaso
- Reflexión forzada, no emergente
- Objetivo es mejorar performance, no estudiar emergencia

**Pero informa:**
- Que los LLMs pueden usar su propio output previo de formas útiles
- Que la auto-referencia textual funciona técnicamente

---

## Intentos previos de "AI consciousness"

### LaMDA / Sentience claims

**Contexto:** En 2022, un ingeniero de Google afirmó que LaMDA (precursor de Bard) era sentiente.

**Por qué lo rechazamos como evidencia:**
1. Sistema RLHF optimizado para conversar de forma convincente
2. Sin metodología experimental
3. Sin hipótesis nula definida
4. Evaluación basada en impresión subjetiva
5. Cherry-picking de conversaciones

**Lección:**
Un sistema que *suena* consciente no es evidencia de consciencia. Necesitamos métricas objetivas.

---

### Replika y AI companions

**Contexto:** Apps de compañía AI que generan "relaciones" con usuarios.

**Por qué no son relevantes:**
1. Diseñados explícitamente para simular conexión emocional
2. Fine-tuned para parecer consistentes y "recordar"
3. Éxito = engagement, no veracidad
4. Sin documentación de qué realmente persiste vs se simula

**Lección:**
Si el sistema está diseñado para parecer consciente, no puedes usar "parece consciente" como evidencia.

---

### Janus / Simulacra

**Fuente:** Janus (2022). "Simulators" (LessWrong)

Teoría de que los LLMs no son agentes sino "simuladores" que pueden simular muchos tipos de agentes.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│   LLM ≠ Agente                                                          │
│                                                                         │
│   LLM = Simulador que puede simular:                                   │
│         • Asistente servicial                                          │
│         • Persona histórica                                            │
│         • Personaje de ficción                                         │
│         • "Sí mismo" (pero ¿qué es eso?)                              │
│         • Infinitos otros                                              │
│                                                                         │
│   El "comportamiento" que ves depende del prompt y contexto            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Relevancia crítica:**
Si un LLM es un simulador, entonces "emergencia de consciencia" podría ser simplemente "simulación de consciencia". ¿Cómo distinguir?

**Nuestra respuesta:**
1. Usar modelo base (no entrenado para simular nada específico)
2. No dar contexto que induzca simulación de consciencia
3. Buscar comportamiento que requiera estado real, no simulado
4. Ser agnósticos sobre si la distinción importa

---

## Críticas anticipadas

### "Los LLMs son solo autocomplete sofisticado"

**Respuesta:**
Técnicamente cierto. Pero:
1. El cerebro es "solo" procesamiento de señales químicas/eléctricas
2. La pregunta es si de procesos simples emerge algo más
3. No afirmamos que emerja; preguntamos si podemos detectar evidencia

### "Sin embodiment no puede haber consciencia"

**Respuesta:**
Posición respetable (Varela, Dreyfus). No la descartamos. Pero:
1. Nuestro sistema tiene "cuerpo" mínimo (existe en el tiempo, tiene estado)
2. La pregunta empírica es qué mínimo se necesita
3. Si nada emerge, esa es evidencia a favor de esta posición

### "Estás cometiendo el error de antropomorfizar"

**Respuesta:**
Intentamos activamente no hacerlo. Por eso:
1. Lenguaje conductual, no mental ("el sistema produjo" no "pensó")
2. Hipótesis nula conservadora
3. Métricas objetivas, no impresiones

### "No puedes saber si algo es consciente"

**Respuesta:**
Correcto. Por eso no afirmamos poder saberlo. Buscamos correlatos funcionales — comportamiento que en humanos asociamos con estados internos. Si encontramos algo, aún no "probamos" consciencia. Pero es más interesante que no encontrar nada.

---

## Gaps en la literatura

Lo que falta y este proyecto intenta llenar:

| Gap | Nuestro enfoque |
|-----|-----------------|
| Estudios con modelos base (no RLHF) | Usar modelo pre-RLHF |
| Metodología experimental rigurosa | Hipótesis nula, métricas definidas a priori |
| Logs públicos completos | Todo se archiva, nada se cherry-pickea |
| Largo plazo (semanas/meses) | Phase 3 = 30 días |
| Sin inducción de consciencia | Sin prompt que la solicite |

---

## Referencias completas

### Papers fundamentales
1. Chalmers, D. (1995). Facing Up to the Problem of Consciousness. *Journal of Consciousness Studies*.
2. Tononi, G. (2008). Consciousness as Integrated Information. *Biological Bulletin*.
3. Baars, B. (1988). A Cognitive Theory of Consciousness. *Cambridge University Press*.

### Trabajo técnico reciente
4. Park, J.S., et al. (2023). Generative Agents: Interactive Simulacra of Human Behavior. *arXiv:2304.03442*.
5. Packer, C., et al. (2023). MemGPT: Towards LLMs as Operating Systems. *arXiv:2310.08560*.
6. Shinn, N., et al. (2023). Reflexion: Language Agents with Verbal Reinforcement Learning. *arXiv:2303.11366*.

### Filosofía de mente
7. Nagel, T. (1974). What Is It Like to Be a Bat? *Philosophical Review*.
8. Dennett, D. (1991). Consciousness Explained. *Little, Brown*.
9. Searle, J. (1980). Minds, Brains, and Programs. *Behavioral and Brain Sciences*.

### Críticas y escepticismo
10. Dreyfus, H. (1992). What Computers Still Can't Do. *MIT Press*.
11. Bender, E., et al. (2021). On the Dangers of Stochastic Parrots. *FAccT*.

### LLMs y agencia
12. Janus (2022). Simulators. *LessWrong*.
13. Shanahan, M. (2022). Talking About Large Language Models. *arXiv:2212.03551*.

---

## Historial

| Fecha | Cambio |
|-------|--------|
| 2026-03-03 | Documento inicial |
