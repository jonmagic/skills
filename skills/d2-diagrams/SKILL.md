---
name: d2-diagrams
description: Create, modify, and render D2 diagrams using the d2 CLI. Use when the user asks for diagrams, architecture visuals, ERDs, sequence diagrams, flowcharts, grid layouts, or any declarative diagramming task. Trigger phrases include "d2 diagram", "create a diagram", "architecture diagram", "sequence diagram", "ERD", "flowchart", "draw", "visualize".
---

# D2 Diagrams

Create, modify, and render diagrams using the [D2 declarative diagramming language](https://d2lang.com).

## Overview

D2 (Declarative Diagramming) is a text-to-diagram scripting language. You write what you want diagrammed, and the D2 CLI generates SVG or PNG images. This skill covers:

- Installing the D2 CLI
- Writing D2 source files (`.d2`)
- Rendering diagrams to SVG/PNG
- All D2 features: shapes, connections, containers, SQL tables, UML classes, sequence diagrams, grid diagrams, icons, themes, styles, variables, globs, layers, scenarios, and steps

## When to Use

- User asks to create or modify any kind of diagram
- Architecture diagrams, system designs, network topologies
- Entity-relationship diagrams (ERDs) with SQL tables
- UML class diagrams
- Sequence diagrams for API flows or protocols
- Flowcharts and process diagrams
- Grid layouts for dashboards or comparison tables
- Any request mentioning "d2", "diagram", "visualize", "draw", "architecture"

## Prerequisites: Installing D2

Before creating diagrams, verify D2 is installed:

```bash
d2 version
```

If not installed, install using one of these methods:

### macOS (Recommended: Homebrew)
```bash
brew install d2
```

### Any platform (Install script)
```bash
curl -fsSL https://d2lang.com/install.sh | sh -s --
```

### From source (requires Go 1.20+)
```bash
go install oss.terrastruct.com/d2@latest
```

### Verify installation
```bash
d2 version
```

## Workflow

### Step 1: Write D2 Source

Create a `.d2` file with the diagram definition. Use the language reference in `references/D2_LANGUAGE_REFERENCE.md` for syntax details.

### Step 2: Render the Diagram

```bash
# Render to SVG (default, with padding)
d2 --pad=40 input.d2 output.svg

# Verify width is reasonable (<1400px for laptops)
rg -o 'viewBox="0 0 ([0-9]+)' -r '$1' output.svg

# Render to PNG
d2 --pad=40 input.d2 output.png

# With a specific theme (0-based IDs, use `d2 themes` to list)
d2 --theme=200 input.d2 output.svg

# With dark theme support
d2 --dark-theme=200 input.d2 output.svg

# With sketch/hand-drawn style
d2 --sketch input.d2 output.svg

# With a specific layout engine (dagre, elk, tala)
d2 --layout=elk input.d2 output.svg

# With custom padding (default recommendation is 40)
d2 --pad=60 input.d2 output.svg

# Watch mode (opens browser with live reload)
d2 --watch input.d2 output.svg
```

### Step 3: Iterate

Modify the `.d2` file and re-render. Use `--watch` for interactive development.

## Quick Reference

### Shapes
```d2
# Basic shapes (default is rectangle)
my_shape
labeled_shape: My Label

# Specific shape types
db: Database {shape: cylinder}
user: User {shape: person}
decision: Choice {shape: diamond}
q: Queue {shape: queue}
pg: Package {shape: package}
doc: Document {shape: document}
oval_shape: Oval {shape: oval}
circle_shape: Circle {shape: circle}
hexagon_shape: Hex {shape: hexagon}
cloud_shape: Cloud {shape: cloud}
```

### Connections
```d2
# Arrow types
a -> b: forward
b <- a: backward
a <-> b: bidirectional
a -- b: undirected

# Chaining
a -> b -> c -> d

# Repeated connections create parallel edges
a -> b: first
a -> b: second
```

### Containers (Nesting)
```d2
server: Backend Server {
  api: REST API
  db: Database {shape: cylinder}
  api -> db: queries
}
```

### Styles
```d2
x: Shape {
  style: {
    fill: "#f0f0f0"
    stroke: "#333333"
    stroke-width: 2
    stroke-dash: 5
    border-radius: 8
    shadow: true
    opacity: 0.9
    font-size: 16
    font-color: "#000"
    bold: true
    italic: false
    animated: true
    3d: true
    multiple: true
    double-border: true
    fill-pattern: dots
  }
}
```

### Icons
```d2
server: Backend {
  icon: https://icons.terrastruct.com/essentials%2F112-server.svg
}

# Standalone icon shape
github: GitHub {
  shape: image
  icon: https://icons.terrastruct.com/dev%2Fgithub.svg
}
```

### SQL Tables
```d2
users: {
  shape: sql_table
  id: int {constraint: primary_key}
  name: varchar(255)
  email: varchar(255) {constraint: unique}
  created_at: timestamp
}
```

### Sequence Diagrams
```d2
shape: sequence_diagram
alice -> bob: Hello
bob -> alice: Hi back
alice -> bob: How are you?
bob -> alice: Good, thanks!
```

### Grid Diagrams
```d2
grid: {
  grid-rows: 2
  grid-columns: 3
  cell1: A
  cell2: B
  cell3: C
  cell4: D
  cell5: E
  cell6: F
}
```

### Variables
```d2
vars: {
  primary-color: "#4A90D9"
  server-icon: https://icons.terrastruct.com/essentials%2F112-server.svg
}
server: Backend {
  icon: ${server-icon}
  style.fill: ${primary-color}
}
```

### Globs (Global Patterns)
```d2
# Style all shapes
*.style.fill: "#f0f0f0"
*.style.border-radius: 8

# Style all connections
(* -> *)[*].style.stroke-dash: 3

# Recursive glob
**.style.font-size: 14
```

### Direction
```d2
direction: down  # Recommended default — narrower diagrams
# Options: up, down, left, right
# Use 'right' only for explicitly horizontal flows (timelines, pipelines)

a -> b -> c
```

### Themes

Use `d2 themes` to list available themes. Common theme IDs:
- `0` - Default
- `1` - Neutral default
- `3` - Mixed berry blue
- `4` - Grape soda
- `5` - Aubergine
- `6` - Colorblind clear
- `8` - Vanilla nitro cola
- `100` - Origami
- `200` - Dark Mauve (terminal-style)
- `300` - Terminal (dark, monospace, caps)
- `301` - Terminal Grayscale
- `302` - Retro

Dark themes:
- `200` - Dark Mauve
- `201-208` - Various dark themes

### Composition (Multi-board)
```d2
# Root board
a -> b

# Layers (independent boards)
layers: {
  detail: {
    x -> y -> z
  }
}

# Scenarios (inherit from base)
scenarios: {
  error: {
    a.style.fill: red
    a -> c: error path
  }
}

# Steps (each inherits from previous)
steps: {
  step1: {
    a -> b
  }
  step2: {
    b -> c
  }
}
```

### Classes (Reusable Styles)
```d2
classes: {
  server: {
    shape: rectangle
    style: {
      fill: "#dceefb"
      stroke: "#4A90D9"
      border-radius: 8
    }
  }
  database: {
    shape: cylinder
    style: {
      fill: "#e8f5e9"
      stroke: "#66bb6a"
    }
  }
}

api: API Server {class: server}
db: PostgreSQL {class: database}
api -> db
```

### Arrowheads
```d2
a -> b: {
  source-arrowhead: {
    shape: diamond
  }
  target-arrowhead: {
    shape: arrow
    label: "1..*"
  }
}

# Arrowhead shapes: triangle, arrow, diamond, circle, cf-one, cf-one-required, cf-many, cf-many-required
```

### Markdown and Code in Labels
```d2
explanation: |md
  # Architecture Overview
  - **Frontend**: React SPA
  - **Backend**: Go microservices
  - **Database**: PostgreSQL
|

code_block: |go
  func main() {
    fmt.Println("Hello")
  }
|
```

## Width Control

Diagram width is the most common problem. D2's dagre layout places sibling nodes side-by-side, so diagrams easily exceed screen width. **Always target <1400px wide** for laptop readability.

### Core Principles

1. **Use `direction: down`** (not `right`) as the default. Vertical stacking is narrower.
2. **Minimize sibling nodes at the same depth.** Each peer node adds horizontal width. Chain nodes vertically with connections (`a -> b -> c`) instead of declaring them as siblings.
3. **After every render, verify the SVG width.** D2 doesn't warn about wide output:
   ```bash
   # Check viewBox width (first number after "0 0" is width)
   rg -o 'viewBox="0 0 ([0-9]+)' -r '$1' output.svg
   ```

### The Container Width Problem

Nested containers with multiple children are the #1 source of width explosion. Dagre lays out children horizontally within a container, so a container with 4 children produces 4 columns of width.

**Bad** — 4 children side-by-side, very wide:
```d2
services: Backend {
  api: API Gateway
  auth: Auth Service
  core: Core API
  worker: Worker
}
```

**Better** — use the "titled container + transparent markdown child" pattern. The container label acts as the heading with proper `border-radius`, and a single invisible child holds markdown body text:
```d2
services: Backend Services {
  style.fill: "#e8f5e9"
  style.stroke: "#4caf50"
  style.border-radius: 10

  details: |md
- API Gateway (:3000)
- Auth Service (JWT)
- Core API (business logic)
- Background Worker (cron)
| {
    style.fill: transparent
    style.stroke: transparent
  }
}
```

This pattern keeps the rounded-corner container visual while collapsing all content into a single narrow box.

### Markdown Labels and border-radius

**Gotcha:** When a node's label is markdown (`|md ... |`), D2 renders the content inside a `foreignObject` and the SVG `<rect>` gets `rx="0"` — meaning **`border-radius` is ignored on the outer shape** even if set via class or inline style. Plain-text labels render `border-radius` correctly.

**Workaround:** Use the titled container pattern above. The parent container uses a plain-text label (which gets proper `border-radius`), and the markdown goes in a transparent child node inside it.

### Sequence Diagram Width

Sequence diagram width is proportional to actor count and cannot be controlled by `direction` or layout. The only way to reduce width is to **merge related actors**:

```d2
# Wide — 5 actors
shape: sequence_diagram
user: User
ios: iOS App
llm: On-Device LLM
server: Server
db: Database

# Narrower — 3 actors (merge ios+llm, server+db)
shape: sequence_diagram
user: User
ios: iOS (App + LLM)
server: Server (+ DB)
```

### Other Width Tactics

- **Shorten labels.** Every character counts. Use abbreviations.
- **Use `--pad=40`** to add breathing room without changing layout width.
- **Chain nodes linearly** (`a -> b -> c`) to force dagre to stack them vertically rather than placing them side-by-side.
- If a diagram is still too wide after all optimizations, **split it into two diagrams** rather than fighting the layout engine.

## Known Gotchas

- **`@` prefix is D2 import syntax.** Labels like `@github/copilot-sdk` or `@MainActor` will be interpreted as imports. Wrap in quotes or rephrase: `"@github/copilot-sdk"` or just `Copilot SDK`.
- **Sequence diagrams don't support `style` blocks on connections.** Unlike regular diagrams, you cannot style individual arrows in a sequence diagram — the render will fail. Remove any `style.stroke`, `style.stroke-width`, etc. from sequence diagram connections.
- **Markdown labels lose `border-radius`** on the outer SVG rect (see Width Control above).
- **Dagre layout is non-deterministic for peer nodes.** Re-rendering the same `.d2` file can produce slightly different widths. Always verify after re-rendering.

## Best Practices

1. **Use meaningful keys**: `api_server` not `box1`. Keys become default labels.
2. **Default to `direction: down`**: Vertical layouts fit screens better. Only use `right` for explicitly horizontal flows (timelines, pipelines).
3. **Use the titled container + transparent md child pattern**: For nodes that need both rounded corners and rich content (see Width Control section).
4. **Use classes for consistency**: Define reusable styles with `classes:`.
5. **Use globs for defaults**: Set `*.style.border-radius: 8` instead of styling each shape.
6. **Use variables for colors**: Define a palette in `vars:` for easy theme changes.
7. **Use icons**: Add icons from https://icons.terrastruct.com for professional diagrams.
8. **Choose the right layout**: `dagre` (default) for hierarchical, `elk` for complex graphs.
9. **Keep it readable**: Use nested syntax and indentation for complex diagrams.
10. **Use composition**: Split complex diagrams into layers, scenarios, or steps.
11. **Always render with `--pad=40`**: Gives diagrams breathing room. Default padding is too tight.
12. **Verify width after every render**: Check the SVG viewBox. Target <1400px for laptop screens.

## Rendering Tips

- **Always use `--pad=40`** for comfortable whitespace around diagrams. The default is too tight.
- **Always verify width after rendering:**
  ```bash
  d2 --pad=40 input.d2 output.svg
  rg -o 'viewBox="0 0 ([0-9]+)' -r '$1' output.svg  # should be <1400
  ```
- **SVG is the default and best format** for web embedding and scalability.
- **PNG** is good for embedding in documents, Slack, etc.
- **Use `--theme`** for professional presentation-ready output.
- **Use `--sketch`** for informal, hand-drawn appearance.
- **Animated SVGs**: Use `--animate-interval=1200` with composition for animated diagrams.

## Troubleshooting

- **"d2: command not found"**: D2 is not installed. Follow install instructions above.
- **Layout issues**: Try a different layout engine (`--layout=elk` or `--layout=tala`).
- **Overlapping labels**: Shorten labels, adjust `font-size`, or use a different layout.
- **Missing icons**: Ensure icon URLs are accessible. Use https://icons.terrastruct.com for reliable icons.
- **Diagram too wide**: See the Width Control section. Most likely cause is nested containers with many sibling children.
- **Square corners on markdown boxes**: `border-radius` doesn't apply to `|md ... |` labels. Use the titled container + transparent md child pattern instead.
- **Render fails on sequence diagram styles**: Sequence diagrams don't support `style` blocks on connections. Remove them.
- **`@` interpreted as import**: Quote or rephrase labels containing `@` (e.g., `"@MainActor"`).

## Additional References

- `references/D2_LANGUAGE_REFERENCE.md` - Complete language syntax reference
- `references/D2_PATTERNS.md` - Common diagram patterns and templates
- `assets/` - Example `.d2` template files ready to use
- Official docs: https://d2lang.com/tour/intro/
- Playground: https://play.d2lang.com
- Icons: https://icons.terrastruct.com
