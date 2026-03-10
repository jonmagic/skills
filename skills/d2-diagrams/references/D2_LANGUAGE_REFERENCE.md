# D2 Language Reference

Complete syntax reference for the D2 diagramming language.

## Table of Contents

- [Shapes](#shapes)
- [Connections](#connections)
- [Containers](#containers)
- [Labels](#labels)
- [Styles](#styles)
- [Icons & Images](#icons--images)
- [SQL Tables](#sql-tables)
- [UML Classes](#uml-classes)
- [Sequence Diagrams](#sequence-diagrams)
- [Grid Diagrams](#grid-diagrams)
- [Text & Code Blocks](#text--code-blocks)
- [Classes](#classes)
- [Variables & Substitutions](#variables--substitutions)
- [Globs](#globs)
- [Direction](#direction)
- [Composition](#composition)
- [Arrowheads](#arrowheads)
- [Comments](#comments)
- [CLI Usage](#cli-usage)
- [Themes](#themes)
- [Layout Engines](#layout-engines)

---

## Shapes

### Declaring Shapes

```d2
# Simple (key becomes label)
my_shape

# With explicit label
pg: PostgreSQL

# Multiple on one line
x; y; z

# With shape type
db: Database {shape: cylinder}
```

### Shape Types

| Shape | Keyword |
|-------|---------|
| Rectangle (default) | `rectangle` |
| Square | `square` |
| Circle | `circle` |
| Oval | `oval` |
| Diamond | `diamond` |
| Hexagon | `hexagon` |
| Cloud | `cloud` |
| Cylinder | `cylinder` |
| Queue | `queue` |
| Package | `package` |
| Person | `person` |
| Page | `page` |
| Parallelogram | `parallelogram` |
| Document | `document` |
| Step | `step` |
| Callout | `callout` |
| Stored Data | `stored_data` |
| C4 Person | `c4-person` |
| Image | `image` |
| Text | `text` |
| Code | `code` |
| SQL Table | `sql_table` |
| Class | `class` |
| Sequence Diagram | `sequence_diagram` |

### Special Shape Notes

- `circle` and `square` maintain 1:1 aspect ratio
- `image` requires an `icon` field with a URL
- `text` renders as plain text (no border)
- Keys are **case-insensitive**: `PostgreSQL` and `postgresql` reference the same shape

---

## Connections

### Connection Types

```d2
a -> b    # Directed (forward arrow)
a <- b    # Directed (backward arrow)
a <-> b   # Bidirectional
a -- b    # Undirected (no arrows)
```

### Connection Labels

```d2
a -> b: sends data
```

### Connection Chaining

```d2
a -> b -> c -> d
a -> b: step 1 -> c: step 2
```

### Repeated Connections

Repeated connections create **new** connections (they don't override):

```d2
a -> b: request
a -> b: response
```

### Referencing Connections

```d2
x -> y: hello
# Reference by index (0-based)
(x -> y)[0].style.stroke: red
```

### Cycles

Cycles are fully supported:

```d2
a -> b -> c -> a
```

---

## Containers

### Nested Syntax

```d2
cloud: AWS {
  lb: Load Balancer
  api: API Server
  db: Database {shape: cylinder}
  lb -> api -> db
}
```

### Flat Syntax

```d2
cloud.lb: Load Balancer
cloud.api: API Server
cloud.lb -> cloud.api
```

### Container Labels

```d2
# Shorthand (key becomes label)
cloud: AWS Cloud {
  ...children...
}

# Using label keyword
cloud: {
  label: AWS Cloud
  ...children...
}
```

### Reference Parent

Use `_` to reference the parent scope:

```d2
outer: {
  inner: {
    child
    child -> _.sibling
  }
  sibling
}
```

---

## Labels

### Setting Labels

```d2
# Key becomes label
my_server  # Label: "my_server"

# Explicit label
my_server: Production API

# Label keyword
my_server: {
  label: Production API
}
```

### Markdown Labels

```d2
my_shape: |md
  # Title
  - item 1
  - item 2
  **bold text**
|
```

### LaTeX Labels

```d2
my_shape: |latex
  \\frac{n!}{k!(n-k)!}
|
```

---

## Styles

All styles go under the `style` field:

```d2
shape: {
  style: {
    opacity: 0.5          # 0.0 to 1.0
    stroke: "#333"         # CSS color or hex
    fill: "#f0f0f0"        # CSS color or hex (shapes only)
    fill-pattern: dots     # dots, lines, grain, none (shapes only)
    stroke-width: 2        # 1 to 15
    stroke-dash: 5         # 0 to 10
    border-radius: 8       # 0 to 20
    shadow: true           # true/false (shapes only)
    3d: true               # true/false (rectangle/square only)
    multiple: true         # true/false (shapes only)
    double-border: true    # true/false (rectangles/ovals)
    font: mono             # currently only "mono"
    font-size: 16          # 8 to 100
    font-color: "#000"     # CSS color or hex
    animated: true         # true/false (connections: animated dash)
    bold: true             # true/false
    italic: true           # true/false
    underline: true        # true/false
    text-transform: uppercase  # uppercase, lowercase, title, none
  }
}
```

### Root-Level Styles

```d2
style: {
  fill: "#fafafa"         # Diagram background
  fill-pattern: dots      # Background pattern
  stroke: "#ccc"          # Frame around diagram
  stroke-width: 2
  stroke-dash: 0
  double-border: true     # Double frame
}
```

---

## Icons & Images

### Adding Icons to Shapes

```d2
server: Backend {
  icon: https://icons.terrastruct.com/essentials%2F112-server.svg
}
```

### Standalone Image Shapes

```d2
github: {
  shape: image
  icon: https://icons.terrastruct.com/dev%2Fgithub.svg
}
```

### Local Images

```d2
logo: {
  icon: ./images/logo.png
}
```

### Icon Collection

Free icons at: https://icons.terrastruct.com

Common categories:
- `essentials/` - server, database, cloud, etc.
- `dev/` - GitHub, Docker, AWS, etc.
- `aws/` - AWS service icons
- `gcp/` - GCP service icons
- `azure/` - Azure service icons
- `tech/` - Technology logos

---

## SQL Tables

```d2
users: {
  shape: sql_table
  id: int {constraint: primary_key}
  username: varchar(255) {constraint: unique}
  email: varchar(255) {constraint: unique}
  password_hash: varchar(255)
  created_at: timestamp
  updated_at: timestamp
}

posts: {
  shape: sql_table
  id: int {constraint: primary_key}
  user_id: int {constraint: foreign_key}
  title: varchar(255)
  body: text
  published: boolean
  created_at: timestamp
}

users.id <-> posts.user_id
```

### Constraint Shortcuts

| Full | Short |
|------|-------|
| `primary_key` | PK |
| `foreign_key` | FK |
| `unique` | UNQ |

### Multiple Constraints

```d2
field: type {constraint: [primary_key; unique]}
```

---

## UML Classes

```d2
MyClass: {
  shape: class
  # Fields (no parentheses)
  +public_field: string
  -private_field: int
  #protected_field: float
  
  # Methods (have parentheses)
  +public_method(arg string): bool
  -private_method(): void
  #protected_method(a int, b int): (int, error)
}
```

### Visibility Prefixes

| Prefix | Meaning |
|--------|---------|
| (none) | public |
| `+` | public |
| `-` | private |
| `#` | protected |

---

## Sequence Diagrams

```d2
shape: sequence_diagram

alice
bob
server

alice -> bob: Hello
bob -> server: Check auth
server -> bob: 200 OK
bob -> alice: Authenticated

# Self-message
alice -> alice: Think about it

# Notes (nested object with no connection)
alice: {
  Remember to log out
}
```

### Spans (Activation Boxes)

```d2
shape: sequence_diagram
alice -> bob: request
bob.a -> bob.b: process
bob -> alice: response
```

### Groups (Fragments)

```d2
shape: sequence_diagram
alice
bob

auth: Authentication {
  alice -> bob: login
  bob -> alice: token
}

data: Data Exchange {
  alice -> bob: GET /data
  bob -> alice: response
}
```

### Sequence Diagram Rules

1. Children share the same scope (no duplicate actors)
2. Order matters - definitions appear in order defined
3. Actors don't need explicit declaration (created on first reference)

---

## Grid Diagrams

```d2
my_grid: {
  grid-rows: 3
  grid-columns: 4
  
  # Children fill grid left-to-right, top-to-bottom
  cell1; cell2; cell3; cell4
  cell5; cell6; cell7; cell8
  cell9; cell10; cell11; cell12
}
```

### Grid Keywords

| Keyword | Description |
|---------|-------------|
| `grid-rows` | Number of rows |
| `grid-columns` | Number of columns |
| `grid-gap` | Gap between all cells |
| `vertical-gap` | Vertical gap between rows |
| `horizontal-gap` | Horizontal gap between columns |

### Dominant Direction

The first keyword defined (`grid-rows` or `grid-columns`) determines fill order.

### Grid Tips

- Set `grid-gap: 0` for table-like layouts
- Use `width` and `height` for precise sizing
- Add invisible elements for alignment:
  ```d2
  spacer: "" {style.opacity: 0}
  ```

---

## Text & Code Blocks

### Markdown

```d2
explanation: |md
  # Heading
  - bullet 1
  - bullet 2
  **bold** and *italic*
|
```

### Code

```d2
snippet: |go
  func main() {
    fmt.Println("Hello, D2!")
  }
|
```

### Supported Language Aliases

| Alias | Language |
|-------|----------|
| `md` | markdown |
| `js` | javascript |
| `ts` | typescript |
| `py` | python |
| `rb` | ruby |
| `go` | golang |
| `tex` | latex |

### Block Strings

Use pipes for content containing special characters:

```d2
# Single pipe
label: |content with special chars|

# Double pipe for content containing |
label: ||content with | pipes||

# Triple or custom delimiters
label: |`content with || double pipes`|
```

---

## Classes

```d2
classes: {
  highlight: {
    style: {
      fill: "#ffeb3b"
      stroke: "#f57f17"
      stroke-width: 2
      shadow: true
    }
  }
  muted: {
    style: {
      opacity: 0.5
      stroke-dash: 3
    }
  }
}

important_thing: Critical Component {class: highlight}
background_thing: Legacy System {class: muted}

# Multiple classes (applied left-to-right, later overrides earlier)
both: Both Styles {class: [highlight; muted]}
```

### Connection Classes

```d2
classes: {
  dashed: {
    style.stroke-dash: 5
  }
}

# On declaration
a -> b: optional {class: dashed}

# After declaration
x -> y
(x -> y)[0].class: dashed
```

---

## Variables & Substitutions

### Defining Variables

```d2
vars: {
  primary: "#4A90D9"
  icon-server: https://icons.terrastruct.com/essentials%2F112-server.svg
  fontsize: 14
}
```

### Using Variables

```d2
server: Backend {
  icon: ${icon-server}
  style.fill: ${primary}
  style.font-size: ${fontsize}
}
```

### Nested Variables

```d2
vars: {
  colors: {
    primary: "#4A90D9"
    secondary: "#66bb6a"
  }
}

box: {style.fill: ${colors.primary}}
```

### Variable Scoping

Variables follow lexical scoping - inner scopes can access outer variables, and inner definitions shadow outer ones.

### Spread Substitutions

```d2
vars: {
  common-style: {
    border-radius: 8
    shadow: true
    fill: "#f0f0f0"
  }
}

box: {
  style: {
    ...${common-style}
  }
}
```

### Configuration Variables

```d2
vars: {
  d2-config: {
    theme-id: 200
    dark-theme-id: 200
    pad: 20
    center: true
    sketch: false
    layout-engine: elk
  }
}
```

---

## Globs

### Basic Globs

```d2
# Style all top-level shapes
*.style.fill: "#f0f0f0"

# Style all connections
(* -> *)[*].style.stroke: blue

# Recursive (all shapes at any depth)
**.style.font-size: 14
```

### Glob Connections

```d2
# Connect all shapes to each other (excluding self-connections)
* -> *
```

### Scoped Globs

```d2
container: {
  # Only affects shapes inside this container
  *.style.fill: yellow
  a; b; c
}
```

### Filters

```d2
# Filter by shape type
*: {
  &shape: circle
  style.fill: red
}

# Filter by style property
*: {
  &style.fill: red
  style.stroke: darkred
}

# Property filters
*: {
  &connected: true    # Only shapes with connections
  &leaf: true          # Only non-container shapes
}
```

### Inverse Filters

```d2
# Target everything EXCEPT circles
*: {
  !&shape: circle
  style.fill: blue
}
```

### Global Globs (Triple)

```d2
# Applies across layers and imports
***.style.font-size: 14
```

---

## Direction

```d2
direction: right   # Options: up, down, left, right

a -> b -> c
```

Note: Only TALA supports per-container direction. Dagre and ELK use global direction only.

---

## Composition

### Layers (Independent Boards)

```d2
# Root board
a -> b

layers: {
  detail_view: {
    x -> y -> z
  }
  overview: {
    system_a -> system_b
  }
}
```

### Scenarios (Inherit from Base)

```d2
a -> b: normal flow

scenarios: {
  error: {
    a -> b: normal flow
    a.style.fill: red
    a -> c: error recovery
  }
}
```

### Steps (Inherit from Previous)

```d2
steps: {
  step1: {
    a -> b: initialize
  }
  step2: {
    b -> c: process
  }
  step3: {
    c -> d: complete
  }
}
```

### Animated Export

```bash
d2 --animate-interval=1200 input.d2 output.svg
```

---

## Arrowheads

```d2
a -> b: {
  source-arrowhead: {
    shape: diamond
    style.filled: true
    label: "0..*"
  }
  target-arrowhead: {
    shape: arrow
    label: "1"
  }
}
```

### Arrowhead Shapes

| Shape | Description |
|-------|-------------|
| `triangle` | Default filled triangle |
| `arrow` | Pointier triangle |
| `diamond` | Diamond (can be `filled: true/false`) |
| `circle` | Circle (can be `filled: true/false`) |
| `box` | Square box |
| `cf-one` | Crow's foot: one |
| `cf-one-required` | Crow's foot: exactly one |
| `cf-many` | Crow's foot: many |
| `cf-many-required` | Crow's foot: one or more |
| `cross` | X mark |

---

## Comments

```d2
# This is a line comment

"""
This is a
block comment
"""
```

---

## CLI Usage

### Basic Commands

```bash
# Render (SVG default)
d2 input.d2 output.svg

# Render to PNG
d2 input.d2 output.png

# Watch mode with live reload
d2 --watch input.d2 output.svg

# Format/auto-format a D2 file
d2 fmt input.d2

# List available themes
d2 themes

# List available layouts
d2 layout
```

### Common Flags

| Flag | Description | Default |
|------|-------------|---------|
| `--theme, -t` | Theme ID | 0 |
| `--dark-theme` | Dark mode theme ID | none |
| `--sketch, -s` | Hand-drawn style | false |
| `--layout, -l` | Layout engine | dagre |
| `--pad` | Padding around diagram | 100 |
| `--center` | Center the diagram | false |
| `--animate-interval` | Animation interval (ms) | 0 |
| `--watch, -w` | Watch for changes | false |
| `--browser` | Open browser in watch mode | true |
| `--bundle` | Bundle for SVG (self-contained) | true |
| `--force-appendix` | Add appendix for tooltips | false |

---

## Themes

### Setting Themes

```bash
# CLI flag
d2 --theme=200 input.d2 output.svg

# Environment variable
D2_THEME=200 d2 input.d2 output.svg

# In D2 source
vars: {
  d2-config: {
    theme-id: 200
  }
}
```

### Theme IDs

**Light themes:**
- `0` - Default
- `1` - Neutral default  
- `3` - Mixed berry blue
- `4` - Grape soda
- `5` - Aubergine
- `6` - Colorblind clear
- `8` - Vanilla nitro cola
- `100` - Origami
- `101-104` - Various light themes

**Dark themes:**
- `200` - Dark Mauve
- `201-208` - Various dark themes

**Special themes:**
- `300` - Terminal (monospace, caps, dot pattern)
- `301` - Terminal Grayscale
- `302` - Retro

### Custom Theme Overrides

```d2
vars: {
  d2-config: {
    theme-id: 300
    theme-overrides: {
      B1: "#1a1a2e"
      B2: "#16213e"
      B3: "#0f3460"
      B4: "#533483"
      B5: "#e94560"
      B6: "#a8e6cf"
    }
  }
}
```

---

## Layout Engines

### Dagre (Default)

- Fast, hierarchical layout
- Based on Graphviz's DOT algorithm
- Good for most diagrams
- Does NOT support ancestor-to-descendant connections

```bash
d2 --layout=dagre input.d2 output.svg
```

### ELK

- More mature, better maintained
- Supports `width` and `height` on containers
- Supports `border-radius` on connections
- Academic research team maintains it

```bash
d2 --layout=elk input.d2 output.svg
```

### TALA

- Purpose-built for software architecture diagrams
- Supports per-container `direction`
- Supports `near` set to another object
- Supports `top` and `left` for position locking
- Requires separate installation

```bash
d2 --layout=tala input.d2 output.svg
```
