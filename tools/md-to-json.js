#!/usr/bin/env node

/**
 * MD to JSON Extractor
 * Parses markdown docs and extracts component definitions to JSON
 * 
 * Usage: node tools/md-to-json.js docs > design/design-spec.json
 */

const fs = require('fs');
const path = require('path');

function parseMarkdown(content, filename) {
    const component = {
        name: path.basename(filename, '.md'),
        description: '',
        props: [],
        variants: [],
        notes: []
    };

    const lines = content.split('\n');
    let currentSection = '';

    for (const line of lines) {
        // Title
        if (line.startsWith('# ')) {
            component.name = line.slice(2).trim();
            continue;
        }

        // Section headers
        if (line.startsWith('## ')) {
            currentSection = line.slice(3).trim().toLowerCase();
            continue;
        }

        // Props/properties
        if (currentSection === 'props' || currentSection === 'properties') {
            if (line.startsWith('- ') || line.startsWith('| ')) {
                const prop = line.replace(/^[-|]\s*/, '').split('|')[0].trim();
                if (prop && prop !== 'Name' && prop !== '---') {
                    component.props.push(prop);
                }
            }
        }

        // Variants
        if (currentSection === 'variants') {
            if (line.startsWith('- ')) {
                component.variants.push(line.slice(2).trim());
            }
        }

        // Notes
        if (currentSection === 'notes' || currentSection === 'usage') {
            if (line.startsWith('- ')) {
                component.notes.push(line.slice(2).trim());
            }
        }

        // Description (first paragraph after title)
        if (!currentSection && line.trim() && !line.startsWith('#')) {
            component.description = line.trim();
            currentSection = 'body';
        }
    }

    return component;
}

function main() {
    const docsDir = process.argv[2] || 'docs';

    if (!fs.existsSync(docsDir)) {
        console.error(`Error: Directory '${docsDir}' not found`);
        process.exit(1);
    }

    const files = fs.readdirSync(docsDir).filter(f => f.endsWith('.md'));
    const components = {};

    for (const file of files) {
        const content = fs.readFileSync(path.join(docsDir, file), 'utf8');
        const parsed = parseMarkdown(content, file);
        components[parsed.name] = parsed;
    }

    const output = {
        generated: new Date().toISOString(),
        source: docsDir,
        components
    };

    console.log(JSON.stringify(output, null, 2));
}

main();
