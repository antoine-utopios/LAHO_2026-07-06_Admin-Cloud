const { app, output } = require('@azure/functions');

// Output binding: the runtime writes to the "orders" queue for us (no SDK code)
const ordersQueue = output.storageQueue({
  queueName: 'orders',
  connection: 'AzureWebJobsStorage',
});

app.http('enqueue', {
  methods: ['POST'],
  authLevel: 'function', // a function key is required
  extraOutputs: [ordersQueue],
  handler: async (request, context) => {
    const body = (await request.text()).trim();
    if (!body) {
      return { status: 400, body: 'Empty body' };
    }
    context.extraOutputs.set(ordersQueue, body);
    return { status: 202, body: `Queued: ${body}` };
  },
});
