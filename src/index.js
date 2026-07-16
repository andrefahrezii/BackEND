const express = require('express');
const helmet = require('helmet'); // Keamanan header wajib untuk perbankan[cite: 1]
const app = express();
const port = process.env.PORT || 3091;

// Security Middleware: Helmet membantu mengamankan aplikasi dari berbagai serangan web[cite: 1]
app.use(helmet());
app.use(express.json());

// Endpoint untuk Health Check (wajib ada untuk monitoring di OpenShift/Kubernetes)[cite: 1, 3]
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', message: 'Service is running securely' });
});

app.listen(port, () => {
  console.log(`User service running on port ${port}`);
});