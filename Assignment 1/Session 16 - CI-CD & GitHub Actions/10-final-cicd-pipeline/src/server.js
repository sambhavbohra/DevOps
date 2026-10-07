const http = require('http');

const PORT = process.env.PORT || 3000;
const VERSION = process.env.APP_VERSION || '1.0.0';
const ENVIRONMENT = process.env.NODE_ENV || 'development';

function calculateTax(amount, rate) {
  if (typeof amount !== 'number' || typeof rate !== 'number') {
    throw new Error('Invalid arguments: amount and rate must be numbers');
  }
  if (amount < 0 || rate < 0) {
    throw new Error('Arguments must be non-negative');
  }
  return Number((amount * (1 + rate)).toFixed(2));
}

function handleRequest(req, res) {
  res.setHeader('Content-Type', 'application/json');

  if (req.url === '/health' || req.url === '/healthz') {
    res.writeHead(200);
    return res.end(JSON.stringify({ status: 'UP', timestamp: new Date().toISOString() }));
  }

  if (req.url === '/info') {
    res.writeHead(200);
    return res.end(JSON.stringify({
      app: 'cicd-demo-service',
      version: VERSION,
      environment: ENVIRONMENT,
      author: 'Sambhav D Bohra',
      regNo: '24bcs10090'
    }));
  }

  if (req.url.startsWith('/calculate')) {
    try {
      const result = calculateTax(100, 0.18);
      res.writeHead(200);
      return res.end(JSON.stringify({ total: result, status: 'success' }));
    } catch (err) {
      res.writeHead(400);
      return res.end(JSON.stringify({ error: err.message }));
    }
  }

  res.writeHead(200);
  res.end(JSON.stringify({
    message: 'Welcome to CI/CD GitHub Actions Demo API',
    endpoints: ['/health', '/info', '/calculate']
  }));
}

const server = http.createServer(handleRequest);

if (require.main === module) {
  server.listen(PORT, () => {
    console.log(`[CI/CD Demo] Server listening on port ${PORT} in ${ENVIRONMENT} mode`);
  });
}

module.exports = { calculateTax, handleRequest, server };
