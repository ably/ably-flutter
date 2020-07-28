const Ably = require('ably');

if(process.argv[2] && !process.argv[3]) throw new Error("Invalid number of args: pass either 0 or 2 args");

const key = process.argv[2];
const channelName = process.argv[3] || 'test-channel';
const environment = 'sandbox';
const logLevel = 2;

var realtime = new Ably.Realtime({key, environment, logLevel});
var channel = realtime.channels.get(channelName);

async function publish(name, data){
    return new Promise((resolve, reject)=>{
        channel.publish(name, data,
            function(err) {
                if(err) {
                    console.log('publish failed with error ' + err);
                    reject();
                } else {
                    console.log(`published message "${data}" with name "${name}"`);
                    resolve();
                }
            }
        );
    });
}

async function publishUndefined(){
    await publish('message-undefined', undefined);
}

async function publishNull(){
    await publish('message-null', null);
}

async function publishString(){
    await publish('message-string', "Out of boredom! Need some more...");
}

async function publishObject(){
    await publish(
        'message-data',
        {"I am": null, "and": {"also": "nested", "too": {"deep": true}}}
    );
}

async function publishArray(){
    await publish(
        'message-data',
        [42, {"are": "you"}, "crazy", false, {"I am": null, "and": {"also": "nested", "too": {"deep": true}}}]
    );
}

async function delay(fn){
    return new Promise(async (resolve, reject) => {
        setTimeout(async () => {
            resolve(await fn());
        }, 2000);
    });
}

publishUndefined()
    .then(() => delay(publishNull))
    .then(() => delay(publishString))
    .then(() => delay(publishObject))
    .then(() => delay(publishArray))
    .then(process.exit)
    .catch((e)=>console.log(e)||process.exit());
