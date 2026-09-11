require('dotenv').config();
const chalk = require('chalk');

const keys = require('./config/keys');
const setupDB = require('./utils/db');
const app = require('./app');
const socket = require('./socket');

const { port } = keys;

setupDB();

const server = app.listen(port, () => {
  console.log(
    `${chalk.green('✓')} ${chalk.blue(
      `Listening on port ${port}. Visit http://localhost:${port}/ in your browser.`
    )}`
  );
});

socket(server);
