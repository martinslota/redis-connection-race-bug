import IORedis from "ioredis";

const cluster = new IORedis.Cluster([{ host: "localhost", port: 6380 }]);

await cluster.set("foo", "bar");

const endPromise = new Promise((resolve) => cluster.once("end", resolve));
await cluster.quit();
cluster.disconnect();
await endPromise;

cluster.connect();
console.log(await cluster.get("foo"));
cluster.disconnect();
