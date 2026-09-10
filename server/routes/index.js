const router = require('express').Router();
const apiRoutes = require('./api');

const keys = require('../config/keys');
const { apiURL } = keys.app;

const api = `/${apiURL}`;

// Health check endpoint for Azure App Service / Container Apps probes
router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// Root service endpoint
router.get('/', (req, res) => {
  res.status(200).json({
    name: keys.app.name,
    status: 'running',
    health: '/health',
    api: api
  });
});

// api routes
router.use(api, apiRoutes);
router.use(api, (req, res) => res.status(404).json('No API route found'));

module.exports = router;
