const url = new URL(Deno.args[0]);
// console.log(url.toString());
// console.log(url.search);
// url.search = new URLSearchParams(url.search).toString();
// console.log(url.search);
const res = await fetch(url);

const body = new Uint8Array(await res.arrayBuffer());
// const json = JSON.parse(body);
await Deno.stdout.write(res);
