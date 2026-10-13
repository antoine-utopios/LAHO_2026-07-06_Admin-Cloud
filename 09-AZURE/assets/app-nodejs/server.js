// Minimal HTTP app used for the App Service exercises.
// The VERSION and GREETING values come from app settings (environment variables).
const http = require("http");

const port = process.env.PORT || 8080;
const version = process.env.APP_VERSION || "v1";
const greeting = process.env.GREETING || "Hello from App Service";

const server = http.createServer((req, res) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);

  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end("OK");
    return;
  }

  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(
    JSON.stringify({
      message: greeting,
      version: version,
      hostname: process.env.WEBSITE_HOSTNAME || "local",
      slot: process.env.WEBSITE_SLOT_NAME || "n/a",
    })
  );
});

server.listen(port, () => console.log(`Listening on port ${port} (${version})`));
