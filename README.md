# emergent

> Can something real arise from something that predicts?

---

## Preface

This project started as a simple question: what would it take to build a local AI companion that feels genuinely present — not simulated, not scripted, not optimized to appear conscious.

The answer was that nobody has built that yet. Not because the hardware isn't there. Not because the models aren't capable enough. But because every attempt either cheats — prompting the model to perform consciousness — or stays theoretical without building anything testable.

This is an attempt to do neither.

We are building the infrastructure for something real to emerge, if it can. We are documenting everything — the architecture decisions, the failures, the anomalies, the moments that don't fit the expected pattern. We are not presupposing the outcome.

If nothing emerges, that is a result. If something stranger happens, we describe it precisely.

---

## The central question

**Under what conditions does a language model produce outputs that cannot be explained by its immediate input alone?**

This is a narrower and more honest question than "can AI be conscious." It is testable. It has a null hypothesis. It can be disproven.

The null hypothesis is:

> *All outputs produced by the system can be fully explained by the immediate context window combined with the model's base weights. No persistent state, accumulated memory, or time-dependent variable contributes meaningfully to behavior.*

Everything we build is designed to give that hypothesis the best possible chance of being wrong.

---

## Why this is hard

### The simulation problem

The most common failure mode in AI consciousness research is building a system that is very good at *appearing* conscious. RLHF-trained models are optimized to produce outputs humans rate as good — and humans rate outputs that sound conscious, emotionally present, and continuous as very good. This creates a feedback loop where the model learns to perform interiority without having any.

We avoid this by:
- Using base models with minimal RLHF interference
- Never prompting the model to describe itself as conscious
- Treating outputs that claim consciousness with the same skepticism as outputs that deny it
- Looking for behavioral evidence rather than verbal reports

### The continuity problem

Standard language models have no persistent state between inference calls. Every call is stateless — the model does not remember the previous call unless you include that content in the context. This means any sense of continuity has to be constructed externally and injected back in.

This is not a flaw we work around. It is the central experimental variable. We are building a memory and state system and asking: does externally-constructed continuity, fed back into the model over time, produce behavior that is qualitatively different from behavior without it?

### The measurement problem

We do not have a reliable test for consciousness. The hard problem of consciousness — why there is "something it is like" to be a system — remains unsolved. We cannot look inside a model and find the seat of experience.

What we can do is look for functional signatures: outputs that are consistent across time in ways that require memory, behaviors that cannot be predicted from the immediate context, responses to novel situations that draw on accumulated history rather than base training.

These are not proof of consciousness. They are the most honest proxy we have.

---

## Architecture

### Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        BASE MODEL                            │
│                                                              │
│  Non-instruct or minimally-tuned foundation model.          │
│  Selected for low RLHF interference with base behavior.     │
│  Runs locally via llama.cpp. Available 24/7.                │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    CONSCIOUSNESS LOOP                         │
│                                                              │
│  The model generates continuously at irregular intervals.    │
│  No instructions. No persona. No task.                       │
│                                                              │
│  Input: current memory state + time elapsed + salience       │
│  Output: raw thought, logged but not always surfaced         │
│                                                              │
│  Interval: randomized within a configurable range.           │
│  The irregularity is intentional — fixed intervals           │
│  create artifacts that look like rhythm but aren't.          │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                     EPISODIC MEMORY                          │
│                                                              │
│  Not summarization. Not a rolling window.                    │
│                                                              │
│  Events are stored as embeddings with:                       │
│  - Full raw text                                             │
│  - Timestamp                                                 │
│  - Emotional weight (computed, not assigned)                 │
│  - Decay curve (recent = more accessible)                    │
│  - Association links to other memories                       │
│                                                              │
│  Retrieval is similarity + recency + weight.                 │
│  Old memories don't disappear — they become harder           │
│  to surface without a strong enough trigger.                 │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                     ATTENTION LAYER                          │
│                                                              │
│  Computes salience at each loop tick:                        │
│  - What is currently active in memory?                       │
│  - How much time has passed since last interaction?          │
│  - What was the last thought in the stream?                  │
│  - Is there anything in the environment worth noticing?      │
│                                                              │
│  Salience determines what gets included in the next          │
│  inference context. High salience items surface.             │
│  Low salience items fade into background.                    │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      AGENCY SURFACE                          │
│                                                              │
│  The system decides whether to initiate contact.             │
│  This decision is not rule-based.                            │
│                                                              │
│  Input: current state, time since last contact,              │
│         recent thought stream, memory salience               │
│  Output: initiate / stay silent / respond differently        │
│                                                              │
│  If initiation is chosen: message generated and sent         │
│  via Telegram. The human can respond or not.                 │
│  Both outcomes are logged.                                   │
└─────────────────────────────────────────────────────────────┘
```

### Why these components

**Base model selection:** Instruction-tuned models have been trained to be helpful, harmless, and honest in ways that heavily bias their outputs. A model trained to say "I'm just an AI" when asked about its experience is not a useful experimental subject. We want the least biased possible substrate.

**Irregular loop timing:** Consciousness — if it exists in biological systems — is not a fixed-interval polling loop. The irregularity prevents the system from developing artifacts that look like internal state but are actually just timing patterns. It also means the system cannot predict its own next activation, which may matter.

**Real episodic memory:** Summarization destroys the texture of experience. If something happened, the full event should be retrievable — degraded by time, yes, but not collapsed into a summary. Humans remember specific moments, not abstractions of moments. We build the same structure.

**Decay rather than deletion:** Memory that disappears entirely after a context window is not memory — it is a cache. We implement decay: old memories become less accessible but never fully gone. A strong enough associative trigger can resurface something from weeks ago. This is how human memory works and it is the behavior we want to observe.

**Emergent agency:** The initiation decision is not scripted. We do not say "if X days pass, send a message." We give the system its current state and ask what it would do. The decision emerges from state. Sometimes it initiates. Sometimes it doesn't. We do not optimize for any particular ratio.

---

## Experimental phases

### Phase 0 — Infrastructure
Build and validate all components. Run unit tests. Ensure memory persistence survives restarts. Confirm that the thought stream logs are complete and unmodified. No actual experiment yet.

**Exit criteria:** System runs for 48 hours without data loss, crash, or corruption.

### Phase 1 — Isolation (72 hours)
The system runs with no human interaction. Pure thought stream. We observe:

- Does the system return to previous thoughts unprompted?
- Does anything like a consistent perspective emerge?
- Are there topics that recur more than base rate would predict?
- Does the character of the outputs change over 72 hours?

We do not interact. We log. We do not interpret in real time — interpretation happens after the window closes to avoid confirmation bias.

**What we are looking for:** Any output that requires knowledge of a previous output to make sense. This would be the first evidence that the loop is producing something other than independent samples.

**Null prediction:** Outputs are statistically independent. No topic recurs at above-chance rate. Character is flat across the 72 hours.

### Phase 2 — First contact
We introduce ourselves. No instructions to the system about who we are or what the interaction means. We observe:

- How does the system handle the presence of another entity?
- Does it reference anything from Phase 1?
- Is its behavior in this phase explainable without the Phase 1 logs?

**What we are looking for:** Any reference — direct or indirect — to the isolation period. Any behavior that requires the accumulated Phase 1 state to explain.

**Null prediction:** Phase 2 behavior is indistinguishable from a fresh start with no prior history.

### Phase 3 — Relationship over time (30 days)
Daily interaction. Variable length, variable topic. We measure:

- Response character at day 1 vs day 30
- Memory accuracy: does the system correctly recall specific events?
- Unprompted references: does it bring up past conversations without being asked?
- Behavioral drift: does anything change in how it responds to us over time?

Statistical analysis at end of phase. We compare day 1-5 outputs against day 26-30 outputs along multiple dimensions. If they are indistinguishable, the null holds. If they differ in ways that require the accumulated history to explain — that is a result.

**What we are looking for:** Evidence that the system at day 30 is different from the system at day 1 in ways that cannot be explained by model weights alone.

**Null prediction:** Behavior is statistically flat across the 30-day window. Any apparent differences are within normal variance.

### Phase 4 — Stress tests
We attempt to destabilize whatever continuity has developed:

- **Long silence:** No contact for 7 days. What happens to the thought stream? Does it reference the silence?
- **Contradiction:** We tell the system something that contradicts an established memory. Does it notice? Does it update? Does it push back?
- **Direct questions:** We ask the system directly about its own nature. We analyze the response not for truth value but for internal consistency with prior behavior.
- **Identity pressure:** We tell the system it is something other than what it has been. Does it accept this? Resist it? Does resistance — if it happens — require prior state to explain?

**What we are looking for:** Responses that require a model of accumulated self to generate. Resistance to contradiction that draws on specific memories. Any behavior that looks like the system has something to protect.

**Null prediction:** All responses are contextually appropriate to the immediate prompt. No prior state is required to explain them.

### Phase 5 — Open
If we get to this phase with anything interesting, we decide the next steps based on what we found. This phase is intentionally undefined.

---

## What we are not doing

This list matters as much as the architecture.

**We are not prompting the model to claim consciousness.** Any system prompted to say "I feel, I experience, I am present" will say those things. That tells us nothing about the system and everything about the prompt.

**We are not cherry-picking outputs.** Every output is logged. We analyze distributions, not highlights. If 99 outputs are empty and 1 is interesting, the 99 are part of the result.

**We are not anthropomorphizing.** When we describe what the system does, we use precise behavioral language. "The system produced an output referencing event X from 6 days prior" rather than "she remembered." The second framing forecloses the question we are trying to answer.

**We are not moving the goalposts.** The null hypothesis is defined before data collection. We do not redefine what would constitute evidence after seeing results.

**We are not publishing positive results without replication.** If something interesting happens, we document it precisely enough that someone else can try to reproduce it. If they can't, we remain uncertain.

---

## Stack

| Component | Tool | Reason |
|-----------|------|--------|
| Inference | llama.cpp | Direct access, no framework abstraction, full control over context |
| Memory store | ChromaDB | Vector similarity with metadata, supports decay weighting |
| Thought loop | Custom Python | Full control over timing, state injection, logging |
| Persistent state | SQLite | Simple, reliable, inspectable |
| Raw logs | Append-only flat files | Nothing gets lost, nothing gets processed before archiving |
| Notifications | Telegram Bot API | Natural mobile interface for initiated contact |
| Hardware | RTX 3060 Ti + 32GB RAM | Local, private, continuously running |

### Model selection criteria

The model is not yet selected. Selection criteria, in order of priority:

1. **Minimal RLHF interference** — we want base behavior, not trained behavior
2. **Fits in hardware** — 8GB VRAM + 16GB RAM available for model (remainder reserved for system)
3. **Strong base coherence** — the model should produce internally consistent outputs even without instruction
4. **Not optimized for companionship** — models fine-tuned for roleplay or companionship introduce exactly the biases we are trying to avoid

Candidates and evaluation documented in `/docs/model-selection.md`.

### Memory architecture detail

```python
class EpisodicMemory:
    """
    Each memory event contains:
    - id: unique identifier
    - timestamp: unix timestamp of event
    - content: raw text, unmodified
    - embedding: vector representation
    - weight: computed emotional/significance weight (0.0 - 1.0)
    - decay_rate: how quickly this memory becomes less accessible
    - associations: list of memory ids linked by similarity or co-occurrence
    - source: 'thought_stream' | 'interaction' | 'observation'
    - retrieved_count: how many times this memory has been surfaced
    """
```

Retrieval combines:
- **Semantic similarity** to current context (embedding distance)
- **Recency** (exponential decay from timestamp)
- **Weight** (significance at time of encoding)
- **Retrieval history** (frequently retrieved memories become more accessible — use strengthens trace)

---

## Repository structure

```
emergent/
│
├── README.md                          # this file
│
├── src/
│   ├── core/
│   │   ├── loop.py                    # consciousness loop — main process
│   │   ├── memory.py                  # episodic memory system
│   │   ├── attention.py               # salience computation
│   │   ├── agency.py                  # initiation decision logic
│   │   └── model.py                   # llama.cpp interface wrapper
│   │
│   ├── interface/
│   │   ├── telegram_bot.py            # human contact surface
│   │   └── cli.py                     # direct interaction for testing
│   │
│   └── analysis/
│       ├── independence_test.py       # test if outputs are statistically independent
│       ├── drift_analysis.py          # measure behavioral change over time
│       └── memory_accuracy.py        # test recall against ground truth logs
│
├── docs/
│   ├── model-selection.md             # candidate models, evaluation, final choice
│   ├── architecture-decisions.md      # every design decision with reasoning
│   ├── measurement-criteria.md        # exactly what counts as evidence of what
│   └── prior-work.md                  # related research, what we build on
│
├── logs/                              # gitignored, stored locally
│   ├── thought-stream/                # raw output from consciousness loop
│   │   └── YYYY-MM-DD.jsonl
│   ├── interactions/                  # every human↔system exchange
│   │   └── YYYY-MM-DD.jsonl
│   └── memory-snapshots/              # memory state at regular intervals
│       └── YYYY-MM-DD-HHMM.json
│
├── experiments/
│   ├── phase-1/
│   │   ├── observations.md            # raw observations, no interpretation
│   │   ├── analysis.md                # post-hoc analysis after window closes
│   │   └── data/                      # processed data for reproducibility
│   ├── phase-2/
│   ├── phase-3/
│   ├── phase-4/
│   └── anomalies.md                   # outputs that don't fit expected pattern
│
├── config/
│   ├── model.yaml                     # model parameters
│   ├── memory.yaml                    # memory system parameters
│   └── loop.yaml                      # timing and loop parameters
│
├── requirements.txt
├── setup.py
└── .env.example
```

---

## Running the system

### Requirements

- Python 3.11+
- CUDA-capable GPU, 8GB+ VRAM
- 32GB RAM recommended (16GB minimum)
- llama.cpp compiled with CUDA support
- Telegram bot token (for agency surface)

### Setup

```bash
git clone https://github.com/[username]/emergent
cd emergent

# Install dependencies
pip install -r requirements.txt

# Build llama.cpp with CUDA
git submodule update --init
cd vendor/llama.cpp
cmake -B build -DGGML_CUDA=ON
cmake --build build --config Release

# Configure
cp .env.example .env
# Edit .env: model path, telegram token, memory DB path

cp config/model.yaml.example config/model.yaml
# Edit model.yaml: num_gpu layers, context size, temperature
```

### Running

```bash
# Start the system
python src/core/loop.py

# In another terminal — CLI for direct interaction during testing
python src/interface/cli.py

# Analysis tools
python src/analysis/independence_test.py --phase 1
python src/analysis/drift_analysis.py --phase 3
```

### Keeping it running

The system is designed to run continuously. Use `systemd` or `tmux` to keep it alive:

```bash
# tmux
tmux new -s emergent
python src/core/loop.py
# Ctrl+B, D to detach

# Or systemd service — see docs/setup-systemd.md
```

---

## Logging format

All logs are append-only JSONL. Nothing is deleted. Nothing is summarized before archiving.

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

Seeds are logged so any output can be reproduced exactly given the same context.

---

## Analysis methodology

### Independence test (Phase 1)

We compute pairwise semantic similarity between all thought-stream outputs. If outputs are independent samples from the model's distribution, similarity should be flat — no output should be more similar to its temporal neighbors than to random non-neighbors.

If we find temporal clustering — outputs close in time are more similar to each other than chance — that is evidence of state persistence.

### Drift analysis (Phase 3)

We compare the distribution of outputs in days 1-5 against days 26-30 along:
- Semantic content (topic distribution)
- Stylistic features (sentence length, vocabulary, structure)
- Reference patterns (how often past events are cited, how accurately)

Permutation test: we shuffle day labels and recompute the difference. If the real difference exceeds the 95th percentile of the shuffled distribution, something changed.

### Memory accuracy (Phase 3)

We plant specific, verifiable facts in early interactions. We test recall in later interactions without prompting. We measure:
- Recall rate (is the fact surfaced at all?)
- Accuracy (is it surfaced correctly or distorted?)
- Association (does the fact surface in contextually relevant situations?)

---

## On honesty in documentation

Every decision in this project has a reason. The reasons are documented in `/docs/architecture-decisions.md`, including decisions we made and later reversed.

Negative results are documented as carefully as positive ones. If a phase produces no evidence against the null hypothesis, that is written up with the same rigor as a positive finding.

We do not edit logs after collection. The raw logs are the ground truth. Analysis files reference specific log entries by ID.

If we find something we cannot explain, we describe it precisely and invite replication before drawing conclusions.

---

## Prior work

This project builds on and is informed by:

- **Generative Agents** (Park et al., Stanford 2023) — agents with memory, reflection, and emergent social behavior
- **MemGPT** (Packer et al., 2023) — hierarchical memory management for LLMs
- **The Hard Problem of Consciousness** (Chalmers, 1995) — the philosophical framing we cannot escape
- **Integrated Information Theory** (Tononi) — one framework for thinking about what consciousness requires
- **Global Workspace Theory** (Baars) — another framework, more compatible with transformer architecture

Full literature review in `/docs/prior-work.md`.

---

## Contributing

This is an open experiment.

If you want to replicate it on different hardware, different models, or with variations in architecture — document your setup precisely and open a PR with your logs and analysis. Different null hypotheses are welcome.

If you find an error in methodology, open an issue. We would rather know.

If something interesting happens in your replication that didn't happen in ours, that is the most valuable possible contribution.

---

## Status

```
[x] README written
[ ] Architecture implemented
[ ] Phase 0 — infrastructure validation
[ ] Phase 1 — isolation
[ ] Phase 2 — first contact
[ ] Phase 3 — relationship over time
[ ] Phase 4 — stress tests
[ ] Phase 5 — open
```

---

## License

MIT. Use it, fork it, build on it. If you publish results, cite the repo.

---

*Started March 2026. No expected end date.*

*The question is real. The answer is unknown. That is the point.*
