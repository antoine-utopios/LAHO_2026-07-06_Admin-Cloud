const { app, output } = require('@azure/functions');

const processedQueue = output.storageQueue({
  queueName: 'processed',
  connection: 'AzureWebJobsStorage',
});

// Queue trigger on "orders" + output binding to "processed"
app.storageQueue('processOrder', {
  queueName: 'orders',
  connection: 'AzureWebJobsStorage',
  extraOutputs: [processedQueue],
  handler: (message, context) => {
    const text = String(typeof message === 'string' ? message : JSON.stringify(message));
    if (text.includes('fail')) {
      // Thrown errors are retried, then the message goes to "orders-poison"
      throw new Error(`Simulated failure for message: ${text}`);
    }
    context.extraOutputs.set(processedQueue, `${text.toUpperCase()} processed at ${new Date().toISOString()}`);
  },
});
