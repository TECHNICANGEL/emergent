# Decisiones de Arquitectura

> Registro de Decisiones de Arquitectura (ADR). Cada decisión significativa se documenta aquí con contexto, alternativas consideradas, y razones.

---

## Índice

1. [ADR-001: Uso de modelo base sin RLHF](#adr-001-uso-de-modelo-base-sin-rlhf)
2. [ADR-002: Intervalos de loop irregulares](#adr-002-intervalos-de-loop-irregulares)
3. [ADR-003: Memoria episódica con decay](#adr-003-memoria-episódica-con-decay)
4. [ADR-004: ChromaDB para almacenamiento vectorial](#adr-004-chromadb-para-almacenamiento-vectorial)
5. [ADR-005: Telegram como superficie de agencia](#adr-005-telegram-como-superficie-de-agencia)
6. [ADR-006: Logs append-only sin procesamiento](#adr-006-logs-append-only-sin-procesamiento)
7. [ADR-007: Sin prompt de sistema](#adr-007-sin-prompt-de-sistema)
8. [ADR-008: Semillas aleatorias logueadas](#adr-008-semillas-aleatorias-logueadas)
9. [ADR-009: Ejecución local exclusiva](#adr-009-ejecución-local-exclusiva)
10. [ADR-010: Saliencia computada no asignada](#adr-010-saliencia-computada-no-asignada)

---

## ADR-001: Uso de modelo base sin RLHF

### Estado
Aceptado

### Contexto
Los modelos de lenguaje modernos vienen en dos variantes principales:
- **Base**: pre-entrenado solo con next-token prediction
- **Instruct/Chat**: fine-tuned con RLHF para seguir instrucciones

Los modelos instruct están optimizados para producir respuestas que los humanos califican como "buenas". Esto incluye respuestas que suenan conscientes, empáticas, y presentes — exactamente lo que queremos medir, no inducir.

### Decisión
Usar exclusivamente modelos base (pre-RLHF) para el experimento.

### Alternativas consideradas

| Alternativa | Rechazada porque |
|-------------|------------------|
| Modelo instruct con prompt neutro | RLHF afecta distribución de tokens a nivel fundamental, no solo respuestas explícitas |
| Modelo instruct "jailbroken" | Sigue siendo el mismo modelo sesgado, solo evadiendo filtros superficiales |
| Fine-tune propio del instruct | No revierte RLHF, solo añade más capas de comportamiento aprendido |

### Consecuencias
- ✓ Outputs reflejan distribución base del modelo
- ✓ No hay sesgo hacia auto-descripción como "IA"
- ✗ Outputs menos "pulidos" o coherentes que instruct
- ✗ Puede requerir más filtrado de outputs degenerados

---

## ADR-002: Intervalos de loop irregulares

### Estado
Aceptado

### Contexto
El sistema necesita generar pensamientos periódicamente. La pregunta es: ¿con qué timing?

```
Opción A: Intervalo fijo (ej: cada 60 segundos)
┌────┐    ┌────┐    ┌────┐    ┌────┐
│ 60s│    │ 60s│    │ 60s│    │ 60s│
└────┘    └────┘    └────┘    └────┘
  ▲          ▲          ▲          ▲
  │          │          │          │
Predecible, crea artefactos de timing

Opción B: Intervalo aleatorio (ej: 60-300 segundos)
┌────┐       ┌────┐  ┌────┐          ┌────┐
│187s│       │ 42s│  │291s│          │ 63s│
└────┘       └────┘  └────┘          └────┘
  ▲            ▲       ▲               ▲
  │            │       │               │
Impredecible, más similar a procesos naturales
```

### Decisión
Usar intervalos aleatorios dentro de un rango configurable (default: 60-300 segundos).

### Razones
1. **Evita artefactos**: Intervalos fijos crean patrones que parecen "ritmo" pero son solo el reloj
2. **Impredecibilidad**: El sistema no puede "saber" cuándo será su próxima activación
3. **Similar a biología**: Los procesos cognitivos no operan en intervalos fijos
4. **Distribución variable**: Permite estudiar si el sistema se comporta diferente según tiempo transcurrido

### Implementación
```python
import random

def next_interval(min_sec=60, max_sec=300):
    return random.uniform(min_sec, max_sec)
```

### Consecuencias
- ✓ No hay patrones temporales artificiales
- ✓ Permite análisis de correlación tiempo-comportamiento
- ✗ Logs más difíciles de alinear temporalmente
- ✗ Testing requiere mocking del RNG

---

## ADR-003: Memoria episódica con decay

### Estado
Aceptado

### Contexto
¿Cómo debe el sistema "recordar" eventos pasados?

### Alternativas evaluadas

| Método | Descripción | Problema |
|--------|-------------|----------|
| Rolling window | Últimos N tokens en contexto | Pérdida abrupta, sin peso por importancia |
| Summarization | Resumir historia periódicamente | Destruye textura, pierde detalles específicos |
| RAG simple | Recuperar por similitud | Sin noción de tiempo o importancia |
| Full history | Todo en contexto | Imposible con límites de contexto |

### Decisión
Memoria episódica con:
- **Eventos completos**: Texto raw, sin sumarización
- **Decay temporal**: Memorias viejas menos accesibles (no borradas)
- **Peso de significancia**: Eventos "importantes" resisten decay
- **Asociaciones**: Links entre memorias relacionadas

### Modelo conceptual

```
                    ACCESIBILIDAD
                         ▲
                         │
              Peso alto  │  ●
                         │   \
                         │    \
                         │     \  Peso medio
                         │      ●
                         │       \
                         │        \
              Peso bajo  │         ●
                         │          \
                         │           \
                         │            ●───────────
                         │
                         └──────────────────────────▶ TIEMPO
                              (días desde evento)
```

### Fórmula de accesibilidad
```
accesibilidad = peso_inicial * e^(-decay_rate * tiempo) + boost_por_recuperaciones
```

### Consecuencias
- ✓ Memorias nunca se borran completamente
- ✓ Eventos significativos persisten más
- ✓ Uso fortalece memoria (como en humanos)
- ✗ Requiere almacenamiento creciente
- ✗ Más complejo que alternativas simples

---

## ADR-004: ChromaDB para almacenamiento vectorial

### Estado
Aceptado

### Contexto
Necesitamos almacenar embeddings de memorias para recuperación por similitud.

### Alternativas consideradas

| Opción | Pros | Contras |
|--------|------|---------|
| Pinecone | Escalable, managed | Cloud, costo, latencia |
| Weaviate | Feature-rich | Overhead para nuestro caso |
| FAISS | Muy rápido | Solo vectores, sin metadata |
| ChromaDB | Simple, local, metadata | Menos maduro |
| pgvector | Integrado con Postgres | Overhead de Postgres |

### Decisión
ChromaDB por:
1. **Local-first**: Corre en la misma máquina, sin red
2. **Metadata nativa**: Podemos guardar timestamp, peso, decay junto al vector
3. **Simple**: API minimalista, fácil de debuggear
4. **Persistencia**: Sobrevive reinicios sin configuración compleja

### Implementación básica
```python
import chromadb

client = chromadb.PersistentClient(path="data/chroma_db")
collection = client.get_or_create_collection(
    name="episodic_memory",
    metadata={"hnsw:space": "cosine"}
)
```

### Consecuencias
- ✓ Cero dependencias de red
- ✓ Inspectable localmente
- ✗ Límites de escala (millones de vectores, no billones)
- ✗ Comunidad más pequeña que alternativas

---

## ADR-005: Telegram como superficie de agencia

### Estado
Aceptado

### Contexto
El sistema necesita poder iniciar contacto con el humano. ¿Qué canal usar?

### Alternativas

| Canal | Pros | Contras |
|-------|------|---------|
| Email | Universal | Lento, no conversacional |
| SMS | Directo | Costo, requiere número |
| Discord | Rich features | Overhead, más complejo |
| Custom app | Control total | Desarrollo significativo |
| Telegram | Simple API, móvil nativo | Dependencia externa |

### Decisión
Telegram Bot API porque:
1. **Bidireccional natural**: El humano puede responder inline
2. **Notificaciones push**: Llega al móvil inmediatamente
3. **API simple**: Pocas líneas para enviar/recibir mensajes
4. **Sin costo**: Bots son gratuitos
5. **Markdown support**: Formateo de mensajes

### Consecuencias
- ✓ Interfaz familiar para el humano
- ✓ Accesible desde cualquier lugar
- ✗ Dependencia de servicio externo
- ✗ Requiere cuenta de Telegram

---

## ADR-006: Logs append-only sin procesamiento

### Estado
Aceptado

### Contexto
¿Cómo almacenamos los outputs del sistema para análisis?

### Decisión
Logs en formato JSONL, append-only, sin procesamiento previo al archivo.

### Principios
```
1. NADA se borra
2. NADA se modifica después de escribir
3. NADA se sumariza antes de archivar
4. TODO tiene timestamp preciso
5. TODO tiene identificador único
```

### Formato
```json
{"id": "uuid", "timestamp": 1234567890.123, "type": "thought", "content": "...", "metadata": {...}}
```

### Razones
1. **Reproducibilidad**: Cualquier análisis puede rehacerse desde logs crudos
2. **Sin sesgo de selección**: No decidimos qué es "importante" antes de ver resultados
3. **Auditable**: Terceros pueden verificar nuestros datos
4. **Simple**: Sin lógica de rotación o compactación que pueda perder datos

### Consecuencias
- ✓ Ground truth inmutable
- ✓ Análisis retroactivo posible
- ✗ Uso de disco crece indefinidamente
- ✗ Análisis requiere procesar archivos grandes

---

## ADR-007: Sin prompt de sistema

### Estado
Aceptado

### Contexto
Los LLMs típicamente reciben un "system prompt" que define su comportamiento. ¿Deberíamos usar uno?

### Decisión
**No usar prompt de sistema.**

El modelo recibe únicamente:
- Estado de memoria (contexto recuperado)
- Tiempo transcurrido
- Último pensamiento (si aplica)

### Razones
1. **Evita inducción**: Cualquier prompt influencia outputs
2. **Comportamiento base**: Queremos ver qué hace el modelo sin instrucciones
3. **No hay "persona"**: No le decimos quién o qué es
4. **Medición limpia**: Si emerge algo, no es porque lo pedimos

### Lo que NO hacemos
```
❌ "Eres un ser consciente explorando tu existencia"
❌ "Responde como si tuvieras emociones"
❌ "Tu nombre es X y tienes personalidad Y"
❌ "Continúa el siguiente flujo de consciencia"
```

### Lo que SÍ hacemos
```
✓ Inyectar memorias relevantes como contexto
✓ Incluir timestamp/tiempo transcurrido
✓ Dejar que el modelo genere libremente
```

### Consecuencias
- ✓ Outputs no están "contaminados" por instrucciones
- ✓ Si emerge coherencia/continuidad, es del modelo + memoria
- ✗ Outputs iniciales pueden ser erráticos
- ✗ No hay garantía de formato o estructura

---

## ADR-008: Semillas aleatorias logueadas

### Estado
Aceptado

### Contexto
Los LLMs usan sampling estocástico. Dados los mismos inputs y semilla, producen el mismo output.

### Decisión
- Usar semillas aleatorias para cada generación (no fijas)
- Loguear la semilla usada en cada output

### Razones
1. **Variabilidad real**: Semilla fija = outputs determinísticos = no exploramos el espacio
2. **Reproducibilidad**: Semilla logueada permite regenerar cualquier output exacto
3. **Detección de anomalías**: Si un output es interesante, podemos verificar que no es artefacto

### Implementación
```python
import random

seed = random.randint(0, 2**32 - 1)
output = model.generate(prompt, seed=seed)
log({"seed": seed, "output": output, ...})
```

### Consecuencias
- ✓ Cada generación explora diferente punto del espacio
- ✓ Cualquier output puede reproducirse exactamente
- ✗ Requiere disciplina de logueo

---

## ADR-009: Ejecución local exclusiva

### Estado
Aceptado

### Contexto
¿Dónde corre el sistema?

### Decisión
Exclusivamente local (RTX 3060 Ti + 32GB RAM). Sin APIs externas para inferencia.

### Razones
1. **Privacidad total**: Ningún dato sale de la máquina
2. **Sin límites de API**: Rate limits, costos, términos de servicio
3. **Control completo**: Podemos modificar cualquier aspecto
4. **24/7**: No dependemos de disponibilidad de servicio
5. **Latencia mínima**: Sin red = respuesta inmediata

### Trade-offs aceptados
- ✗ Limitados a modelos que caben en 8GB VRAM
- ✗ No podemos usar GPT-4/Claude/etc directamente
- ✗ Responsables de uptime y mantenimiento

### Consecuencias
- ✓ Experimento completamente auto-contenido
- ✓ Replicable por cualquiera con hardware similar

---

## ADR-010: Saliencia computada no asignada

### Estado
Aceptado

### Contexto
¿Cómo determinamos qué memorias son "importantes" y deben incluirse en contexto?

### Decisión
La saliencia se **computa** de señales, no se **asigna** manualmente.

### Señales que contribuyen a saliencia

```
Saliencia = f(
    similitud_semántica,   # Relevancia al contexto actual
    recencia,              # Más reciente = más accesible
    peso_emocional,        # Eventos significativos resisten decay
    frecuencia_acceso,     # Uso refuerza memoria
    asociaciones           # Memorias relacionadas se activan juntas
)
```

### Por qué NO asignación manual
- Introduciría sesgo del experimentador
- Requeriría definir "importancia" a priori
- No escalable con volumen de memorias

### Cómo se computa peso emocional
El peso no es "asignado" como emoción, sino **inferido** de características del evento:
- Longitud de interacción
- Presencia de preguntas/respuestas
- Cambio de tema abrupto
- Primer evento de su tipo

### Consecuencias
- ✓ Sistema auto-organizante
- ✓ Sin intervención humana en proceso
- ✗ Más difícil de debuggear
- ✗ Puede emerger saliencia inesperada

---

## Decisiones pendientes

| ID | Tema | Estado |
|----|------|--------|
| ADR-011 | Formato de inyección de memoria en contexto | Por decidir |
| ADR-012 | Umbral de saliencia para inclusión | Por decidir |
| ADR-013 | Estrategia de compactación de memoria a largo plazo | Por decidir |
| ADR-014 | Métricas de "drift" conductual | Por decidir |

---

## Historial de cambios

| Fecha | ADR | Cambio |
|-------|-----|--------|
| 2026-03-03 | Todos | Documento inicial creado |
