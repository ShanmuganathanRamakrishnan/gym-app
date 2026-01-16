# Gym App

A mobile-first fitness tracking application built with Flutter.

## Project Structure

```
├── lib/              # Flutter app source code (safe to edit)
├── design/           # Design specs and UI examples (safe to edit)
├── docs/             # Component documentation (safe to edit)
├── tools/            # Dev utilities (md-to-json converter)
├── mcp/              # Local MCP server for dev tooling
└── .github/          # CI workflows
```

## Getting Started

### Prerequisites

- Flutter SDK >= 2.18.0
- Node.js >= 16.x (for MCP server and tools)

### Run the Flutter App

```bash
flutter pub get
flutter run
```

### Run the MCP Server

The MCP server serves design specs and UI examples on `localhost:3845`.

```bash
cd mcp
npm install
npm start
```

**Endpoints:**
- `GET /design-spec` → Returns `design/design-spec.json`
- `GET /ui/home` → Returns `design/ui-examples/home.json`

### Regenerate Design Spec from Docs

Extract component definitions from Markdown docs:

```bash
node tools/md-to-json.js docs > design/design-spec.json
```

## Token Configuration

For GitHub MCP integration, use a fine-grained personal access token.

- **Suggested token name:** `mcp-gym-app-dev`
- **Do NOT commit tokens.** Store them in environment variables or `.env` files (already in `.gitignore`).

## Editable Paths

These directories are safe to edit during development:

| Path | Purpose |
|------|---------|
| `lib/` | Flutter app code |
| `design/` | Design contract JSON |
| `docs/` | Component documentation (Markdown) |

## Adding Dependencies

Edit `pubspec.yaml` to add packages. Suggested future additions:

- `flutter_riverpod` for state management
- `go_router` for navigation
- `dio` for HTTP requests

## License

MIT © Student Developer
