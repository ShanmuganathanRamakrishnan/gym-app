// Input validators for API and MCP endpoints
import { z } from 'zod';

// Tool input schemas
const toolSchemas: Record<string, z.ZodSchema> = {
    getDesignSpec: z.object({}),
    listScreens: z.object({}),
    getScreenComponents: z.object({
        screen: z.string().min(1).max(50).regex(/^[a-zA-Z0-9_-]+$/)
    }),
    purchaseSticker: z.object({
        stickerId: z.string().uuid(),
        userId: z.string().uuid().optional()
    })
};

export interface ValidationResult {
    valid: boolean;
    error?: string;
}

// Validate tool inputs against schema
export const validateToolInput = (
    toolId: string,
    inputs: Record<string, unknown>
): ValidationResult => {
    const schema = toolSchemas[toolId];

    if (!schema) {
        return { valid: false, error: `Unknown tool: ${toolId}` };
    }

    try {
        schema.parse(inputs);
        return { valid: true };
    } catch (err) {
        if (err instanceof z.ZodError) {
            return { valid: false, error: err.errors.map(e => e.message).join(', ') };
        }
        return { valid: false, error: 'Validation failed' };
    }
};

// Common validators
export const emailSchema = z.string().email();
export const passwordSchema = z.string().min(6).max(100);
export const uuidSchema = z.string().uuid();
