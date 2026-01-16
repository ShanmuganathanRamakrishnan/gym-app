#!/usr/bin/env node

/**
 * md-to-json.js
 * 
 * Parses Markdown component documentation files and extracts
 * component definitions into a JSON format.
 * 
 * Usage:
 *   node tools/md-to-json.js docs > design/design-spec.json
 */

const fs = require('fs');
const path = require('path');

function parseMarkdownFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.split('\n');

    let componentName = '';
    let props = [];
    let variants = [];
    let inPropsSection = false;
    let inVariantsSection = false;

    for (const line of lines) {
        const trimmed = line.trim();

        // Extract component name from H1
        if (trimmed.startsWith('# ')) {
            componentName = trimmed.slice(2).trim();
            // Convert to PascalCase
            componentName = componentName.replace(/[^a-zA-Z0-9]/g, '');
        }

        // Detect sections
        if (trimmed.startsWith('## Props') || trimmed.startsWith('| Prop')) {
            inPropsSection = true;
            inVariantsSection = false;
            continue;
        }

        if (trimmed.startsWith('## Variants')) {
            inVariantsSection = true;
            inPropsSection = false;
            continue;
        }

        if (trimmed.startsWith('## ') && !trimmed.startsWith('## Props') && !trimmed.startsWith('## Variants')) {
            inPropsSection = false;
            inVariantsSection = false;
        }

        // Parse props from table
        if (inPropsSection && trimmed.startsWith('|') && !trimmed.includes('---')) {
            const cells = trimmed.split('|').map(c => c.trim()).filter(c => c);
            if (cells.length >= 1 && cells[0] !== 'Prop' && cells[0] !== 'Token' && cells[0] !== 'Style') {
                props.push(cells[0]);
            }
        }

        // Parse variants from list
        if (inVariantsSection && (trimmed.startsWith('- **') || trimmed.startsWith('- `'))) {
            const match = trimmed.match(/^- \*\*(\w+)\*\*|^- `(\w+)`/);
            if (match) {
                variants.push(match[1] || match[2]);
            }
        }
    }

    const result = { props };
    if (variants.length > 0) {
        result.variants = variants;
    }

    return { name: componentName, data: result };
}

function main() {
    const args = process.argv.slice(2);

    if (args.length === 0) {
        console.error('Usage: node tools/md-to-json.js <docs-directory>');
        console.error('Example: node tools/md-to-json.js docs > design/design-spec.json');
        process.exit(1);
    }

    const docsDir = args[0];

    if (!fs.existsSync(docsDir)) {
        console.error(`Error: Directory "${docsDir}" not found`);
        process.exit(1);
    }

    const files = fs.readdirSync(docsDir).filter(f => f.endsWith('.md'));

    const components = {};

    for (const file of files) {
        const filePath = path.join(docsDir, file);
        const { name, data } = parseMarkdownFile(filePath);

        if (name && name !== 'Theme') {
            components[name] = data;
        }
    }

    // Build the design spec
    const designSpec = {
        theme: {
            bg: '#F7F7F7',
            surface: '#FFFFFF',
            text: '#0A0A0A',
            muted: '#6B6B6B',
            accent: '#00C2A8'
        },
        components,
        screens: {
            Home: ['AppBar', 'WorkoutCard', 'TemplateRow', 'RecentList', 'BottomNav']
        }
    };

    console.log(JSON.stringify(designSpec, null, 2));
}

main();
