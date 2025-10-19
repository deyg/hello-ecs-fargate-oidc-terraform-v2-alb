// App Node.js simples para ECS Fargate (GET /hello e /health)
const express = require('express');
const app = express();

const DEFAULT_STAGE = 'prod';

const normalizeStage = (stage) => stage.replace(/^\/+/, '');

const createRouter = () => {
  const router = express.Router();

  router.get('/', (_, res) => res.json({ ok: true }));
  router.get('/hello', (_, res) =>
    res.json({ message: 'Ola, mundo ECS Fargate (ALB)!', at: new Date().toISOString() })
  );
  router.get('/health', (_, res) => res.status(200).send('OK'));

  return router;
};

const configureRoutes = (stage) => {
  const normalizedStage = normalizeStage(stage || DEFAULT_STAGE);
  const mountPoints = ['', normalizedStage ? `/${normalizedStage}` : ''];
  const router = createRouter();

  mountPoints.forEach((basePath) => {
    const mount = basePath || '/';
    app.use(mount, router);
  });
};

configureRoutes(process.env.API_STAGE);

const port = Number(process.env.PORT) || 3000;
app.listen(port, () => {
  console.log(`App up on ${port}`);
});
