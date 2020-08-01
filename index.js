const Koa = require('koa');
const Router = require('@koa/router');
const app = new Koa();
const router = new Router();
const port = parseInt(process.env.PORT) || 3000;

router.get('/', async (ctx) => {
  ctx.body = {user: "ta6ish"}
});

router.get('/create', async (ctx) => {
  ctx.body = {status: "success"}
});

app
  .use(router.routes())
  .use(router.allowedMethods());

const server = app.listen(port, () => {
    console.info(`listening on ${server.address().port}`);
});

module.exports = {
  server
};
