const appInsights = require('applicationinsights');

const keys = require('./keys');

// no-op if APPLICATIONINSIGHTS_CONNECTION_STRING isn't set (local dev, CI)
function setupMonitoring() {
  const connectionString = keys.appInsights.connectionString;

  if (!connectionString) {
    return;
  }

  appInsights
    .setup(connectionString)
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true, true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .setAutoCollectConsole(true, true)
    .setSendLiveMetrics(true)
    .start();

  appInsights.defaultClient.context.tags[appInsights.defaultClient.context.keys.cloudRole] =
    'ecommerce-server';
}

module.exports = setupMonitoring;
