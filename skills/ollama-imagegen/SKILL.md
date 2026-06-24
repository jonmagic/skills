---
name: ollama-imagegen
description: Generate images locally using Ollama's x/z-image-turbo model. Use when the user asks to generate an image, create art, make a picture, or produce a visual. Trigger phrases include "generate an image", "create a picture", "make art", "image of", "draw me", "visualize", "photo of", "illustration of".
---

# Ollama Image Generation

Generate images locally using Ollama and the x/z-image-turbo model. Images are created entirely on-device using Apple Silicon (MLX) — no API keys or cloud services required.

## Prerequisites

- Ollama must be running (`ollama serve` or via brew services)
- Model must be pulled: `ollama pull x/z-image-turbo`

Verify with:
```bash
ollama list | grep z-image-turbo
```

## How to Generate Images

Use the Ollama API to generate images and save them as PNG files. The streaming API returns progress updates followed by a final message with base64-encoded image data in the `image` field.

### Generating and saving an image

```bash
curl -s http://localhost:11434/api/generate \
  -d '{"model": "x/z-image-turbo", "prompt": "YOUR PROMPT HERE"}' | \
  python3 -c "
import sys, json, base64
for line in sys.stdin:
    line = line.strip()
    if line:
        data = json.loads(line)
        if data.get('done') and 'image' in data:
            img = base64.b64decode(data['image'])
            with open('OUTPUT_FILENAME.png', 'wb') as f:
                f.write(img)
            print(f'Image saved: OUTPUT_FILENAME.png ({len(img)} bytes)')
        elif not data.get('done'):
            completed = data.get('completed', 0)
            total = data.get('total', 0)
            if total > 0:
                print(f'Generating: {completed}/{total} steps', end='\r')
"
```

### With custom dimensions and options

```bash
curl -s http://localhost:11434/api/generate \
  -d '{
    "model": "x/z-image-turbo",
    "prompt": "YOUR PROMPT HERE",
    "options": {
      "width": 1024,
      "height": 1024,
      "num_steps": 9,
      "seed": 42
    }
  }' | python3 -c "
import sys, json, base64
for line in sys.stdin:
    line = line.strip()
    if line:
        data = json.loads(line)
        if data.get('done') and 'image' in data:
            img = base64.b64decode(data['image'])
            with open('OUTPUT_FILENAME.png', 'wb') as f:
                f.write(img)
            print(f'Image saved: OUTPUT_FILENAME.png ({len(img)} bytes)')
"
```

## Workflow

1. **Craft the prompt** — Be descriptive. Include style, lighting, composition, and subject details. The model responds well to photographic and artistic terminology.
2. **Choose output path** — Save to the user's current working directory or a specified path. Use a descriptive filename based on the prompt (e.g., `neon-sign-rainy-alley.png`).
3. **Generate** — Use the curl + python3 pipeline above. Generation takes ~15-30 seconds on Apple Silicon.
4. **Report** — Tell the user the file path and size. If in a terminal that supports inline images (Ghostty, iTerm2), the image can also be displayed inline using the kitty graphics protocol or iTerm2 inline images escape sequence.

## Prompt Tips

- **Photorealistic**: Include camera terms — "shot on 35mm film", "natural lighting", "bokeh", "candid"
- **Artistic**: Specify style — "oil painting", "watercolor", "digital art", "pixel art"
- **Text in images**: The model handles bilingual text rendering (English + Chinese) well
- **Negative prompts**: Use the `negative_prompt` option to exclude unwanted elements

### Example prompts

```
A neon sign reading "OPEN 24 HOURS" in a rainy city alley at night, reflections on wet pavement

Young woman in a cozy coffee shop, natural window lighting, wearing a cream knit sweater, holding a ceramic mug, soft bokeh background, shot on 35mm film

Surreal double exposure portrait, woman's silhouette filled with blooming cherry blossom trees, soft pink petals floating, dreamy ethereal atmosphere

Traditional Chinese calligraphy brush painting style, the characters "山高水长" written in elegant black ink on rice paper, red seal stamp in corner
```

## API Response Format

The streaming API returns NDJSON (newline-delimited JSON):

**Progress messages:**
```json
{"model": "x/z-image-turbo", "done": false, "completed": 3, "total": 9}
```

**Final message (contains the image):**
```json
{"model": "x/z-image-turbo", "done": true, "done_reason": "stop", "image": "<base64-encoded PNG>", "total_duration": 14057482542}
```

The `image` field contains the base64-encoded PNG data. Decode and write to file.

## Model Info

- **Name**: x/z-image-turbo (Z-Image Turbo by Alibaba Tongyi Lab)
- **Parameters**: 10.3B (FP8 quantized)
- **Size on disk**: ~12GB
- **Default resolution**: 1024×1024
- **License**: Apache 2.0
- **Generation time**: ~15-30 seconds on M5 Max

## Troubleshooting

- **"libmlxc.dylib not found"**: Ollama needs the MLX library path. Ensure the ollama serve process has `DYLD_LIBRARY_PATH=/opt/homebrew/lib` set (use wrapper script for launchd).
- **Slow first generation**: The model needs ~1s to load into VRAM on first use. Subsequent generations are faster.
- **Large file sizes**: Output PNGs are typically 0.5-1.5MB. For smaller files, reduce dimensions.

## Source Expertise

This skill is grounded in its existing workflow instructions and conventions. It captures the reusable workflow for local image generation with Ollama image models.

No extra reference file is required by default; load source files only when the task needs that context.

## Anchored Workflow

### Deterministic prefix

1. Confirm the user's request matches this skill's scope: local image generation with Ollama image models.
2. Load only the needed local instructions, references, scripts, assets, and source files.
3. Resolve required identifiers, paths, dates, accounts, repositories, or output destinations before drafting or acting.

### AI decision step

Use AI judgment for bounded interpretation: selecting relevant context, classifying the request, drafting the response or artifact, and identifying risks, gaps, or follow-up questions.

### Validation step

Before side effects or completion claims, validate that the output follows this skill's contract, required inputs are present, citations or evidence are attached when needed, and any repo/tool-specific checks have passed or are explicitly reported as unavailable.

### Deterministic suffix

Only after validation, write files, run scripts, call APIs, post messages, create commits, or return the final artifact. Keep side effects scoped to the confirmed task.

## Output Contract

Return the smallest useful artifact for the request. It must include:

1. The concrete result or draft requested by the user.
2. Source paths, links, commands, or evidence when the work depends on retrieved context.
3. Any blocking gaps, assumptions, or validation that could not be completed.
4. A saved file path, commit SHA, rendered artifact, or posted destination when a side effect was explicitly requested and completed.

## Validation Gates

- The frontmatter description must remain scoped to this skill and not trigger on near-miss tasks.
- Required inputs must be explicit before running tools or writing files.
- Generated files or final outputs must match the conventions that apply to the target repository, service, document, or artifact type.
- If validation cannot run, say so directly and do not claim the side effect is complete.

## Tool and Action Safety

- Do not perform destructive, externally visible, or hard-to-reverse actions without explicit approval.
- Do not expose private or sensitive data beyond what the user asked to use.
- Do not silently skip failed tool calls, missing permissions, ambiguous identifiers, or empty result sets.
- No bundled script is required by default.

## Gotchas

- Do not claim image generation succeeded until the local artifact exists.
- Do not broaden this skill into adjacent workflows just because the topic sounds related.
- Preserve the user's communication and git hygiene preferences when drafting, committing, posting, or saving artifacts.

## Examples

Should trigger:

- "generate an image of a robot painting a sunset"

Should not trigger:

- "write a text-only image prompt for another service"
