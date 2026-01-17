/**
 * MCP Server - serves design specs and tool endpoints for AI agents
 * 
 * Run with ts-node:   npx ts-node src/mcp/mcp-server.ts
 * Run compiled:       node dist/mcp/mcp-server.js
 * 
 * JWT Secret Rotation:
 *   1. Generate new secret: openssl rand -base64 32
 *   2. Update JWT_SECRET in infra/.env
 *   3. Restart backend service
 *   4. Old tokens will be invalidated; users must re-authenticate
 * 
 * Sentry Integration:
 *   1. Create project at sentry.io
 *   2. Set SENTRY_DSN in infra/.env
 *   3. Restart backend to enable error tracking
 */

import Fastify, { FastifyRequest, FastifyReply } from 'fastify';
import * as fs from 'fs';
import * as path from 'path';

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

// Load MCP manifest on startup
const manifestPath = path.join(__dirname, '../../../mcp/manifest.json');
let mcpManifest: Record<string, unknown> = {};
try {
    mcpManifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
    console.log('[MCP] Manifest loaded:', Object.keys(mcpManifest));
} catch (err) {
    console.warn('[MCP] Manifest not found, using defaults');
}

// =============================================================================
// Sensitive Keys to Redact in Audit Logs
// =============================================================================
const SENSITIVE_KEYS = ['password', 'receipt', 'token', 'jwt', 'authorization', 'ssn', 'secret'];

function redactSensitiveFields(obj: Record<string, unknown>): Record<string, unknown> {
    const redacted: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(obj)) {
        const lowerKey = key.toLowerCase();
        if (SENSITIVE_KEYS.some(k => lowerKey.includes(k))) {
            redacted[key] = '[REDACTED]';
        } else if (typeof value === 'object' && value !== null) {
            redacted[key] = redactSensitiveFields(value as Record<string, unknown>);
        } else {
            redacted[key] = value;
        }
    }
    return redacted;
}

// =============================================================================
// Audit Logger - writes newline-delimited JSON to logs/mcp-audit.log
// =============================================================================
function auditLog(
    method: string,
    path: string,
    toolId: string | null,
    caller: string,
    input: Record<string, unknown>
): void {
    const record = {
        timestamp: new Date().toISOString(),
        method,
        path,
        toolId,
        caller,
        input: redactSensitiveFields(input)
    };

    const line = JSON.stringify(record) + '\n';

    try {
        fs.appendFileSync(AUDIT_LOG_PATH, line);
    } catch (err) {
        console.error('[AUDIT] Failed to write audit log:', err);
    }
}

// Extract caller ID from Authorization header (first 20 chars or 'anonymous')
function extractCaller(authHeader?: string): string {
    if (!authHeader) return 'anonymous';
    // Store only prefix of token for privacy
    const token = authHeader.replace(/^Bearer\s+/i, '');
    return token.substring(0, 20) + (token.length > 20 ? '...' : '');
}

// =============================================================================
// Rate Limiter (in-memory)
// NOTE: For clustered deployments, replace with Redis-based rate limiting
// =============================================================================
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();

function checkRateLimit(clientId: string): { allowed: boolean; remaining: number } {
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
// Input Validation Placeholder
// NOTE: Install ajv for JSON Schema validation: npm install ajv
// Example usage:
//   const Ajv = require('ajv');
//   const ajv = new Ajv();
//   const validate = ajv.compile(schema);
//   if (!validate(data)) { return reply.status(400).send({ error: validate.errors }); }
// =============================================================================
function validateToolInput(toolId: string, input: unknown): { valid: boolean; error?: string } {
    // Placeholder - implement with ajv for production
    // Find tool schema in manifest and validate
    const tool = (mcpManifest.tools as Array<{ id: string; inputSchema: unknown }>)?.find(t => t.id === toolId);

    if (!tool) {
        return { valid: false, error: `Unknown tool: ${toolId}` };
    }

    // Basic type check
    if (typeof input !== 'object' || input === null) {
        return { valid: false, error: 'Input must be a JSON object' };
    }

    return { valid: true };
}

// =============================================================================
// Fastify Server Setup
// =============================================================================
const app = Fastify({ logger: true });

// Audit + Rate Limit middleware
app.addHook('preHandler', async (request: FastifyRequest, reply: FastifyReply) => {
    const caller = extractCaller(request.headers.authorization);

    // Rate limiting
    const { allowed, remaining } = checkRateLimit(caller);
    reply.header('X-RateLimit-Limit', RATE_LIMIT);
    reply.header('X-RateLimit-Remaining', remaining);

    if (!allowed) {
        return reply.status(429).send({ error: 'Rate limit exceeded' });
    }

    // Audit logging for tool endpoints
    if (request.url.startsWith('/tools/') || request.url === '/design-spec') {
        const toolId = request.url.startsWith('/tools/')
            ? request.url.split('/')[2]
            : 'getDesignSpec';

        auditLog(
            request.method,
            request.url,
            toolId,
            caller,
            (request.body as Record<string, unknown>) || {}
        );
    }
});

// =============================================================================
// Routes
// =============================================================================

// Health check
app.get('/health', async () => {
    return { status: 'ok', timestamp: new Date().toISOString() };
});

// Design spec
app.get('/design-spec', async (request, reply) => {
    const designDir = path.join(__dirname, '../../..', 'design');
    const specPath = path.join(designDir, 'design-spec.json');

    if (!fs.existsSync(specPath)) {
        return reply.status(404).send({ error: 'design-spec.json not found' });
    }

    const content = fs.readFileSync(specPath, 'utf8');
    return JSON.parse(content);
});

// List screens
app.get('/ui', async () => {
    const uiDir = path.join(__dirname, '../../..', 'design/ui-examples');

    if (!fs.existsSync(uiDir)) {
        return { screens: [] };
    }

    const files = fs.readdirSync(uiDir)
        .filter(f => f.endsWith('.json'))
        .map(f => f.replace('.json', ''));

    return { screens: files };
});

// Get screen UI
app.get('/ui/:screen', async (request, reply) => {
    const { screen } = request.params as { screen: string };

    // Validate screen name
    if (!/^[a-zA-Z0-9_-]+$/.test(screen)) {
        return reply.status(400).send({ error: 'Invalid screen name' });
    }

    const uiPath = path.join(__dirname, '../../..', 'design/ui-examples', `${screen}.json`);

    if (!fs.existsSync(uiPath)) {
        return reply.status(404).send({ error: `Screen '${screen}' not found` });
    }

    const content = fs.readFileSync(uiPath, 'utf8');
    return JSON.parse(content);
});

// Execute tool
app.post('/tools/:toolId', async (request, reply) => {
    const { toolId } = request.params as { toolId: string };
    const input = (request.body || {}) as Record<string, unknown>;

    // Validate input
    const validation = validateToolInput(toolId, input);
    if (!validation.valid) {
        return reply.status(400).send({ error: validation.error });
    }

    // Tool execution
    switch (toolId) {
        case 'getDesignSpec': {
            const specPath = path.join(__dirname, '../../..', 'design/design-spec.json');
            const content = fs.readFileSync(specPath, 'utf8');
            return JSON.parse(content);
        }

        case 'listScreens': {
            const uiDir = path.join(__dirname, '../../..', 'design/ui-examples');
            const files = fs.readdirSync(uiDir).filter(f => f.endsWith('.json'));
            return { screens: files.map(f => f.replace('.json', '')) };
        }

        case 'getScreenComponents': {
            const screenName = input.screen as string;
            const screenPath = path.join(__dirname, '../../..', 'design/ui-examples', `${screenName}.json`);
            if (!fs.existsSync(screenPath)) {
                return reply.status(404).send({ error: 'Screen not found' });
            }
            return JSON.parse(fs.readFileSync(screenPath, 'utf8'));
        }

        case 'logWorkout': {
            // Stub - would save to database
            return {
                success: true,
                workoutId: `w_${Date.now()}`,
                message: 'Workout logged successfully'
            };
        }

        case 'purchaseSticker': {
            // Stub - would integrate with IAP receipt validation
            return {
                success: true,
                stickerId: input.stickerId,
                message: 'Sticker purchase simulated (IAP not implemented)',
                coinsRemaining: 200
            };
        }

        default:
            return reply.status(404).send({ error: `Tool '${toolId}' not found` });
    }
});

// =============================================================================
// Start Server
// =============================================================================
const start = async (): Promise<void> => {
    try {
        await app.listen({ port: PORT, host: '0.0.0.0' });
        console.log(`[MCP] Server running on http://localhost:${PORT}`);
        console.log(`[MCP] Endpoints: GET /health, GET /design-spec, GET /ui, POST /tools/:toolId`);
        console.log(`[MCP] Rate limit: ${RATE_LIMIT} requests/minute`);
        console.log(`[MCP] Audit log: ${AUDIT_LOG_PATH}`);
    } catch (err) {
        app.log.error(err);
        process.exit(1);
    }
};

start();
