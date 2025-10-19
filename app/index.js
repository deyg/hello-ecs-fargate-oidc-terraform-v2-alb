// App Node.js simples para ECS Fargate (GET /hello e /health)
const express = require('express');
const app = express();

app.get('/', (_, res) => res.json({ ok: true }));
app.get('/hello', (_, res) =>
  res.json({ message: 'Olá, mundo ECS Fargate (ALB)!', at: new Date().toISOString() })
);
// Endpoint de saúde para o ALB
app.get('/health', (_, res) => res.status(200).send('OK'));

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`App up on ${port}`));
