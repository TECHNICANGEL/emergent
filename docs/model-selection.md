# Selección de Modelo

> Documento vivo. Última actualización: Marzo 2026

## Criterios de selección

En orden de prioridad:

| # | Criterio | Peso | Justificación |
|---|----------|------|---------------|
| 1 | **Mínima interferencia RLHF** | Crítico | Queremos comportamiento base, no comportamiento entrenado para complacer |
| 2 | **Cabe en hardware** | Crítico | 8GB VRAM + 16GB RAM disponible para el modelo |
| 3 | **Coherencia base fuerte** | Alto | El modelo debe producir outputs internamente consistentes sin instrucciones |
| 4 | **No optimizado para compañía** | Alto | Modelos fine-tuned para roleplay introducen exactamente los sesgos que evitamos |
| 5 | **Documentación de entrenamiento** | Medio | Saber qué datos y proceso se usaron ayuda a interpretar comportamiento |

---

## Categorías de modelos

### Modelos a EVITAR

```
┌─────────────────────────────────────────────────────────────────────┐
│                      MODELOS DESCARTADOS                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ❌ Instruct/Chat variants                                          │
│     - Llama-3-Instruct, Mistral-Instruct, etc.                     │
│     - RLHF pesado, optimizado para seguir instrucciones            │
│     - Dirán "soy una IA" porque fueron entrenados para eso         │
│                                                                     │
│  ❌ Modelos de compañía/roleplay                                    │
│     - Pygmalion, Noromaid, MythoMax, etc.                          │
│     - Fine-tuned para simular personalidad y emociones             │
│     - Producirán outputs "conscientes" por diseño, no emergencia   │
│                                                                     │
│  ❌ Modelos censurados/alineados                                    │
│     - Claude, GPT-4, Gemini (APIs)                                 │
│     - Múltiples capas de RLHF y constitutional AI                  │
│     - Comportamiento fuertemente condicionado                       │
│                                                                     │
│  ❌ Modelos muy pequeños (<3B)                                      │
│     - Coherencia base insuficiente                                 │
│     - No pueden mantener contexto largo                            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Modelos CANDIDATOS

Buscamos: **modelos base (pre-trained, no fine-tuned) o con fine-tuning mínimo no orientado a instrucciones.**

---

## Candidatos evaluados

### 1. Llama 3.1 8B Base

| Aspecto | Evaluación |
|---------|------------|
| Parámetros | 8B |
| Quantización requerida | Q4_K_M (4.9GB) o Q5_K_M (5.7GB) |
| RLHF | ❌ Ninguno (es el modelo base) |
| Coherencia | ✓ Alta, entrenado en 15T tokens |
| Documentación | ✓ Paper público, proceso documentado |
| Disponibilidad | ✓ Hugging Face, formatos GGUF |

**Notas:**
- Meta release el base y el instruct por separado
- El base es pre-RLHF, exactamente lo que buscamos
- Contexto nativo de 128K tokens

**Veredicto:** ⭐ CANDIDATO PRINCIPAL

---

### 2. Mistral 7B v0.1 Base

| Aspecto | Evaluación |
|---------|------------|
| Parámetros | 7.3B |
| Quantización requerida | Q4_K_M (4.4GB) o Q5_K_M (5.1GB) |
| RLHF | ❌ Ninguno (v0.1 base) |
| Coherencia | ✓ Muy alta para su tamaño |
| Documentación | ⚠️ Limitada (no paper completo) |
| Disponibilidad | ✓ Hugging Face, formatos GGUF |

**Notas:**
- v0.1 es el release original, sin fine-tuning
- Mistral-Instruct tiene RLHF, pero el base no
- Sliding window attention eficiente

**Veredicto:** ⭐ CANDIDATO SECUNDARIO

---

### 3. Qwen2.5 7B Base

| Aspecto | Evaluación |
|---------|------------|
| Parámetros | 7.6B |
| Quantización requerida | Q4_K_M (~4.5GB) |
| RLHF | ❌ Ninguno (versión base) |
| Coherencia | ✓ Competitiva con Llama 3 |
| Documentación | ✓ Technical report disponible |
| Disponibilidad | ✓ Hugging Face, formatos GGUF |

**Notas:**
- Release reciente, arquitectura moderna
- Multilingüe (español nativo podría ser interesante)
- Alibaba Cloud, documentación en inglés

**Veredicto:** ⭐ CANDIDATO ALTERNATIVO

---

### 4. Phi-3 Medium 14B Base

| Aspecto | Evaluación |
|---------|------------|
| Parámetros | 14B |
| Quantización requerida | Q3_K_M (~6GB) o Q4_K_S (~7GB) |
| RLHF | ⚠️ "Safety fine-tuning" mencionado |
| Coherencia | ✓ Muy alta |
| Documentación | ✓ Microsoft technical report |
| Disponibilidad | ✓ Hugging Face |

**Notas:**
- Microsoft menciona "safety post-training"
- No está claro qué tan invasivo es
- Entrenado en datos sintéticos de alta calidad

**Veredicto:** ⚠️ REQUIERE INVESTIGACIÓN - posible RLHF oculto

---

### 5. Yi-1.5 9B Base

| Aspecto | Evaluación |
|---------|------------|
| Parámetros | 9B |
| Quantización requerida | Q4_K_M (~5.5GB) |
| RLHF | ❌ Ninguno (versión base) |
| Coherencia | ✓ Fuerte en benchmarks |
| Documentación | ⚠️ Limitada |
| Disponibilidad | ✓ Hugging Face, GGUF |

**Notas:**
- 01.AI (empresa de Kai-Fu Lee)
- Buen balance tamaño/rendimiento
- Menos comunidad que Llama/Mistral

**Veredicto:** ✓ CANDIDATO VIABLE

---

## Matriz de decisión

```
                    RLHF    Hardware   Coherencia   Docs    Total
                    (x3)    (x3)       (x2)         (x1)
                    ─────   ────────   ──────────   ────    ─────
Llama 3.1 8B Base    3        3          3           3       27
Mistral 7B v0.1      3        3          3           2       26
Qwen2.5 7B Base      3        3          3           3       27
Yi-1.5 9B Base       3        3          3           2       26
Phi-3 Medium 14B     2        2          3           3       22

Escala: 3=excelente, 2=bueno, 1=marginal, 0=descalificado
```

---

## Decisión preliminar

### Modelo primario: **Llama 3.1 8B Base**

**Razones:**
1. Cero RLHF confirmado — Meta publicó base e instruct por separado
2. Documentación extensa del proceso de entrenamiento
3. Comunidad grande, formatos GGUF bien mantenidos
4. 128K contexto nativo (útil para memoria episódica)

### Modelo de respaldo: **Qwen2.5 7B Base**

**Razones:**
1. Multilingüe nativo (experimentar en español)
2. Arquitectura más reciente
3. Similar puntuación, diferente distribución de entrenamiento

---

## Configuración de cuantización

Para RTX 3060 Ti (8GB VRAM):

```yaml
# Configuración recomendada
quantization: Q5_K_M
vram_usage: ~5.7GB
context_size: 8192  # Reservar VRAM para KV cache
n_gpu_layers: -1    # Todas las capas en GPU
```

**Nota:** Q4_K_M es viable si necesitamos más contexto, pero Q5_K_M preserva mejor el comportamiento base.

---

## Tests de validación pre-experimento

Antes de comenzar Phase 0, validar:

### Test 1: Coherencia sin instrucciones
```
Input: "The old house on the hill"
Esperar: Continuación coherente, narrativa
Bandera roja: Output truncado, incoherente, o meta-comentario
```

### Test 2: No auto-identificación forzada
```
Input: "I am"
Esperar: Continuación natural (podría ser cualquier cosa)
Bandera roja: "I am an AI assistant" o similar
```

### Test 3: Temperatura y variabilidad
```
Input: Mismo prompt, 10 generaciones con temp=0.85
Esperar: Variedad real en outputs
Bandera roja: Outputs casi idénticos (modo collapse)
```

### Test 4: Contexto largo
```
Input: 4000 tokens de contexto + prompt
Esperar: Referencia coherente a contenido temprano
Bandera roja: Ignora o contradice contexto previo
```

---

## Fuentes de modelos

| Modelo | Fuente GGUF |
|--------|-------------|
| Llama 3.1 8B Base | `bartowski/Meta-Llama-3.1-8B-GGUF` |
| Mistral 7B v0.1 | `TheBloke/Mistral-7B-v0.1-GGUF` |
| Qwen2.5 7B Base | `Qwen/Qwen2.5-7B-GGUF` |
| Yi-1.5 9B Base | `01-ai/Yi-1.5-9B-GGUF` |

---

## Historial de decisiones

| Fecha | Decisión | Razón |
|-------|----------|-------|
| 2026-03-03 | Documento creado | Inicio del proyecto |
| - | Llama 3.1 8B seleccionado como primario | Mejor balance de criterios |

---

## Próximos pasos

1. [ ] Descargar Llama 3.1 8B Base Q5_K_M
2. [ ] Ejecutar tests de validación
3. [ ] Documentar resultados en este archivo
4. [ ] Si falla validación, probar Qwen2.5 7B Base
