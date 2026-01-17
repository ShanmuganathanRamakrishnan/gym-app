// Workouts API routes
import { FastifyInstance } from 'fastify';

interface Workout {
    id: string;
    title: string;
    description: string;
    duration: number;
    exercises: number;
}

// Mock data - replace with database queries
const mockWorkouts: Workout[] = [
    { id: '1', title: 'Upper Body Strength', description: 'Chest, shoulders, triceps', duration: 45, exercises: 8 },
    { id: '2', title: 'Leg Day', description: 'Quads, hamstrings, calves', duration: 50, exercises: 6 },
    { id: '3', title: 'HIIT Cardio', description: 'High intensity intervals', duration: 30, exercises: 10 },
];

export async function workoutsRoutes(app: FastifyInstance): Promise<void> {
    // GET /api/workouts - list all workouts
    app.get('/workouts', async () => {
        return { workouts: mockWorkouts };
    });

    // GET /api/workouts/:id - get single workout
    app.get('/workouts/:id', async (request, reply) => {
        const { id } = request.params as { id: string };
        const workout = mockWorkouts.find(w => w.id === id);

        if (!workout) {
            return reply.status(404).send({ error: 'Workout not found' });
        }

        return workout;
    });

    // POST /api/workouts - create workout (stub)
    app.post('/workouts', async (request, reply) => {
        const body = request.body as Partial<Workout>;

        if (!body.title) {
            return reply.status(400).send({ error: 'Title is required' });
        }

        const newWorkout: Workout = {
            id: String(mockWorkouts.length + 1),
            title: body.title,
            description: body.description || '',
            duration: body.duration || 30,
            exercises: body.exercises || 0
        };

        mockWorkouts.push(newWorkout);
        return reply.status(201).send(newWorkout);
    });
}
