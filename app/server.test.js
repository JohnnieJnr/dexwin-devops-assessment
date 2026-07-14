const assert = require('node:assert/strict');
const test = require('node:test');

const { isHealthy } = require('./server');

test('given the configured startup delay, the service reports healthy afterward', () => {
  assert.equal(isHealthy(Date.now() + 20_000), true);
});
