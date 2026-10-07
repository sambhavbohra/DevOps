const test = require('node:test');
const assert = require('node:assert/strict');
const { calculateTax } = require('./server');

test('Tax calculation - standard calculation', () => {
  const result = calculateTax(100, 0.18);
  assert.equal(result, 118.00);
});

test('Tax calculation - zero tax rate', () => {
  const result = calculateTax(50, 0.0);
  assert.equal(result, 50.00);
});

test('Tax calculation - invalid argument type throws error', () => {
  assert.throws(() => calculateTax('100', 0.18), {
    name: 'Error',
    message: 'Invalid arguments: amount and rate must be numbers'
  });
});

test('Tax calculation - negative number throws error', () => {
  assert.throws(() => calculateTax(-10, 0.18), {
    name: 'Error',
    message: 'Arguments must be non-negative'
  });
});
