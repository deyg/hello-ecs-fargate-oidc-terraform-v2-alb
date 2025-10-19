// App Node.js simples para ECS Fargate (GET /hello e /health)
const express = require('express');
const app = express();

// Permite servir tanto sem prefixo quanto com o stage (ex.: /prod)
const stage = (process.env.API_STAGE || 'prod').replace(/^\/+/, '');
const mountPoints = ['', stage ? `/${stage}` : ''].filter((value, index, self) => self.indexOf(value) === index);

const createRouter = () => {
  const router = express.Router();

  router.get('/', (_, res) => res.json({ ok: true }));
  router.get('/hello', (_, res) =>
    res.json({ message: 'Ola, mundo ECS Fargate (ALB)!', at: new Date().toISOString() })
  );
  // Endpoint de saude para o ALB monitorar
  router.get('/health', (_, res) => res.status(200).send('OK'));

  return router;
};

mountPoints.forEach((base) => app.use(base || '/', createRouter()));

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`App up on ${port}`));
