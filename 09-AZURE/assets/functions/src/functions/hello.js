const { app } = require('@azure/functions');

// HTTP trigger, no key required (demo only)
app.http('hello', {
  methods: ['GET'],
  authLevel: 'anonymous',
  handler: async (request, context) => {
    const name = request.query.get('name') || 'world';
    context.log(`hello called with name=${name}`);
    return { jsonBody: { message: `Hello, ${name}!`, time: new Date().toISOString() } };
  },
});
