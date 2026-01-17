# Database Migrations

## Overview

This project uses migration files to manage database schema changes.

## Recommended Tool

Use **node-pg-migrate** for migrations:

```bash
npm install node-pg-migrate
```

## Convention

Migrations are stored in `migrations/` with naming:

```
YYYYMMDDHHMMSS_description.js
```

Example:
- `20260117120000_create_users.js`
- `20260117120100_add_workouts.js`

## Commands

```bash
# Create a new migration
npx node-pg-migrate create add_stickers

# Run migrations
npx node-pg-migrate up

# Rollback last migration
npx node-pg-migrate down
```

## Configuration

Add to `package.json`:

```json
{
  "scripts": {
    "migrate:up": "node-pg-migrate up",
    "migrate:down": "node-pg-migrate down",
    "migrate:create": "node-pg-migrate create"
  }
}
```

Set `DATABASE_URL` environment variable.

## Initial Schema

See `scripts/seed-db.js` for the initial DDL including:
- users
- workouts
- sets
- coins
- purchases
- stickers
