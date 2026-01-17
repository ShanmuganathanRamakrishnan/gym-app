# Gym App - Architecture & Tech Stack

## Part A: Definitive Tech Stack

### Mobile Client
- **Framework**: Flutter (stable channel)
- **State Management**: Riverpod 2.x
- **Navigation**: go_router
- **HTTP Client**: dio
- **Rationale**: Flutter provides cross-platform mobile development with excellent performance. Riverpod offers compile-time safety and testability. go_router aligns with Flutter's declarative navigation patterns.

### Backend / API / MCP Server
- **Runtime**: Node.js 20 LTS
- **Language**: TypeScript 5.x
- **Framework**: Fastify
- **Rationale**: Fastify over Express for better performance, built-in TypeScript support, and schema validation. Node.js is student-friendly with extensive ecosystem.

### Database
- **Primary**: PostgreSQL 15
- **Hosted Option**: Supabase (free tier with Postgres, Auth, Storage)
- **Local Dev**: Docker container
- **Rationale**: Postgres is battle-tested, supports JSON columns for flexible schemas, and Supabase provides a generous free tier perfect for student projects.

### Cache / Session
- **Redis** (optional)
- **Local Dev**: Docker container
- **Use**: Session storage, rate limiting, job queues

### Object Storage
- **S3-Compatible**: MinIO for local dev
- **Production**: Supabase Storage or AWS S3
- **Use**: Stickers, workout images, user avatars

### Authentication
- **Choice**: Supabase Auth
- **Rationale**: Free tier, easy integration, handles JWT, social login, and email auth. Student-friendly with excellent docs. Alternative: Auth0 or Firebase Auth.

### AI / Local Models (Future)
- **Local Experimentation**: llama.cpp with small models (Phi-2, TinyLlama)
- **Tradeoffs**:
  - Local: Privacy, no API costs, works offline; requires device resources
  - Hosted: Better quality, no device load; costs, latency, privacy concerns
- **Recommendation**: Start with hosted OpenAI/Claude for MVP, add local option later

### CI/CD
- **Platform**: GitHub Actions
- **Jobs**: Lint, test, build, deploy previews

### Containerization
- **Docker** + **docker-compose**
- **Services**: Backend, Postgres, Redis, MinIO

### Monitoring
- **Error Tracking**: Sentry (free tier)
- **Metrics**: Prometheus + Grafana (production)
- **Logging**: Structured JSON logs with request-id correlation

### Payments
- **Rule**: iOS/Android require using App Store/Play Store IAP for digital goods
- **Architecture**: Server-side receipt validation via store APIs
- **Implementation**: Deferred to post-MVP

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         MOBILE CLIENT                                │
│                     Flutter App (iOS/Android)                        │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐   │
│  │  Home   │  │Workouts │  │   AI    │  │ Profile │  │  Auth   │   │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘   │
│       └────────────┴────────────┴────────────┴────────────┘         │
│                              │                                       │
│                    MCPClient (HTTP)                                  │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         BACKEND SERVICES                             │
│                                                                      │
│  ┌──────────────────────┐      ┌──────────────────────────────┐     │
│  │   REST API (Fastify) │      │   MCP Server (:3845)         │     │
│  │   /api/workouts      │      │   GET /design-spec           │     │
│  │   /api/users         │      │   GET /ui/:screen            │     │
│  │   /api/auth          │      │   POST /tools/:toolId        │     │
│  └──────────┬───────────┘      └──────────────┬───────────────┘     │
│             │                                  │                     │
│             └──────────────┬───────────────────┘                     │
│                            ▼                                         │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    PostgreSQL Database                       │    │
│  │   users │ workouts │ sets │ coins │ purchases │ stickers    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────────────┐    │
│  │     Redis     │  │     MinIO     │  │   Supabase Auth       │    │
│  │   (cache)     │  │  (S3 storage) │  │   (JWT tokens)        │    │
│  └───────────────┘  └───────────────┘  └───────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘

MCP in Dev vs Prod:
─────────────────────
DEV:  Agent → localhost:3845/mcp → reads design-spec.json, ui-examples
      Used by AI coding assistants to understand UI contracts

PROD: MCP endpoints serve tool definitions for AI features
      Rate-limited, authenticated, audit-logged
```

---

## Security & Privacy Checklist for Release

### Authentication & Authorization
- [ ] JWT tokens with short expiry (15min access, 7d refresh)
- [ ] Secure token storage (flutter_secure_storage)
- [ ] Role-based access control on API endpoints
- [ ] API key rotation mechanism documented

### Transport Security
- [ ] HTTPS only in production (TLS 1.3)
- [ ] Certificate pinning for mobile app
- [ ] HSTS headers on backend

### Data Protection
- [ ] Minimize health data collection (no medical diagnosis)
- [ ] Encrypt PII at rest in database
- [ ] No logging of passwords or tokens
- [ ] Data retention policy documented

### Privacy Compliance
- [ ] Privacy policy URL in app and stores
- [ ] GDPR: data export and deletion endpoints
- [ ] CCPA: opt-out mechanism
- [ ] Age verification (13+ for fitness apps)

### Secrets Management
- [ ] No hardcoded secrets in code
- [ ] Use GitHub Secrets for CI
- [ ] Environment variables for runtime secrets
- [ ] Separate dev/staging/prod credentials

### App Store Requirements
- [ ] In-app purchase for digital goods (coins, stickers)
- [ ] Server-side receipt validation
- [ ] No external payment links for IAP items
- [ ] Health disclaimers if applicable
