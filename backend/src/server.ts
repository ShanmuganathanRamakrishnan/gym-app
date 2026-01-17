// Backend entry point - starts Fastify server with API and MCP routes
import Fastify from 'fastify';
import cors from '@fastify/cors';
import pino from 'pino';
import { workoutsRoutes } from './api/workouts';
import { mcpRoutes } from './mcp/mcp-server';

const logger = pino({
    level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
    transport: process.env.NODE_ENV !== 'production' ? {
        target: 'pino-pretty',
        options: { colorize: true }
    } : undefined
});

const app = Fastify({
    logger: true,
    requestIdHeader: 'x-request-id',
    requestIdLogLabel: 'requestId'
});

// Register plugins
app.register(cors, { origin: true });

// Health check endpoint
app.get('/health', async () => ({ status: 'ok', timestamp: new Date().toISOString() }));

// Simple metrics stub (Prometheus-compatible placeholder)
app.get('/metrics', async () => {
    return `# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",status="200"} 0
`;
});

// Register routes
app.register(workoutsRoutes, { prefix: '/api' });
app.register(mcpRoutes);

// Start server
const PORT = parseInt(process.env.PORT || '3845', 10);

const start = async (): Promise<void> => {
    try {
        await app.listen({ port: PORT, host: '0.0.0.0' });
        logger.info(`Server running on http://localhost:${PORT}`);
        logger.info(`MCP endpoints: GET /design-spec, GET /ui/:screen`);
    } catch (err) {
        app.log.error(err);
        process.exit(1);
    }
};

start();
