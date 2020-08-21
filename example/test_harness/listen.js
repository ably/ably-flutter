const Ably = require("ably");

if (process.argv[2] && !process.argv[3]) {
  throw new Error("Invalid number of args: pass either 0 or 2 args");
}

const key = process.argv[2];
const channelName = process.argv[3] || "test-channel";
const environment = "sandbox";
const logLevel = 2;

const realtime = new Ably.Realtime({ key, environment, logLevel });
const channel = realtime.channels.get(channelName);

channel.subscribe((message) => {
  console.log(message);
});
