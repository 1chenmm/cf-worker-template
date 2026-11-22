export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    return Response.json({
      ok: true,
      message: "部署成功 🎉 改代码 push 一下就会自动更新",
      path: url.pathname,
      colo: request.cf?.colo ?? null,
      time: new Date().toISOString(),
    });
  },
};
