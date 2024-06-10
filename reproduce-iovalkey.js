import IOValkey from "iovalkey";

const cluster = new IOValkey.Cluster([{ host: "localhost", port: 6390 }]);

await cluster.set("foo", "bar");

const endPromise = new Promise((resolve) => cluster.once("end", resolve));
await cluster.quit();
cluster.disconnect();
await endPromise;

cluster.connect();
console.log(await cluster.get("foo"));
cluster.disconnect();
