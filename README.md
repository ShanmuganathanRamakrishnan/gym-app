# Gym App

A mobile-first fitness tracking application built with Flutter, powered by a Node.js backend and MCP-enabled development tooling.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Mobile | Flutter + Riverpod + go_router |
| Backend | Node.js + TypeScript + Fastify |
| Database | PostgreSQL (Supabase) |
| Cache | Redis |
| Storage | MinIO (S3-compatible) |
| Auth | Supabase Auth |
| CI/CD | GitHub Actions |

---

## Setup

### Prerequisites

- Flutter SDK >= 3.16.0
- Node.js >= 20.x
- Docker & Docker Compose
- Git

### Environment Variables

Use `infra/local.env.example` → copy to `infra/.env` and replace placeholders.  
**⚠️ Do NOT commit `infra/.env`.**

```bash
cp infra/local.env.example infra/.env
```

Required variables (see `local.env.example` for full list):

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string |
| `JWT_SECRET` | Secret for JWT signing (min 32 chars) |
| `S3_ENDPOINT` | MinIO/S3 endpoint URL |
| `MCP_RATE_LIMIT_PER_MINUTE` | Rate limit for MCP endpoints |
| `SENTRY_DSN` | Sentry error tracking (optional) |

---

## Run Locally

### 1. Start Infrastructure (Docker)

```bash
docker-compose -f infra/docker-compose.yml up -d
```

Services started:
- PostgreSQL on port 5432
- Redis on port 6379
- MinIO on port 9000 (console: 9001)
- Backend on port 3845

To stop:
```bash
docker-compose -f infra/docker-compose.yml down
```

### 2. Run Backend (Development)

```bash
cd backend
npm ci
npm run dev
```

Backend runs on `http://localhost:3845`

**MCP Endpoints:**
- `GET /health` → Health check
- `GET /design-spec` → Design contract JSON
- `GET /ui` → List screens
- `GET /ui/:screen` → UI example for screen
- `POST /tools/:toolId` → Execute MCP tool

### 3. Run Flutter App

```bash
cd app
flutter pub get
flutter run
```

### 4. Regenerate Design Spec

```bash
node tools/md-to-json.js docs > design/design-spec.json
```

### 5. Seed Database

```bash
DB_URL=postgresql://postgres:postgres@localhost:5432/gymapp node scripts/seed-db.js
```

---

## Release Checklist

See [release/checklist.md](release/checklist.md) for full store submission checklist.

### Key Requirements

- **App Store / Play Store IAP**: All digital goods must use in-app purchase
- **Privacy Policy**: Required URL in app stores
- **Signing**: iOS requires provisioning profiles; Android requires keystore

---

## Secrets Management

1. **Local Dev**: Use `infra/.env` (gitignored)
2. **CI/CD**: Use GitHub Secrets
3. **Rotation**: Rotate JWT_SECRET quarterly
4. **Never**: Hardcode secrets in source code

### JWT Secret Rotation

1. Generate new secret: `openssl rand -base64 32`
2. Update `JWT_SECRET` in `infra/.env`
3. Restart backend service
4. Old tokens will be invalidated

### Enable Sentry

1. Create project at sentry.io
2. Set `SENTRY_DSN` in `infra/.env`
3. Restart backend

---

## Development Commands

| Command | Description |
|---------|-------------|
| `flutter analyze` | Run Flutter static analysis |
| `flutter test` | Run Flutter unit tests |
| `npm run lint` | Lint backend TypeScript |
| `npm test` | Run backend tests |
| `npm run build` | Build backend for production |

---

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for full tech stack details.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for coding standards.

## License

MIT © Student Developer
