/**
 * Gym App MCP Server
 * 
 * A lightweight Express server that serves design specifications
 * and UI examples for development tooling integration.
 * 
 * Endpoints:
 *   GET /design-spec  -> design/design-spec.json
 *   GET /ui/home      -> design/ui-examples/home.json
 *   GET /health       -> Health check
 * 
 * Default port: 3845
 */

const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3845;

// Paths relative to project root (one level up from mcp/)
const PROJECT_ROOT = path.join(__dirname, '..');
const DESIGN_SPEC_PATH = path.join(PROJECT_ROOT, 'design', 'design-spec.json');
const UI_EXAMPLES_DIR = path.join(PROJECT_ROOT, 'design', 'ui-examples');

// Middleware
app.use(express.json());

// CORS for local development
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// GET /design-spec
app.get('/design-spec', (req, res) => {
    try {
        if (!fs.existsSync(DESIGN_SPEC_PATH)) {
            return res.status(404).json({ error: 'design-spec.json not found' });
        }

        const content = fs.readFileSync(DESIGN_SPEC_PATH, 'utf8');
        const data = JSON.parse(content);
        res.json(data);
    } catch (err) {
        console.error('Error reading design-spec.json:', err.message);
        res.status(500).json({ error: 'Failed to read design spec' });
    }
});

// GET /ui/:screen (e.g., /ui/home)
app.get('/ui/:screen', (req, res) => {
    const screen = req.params.screen;
    const filePath = path.join(UI_EXAMPLES_DIR, `${screen}.json`);

    try {
        if (!fs.existsSync(filePath)) {
            return res.status(404).json({ error: `UI example '${screen}' not found` });
        }

        const content = fs.readFileSync(filePath, 'utf8');
        const data = JSON.parse(content);
        res.json(data);
    } catch (err) {
        console.error(`Error reading ui-examples/${screen}.json:`, err.message);
        res.status(500).json({ error: `Failed to read UI example '${screen}'` });
    }
});

// List available UI examples
app.get('/ui', (req, res) => {
    try {
        if (!fs.existsSync(UI_EXAMPLES_DIR)) {
            return res.json({ screens: [] });
        }

        const files = fs.readdirSync(UI_EXAMPLES_DIR)
            .filter(f => f.endsWith('.json'))
            .map(f => f.replace('.json', ''));

        res.json({ screens: files });
    } catch (err) {
        console.error('Error listing UI examples:', err.message);
        res.status(500).json({ error: 'Failed to list UI examples' });
    }
});

// Start server
app.listen(PORT, () => {
    console.log('');
    console.log('╔════════════════════════════════════════════════╗');
    console.log('║         Gym App MCP Server                     ║');
    console.log('╠════════════════════════════════════════════════╣');
    console.log(`║  🚀 Running on http://localhost:${PORT}          ║`);
    console.log('║                                                ║');
    console.log('║  Endpoints:                                    ║');
    console.log('║    GET /health       - Health check            ║');
    console.log('║    GET /design-spec  - Design specification    ║');
    console.log('║    GET /ui           - List UI examples        ║');
    console.log('║    GET /ui/:screen   - Get UI example          ║');
    console.log('║                                                ║');
    console.log('║  Press Ctrl+C to stop                          ║');
    console.log('╚════════════════════════════════════════════════╝');
    console.log('');
});
