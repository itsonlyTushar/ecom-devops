const request = require('supertest');
const app = require('../app');

describe('health and root endpoints', () => {
  it('GET /health returns ok status', async () => {
    const res = await request(app).get('/health');

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(typeof res.body.uptime).toBe('number');
  });

  it('GET / returns service info', async () => {
    const res = await request(app).get('/');

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('running');
    expect(res.body.api).toBe('/api');
  });

  it('GET /api/unknown-route returns 404', async () => {
    const res = await request(app).get('/api/unknown-route');

    expect(res.status).toBe(404);
  });
});
