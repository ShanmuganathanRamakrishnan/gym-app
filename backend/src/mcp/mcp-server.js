/**
 * MCP Server - serves design specs and tool endpoints for AI agents
 * 
 * Run with ts-node:   npx ts-node src/mcp/mcp-server.ts
 * Run compiled:       node dist/mcp/mcp-server.js
 * 
 * NOTE: This file requires dependencies to be installed first:
 *   cd backend && npm install
 * 
 * JWT Secret Rotation:
 *   1. Generate new secret: openssl rand -base64 32
 *   2. Update JWT_SECRET in infra/.env
 *   3. Restart backend service
 */

// NOTE: If running without TypeScript compilation, use plain Node.js
// This file can be run standalone with: node backend/src/mcp/mcp-server.js

const express = require('express');
const fs = require('fs');
const path = require('path');

// =============================================================================
// Configuration
// =============================================================================
const PORT = parseInt(process.env.PORT || '3845', 10);
const RATE_LIMIT = parseInt(process.env.MCP_RATE_LIMIT_PER_MINUTE || '60', 10);
const LOG_DIR = path.join(__dirname, '../../logs');
const AUDIT_LOG_PATH = path.join(LOG_DIR, 'mcp-audit.log');

// Ensure logs directory exists
if (!fs.existsSync(LOG_DIR)) {
    fs.mkdirSync(LOG_DIR, { recursive: true });
}

// =============================================================================
// Sensitive Keys to Redact in Audit Logs
// =============================================================================
const SENSITIVE_KEYS = ['password', 'receipt', 'token', 'jwt', 'authorization', 'ssn', 'secret'];

function redactSensitiveFields(obj) {
    if (!obj || typeof obj !== 'object') return obj;

    const redacted = {};
    for (const [key, value] of Object.entries(obj)) {
        const lowerKey = key.toLowerCase();
        if (SENSITIVE_KEYS.some(k => lowerKey.includes(k))) {
            redacted[key] = '[REDACTED]';
        } else if (typeof value === 'object' && value !== null) {
            redacted[key] = redactSensitiveFields(value);
        } else {
            redacted[key] = value;
        }
    }
    return redacted;
}

// =============================================================================
// Audit Logger - writes newline-delimited JSON to logs/mcp-audit.log
// =============================================================================
function auditLog(method, urlPath, toolId, caller, input) {
    const record = {
        timestamp: new Date().toISOString(),
        method,
        path: urlPath,
        toolId,
        caller,
        input: redactSensitiveFields(input || {})
    };

    const line = JSON.stringify(record) + '\n';

    try {
        fs.appendFileSync(AUDIT_LOG_PATH, line);
    } catch (err) {
        console.error('[AUDIT] Failed to write audit log:', err.message);
    }
}

// Extract caller ID from Authorization header (first 20 chars or 'anonymous')
function extractCaller(authHeader) {
    if (!authHeader) return 'anonymous';
    const token = authHeader.replace(/^Bearer\s+/i, '');
    return token.substring(0, 20) + (token.length > 20 ? '...' : '');
}

// =============================================================================
// Rate Limiter (in-memory)
// NOTE: For clustered deployments, replace with Redis-based rate limiting
// =============================================================================
const rateLimitMap = new Map();

function checkRateLimit(clientId) {
    const now = Date.now();
    const entry = rateLimitMap.get(clientId);

    if (!entry || now > entry.resetAt) {
        rateLimitMap.set(clientId, { count: 1, resetAt: now + 60000 });
        return { allowed: true, remaining: RATE_LIMIT - 1 };
    }

    if (entry.count >= RATE_LIMIT) {
        return { allowed: false, remaining: 0 };
    }

    entry.count++;
    return { allowed: true, remaining: RATE_LIMIT - entry.count };
}

// =============================================================================
// Express Server Setup
// =============================================================================
const app = express();
app.use(express.json());

// CORS middleware
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    if (req.method === 'OPTIONS') return res.sendStatus(200);
    next();
});

// Rate limit + audit middleware
app.use((req, res, next) => {
    const caller = extractCaller(req.headers.authorization);

    const { allowed, remaining } = checkRateLimit(caller);
    res.setHeader('X-RateLimit-Limit', RATE_LIMIT);
    res.setHeader('X-RateLimit-Remaining', remaining);

    if (!allowed) {
        return res.status(429).json({ error: 'Rate limit exceeded' });
    }

    // Audit logging for tool endpoints
    if (req.path.startsWith('/tools/') || req.path === '/design-spec') {
        const toolId = req.path.startsWith('/tools/')
            ? req.path.split('/')[2]
            : 'getDesignSpec';

        auditLog(req.method, req.path, toolId, caller, req.body);
    }

    next();
});

// =============================================================================
// Routes
// =============================================================================

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Design spec
app.get('/design-spec', (req, res) => {
    const designDir = path.join(__dirname, '../../..', 'design');
    const specPath = path.join(designDir, 'design-spec.json');

    if (!fs.existsSync(specPath)) {
        return res.status(404).json({ error: 'design-spec.json not found' });
    }

    try {
        const content = fs.readFileSync(specPath, 'utf8');
        res.json(JSON.parse(content));
    } catch (err) {
        res.status(500).json({ error: 'Failed to parse design spec' });
    }
});

// List screens
app.get('/ui', (req, res) => {
    const uiDir = path.join(__dirname, '../../..', 'design/ui-examples');

    if (!fs.existsSync(uiDir)) {
        return res.json({ screens: [] });
    }

    const files = fs.readdirSync(uiDir)
        .filter(f => f.endsWith('.json'))
        .map(f => f.replace('.json', ''));

    res.json({ screens: files });
});

// Get screen UI
app.get('/ui/:screen', (req, res) => {
    const { screen } = req.params;

    if (!/^[a-zA-Z0-9_-]+$/.test(screen)) {
        return res.status(400).json({ error: 'Invalid screen name' });
    }

    const uiPath = path.join(__dirname, '../../..', 'design/ui-examples', `${screen}.json`);

    if (!fs.existsSync(uiPath)) {
        return res.status(404).json({ error: `Screen '${screen}' not found` });
    }

    try {
        const content = fs.readFileSync(uiPath, 'utf8');
        res.json(JSON.parse(content));
    } catch (err) {
        res.status(500).json({ error: 'Failed to parse screen data' });
    }
});

// Execute tool
app.post('/tools/:toolId', (req, res) => {
    const { toolId } = req.params;
    const input = req.body || {};

    switch (toolId) {
        case 'getDesignSpec': {
            const specPath = path.join(__dirname, '../../..', 'design/design-spec.json');
            try {
                const content = fs.readFileSync(specPath, 'utf8');
                return res.json(JSON.parse(content));
            } catch (err) {
                return res.status(500).json({ error: 'Failed to read design spec' });
            }
        }

        case 'listScreens': {
            const uiDir = path.join(__dirname, '../../..', 'design/ui-examples');
            const files = fs.existsSync(uiDir)
                ? fs.readdirSync(uiDir).filter(f => f.endsWith('.json')).map(f => f.replace('.json', ''))
                : [];
            return res.json({ screens: files });
        }

        case 'getScreenComponents': {
            const screenName = input.screen;
            if (!screenName) {
                return res.status(400).json({ error: 'screen parameter required' });
            }
            const screenPath = path.join(__dirname, '../../..', 'design/ui-examples', `${screenName}.json`);
            if (!fs.existsSync(screenPath)) {
                return res.status(404).json({ error: 'Screen not found' });
            }
            try {
                return res.json(JSON.parse(fs.readFileSync(screenPath, 'utf8')));
            } catch (err) {
                return res.status(500).json({ error: 'Failed to parse screen' });
            }
        }

        case 'logWorkout': {
            return res.json({
                success: true,
                workoutId: `w_${Date.now()}`,
                message: 'Workout logged successfully'
            });
        }

        case 'purchaseSticker': {
            return res.json({
                success: true,
                stickerId: input.stickerId,
                message: 'Sticker purchase simulated (IAP not implemented)',
                coinsRemaining: 200
            });
        }

        default:
            return res.status(404).json({ error: `Tool '${toolId}' not found` });
    }
});

// =============================================================================
// Start Server
// =============================================================================
app.listen(PORT, '0.0.0.0', () => {
    console.log(`[MCP] Server running on http://localhost:${PORT}`);
    console.log(`[MCP] Endpoints: GET /health, GET /design-spec, GET /ui, POST /tools/:toolId`);
    console.log(`[MCP] Rate limit: ${RATE_LIMIT} requests/minute`);
    console.log(`[MCP] Audit log: ${AUDIT_LOG_PATH}`);
});
