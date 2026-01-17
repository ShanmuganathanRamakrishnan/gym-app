// Database connection utility - PostgreSQL client
import { Pool } from 'pg';

// Connection pool singleton
let pool: Pool | null = null;

export const getPool = (): Pool => {
    if (!pool) {
        const connectionString = process.env.DB_URL ||
            'postgresql://postgres:postgres@localhost:5432/gymapp';

        pool = new Pool({
            connectionString,
            max: 10,
            idleTimeoutMillis: 30000,
            connectionTimeoutMillis: 2000,
        });

        pool.on('error', (err) => {
            console.error('Unexpected database error:', err);
        });
    }

    return pool;
};

// Helper for running queries
export const query = async <T>(
    text: string,
    params?: unknown[]
): Promise<T[]> => {
    const pool = getPool();
    const result = await pool.query(text, params);
    return result.rows as T[];
};

// Close pool on shutdown
export const closePool = async (): Promise<void> => {
    if (pool) {
        await pool.end();
        pool = null;
    }
};
