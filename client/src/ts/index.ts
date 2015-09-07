/// <reference path="typings/tsd.d.ts"/>
/// <reference path="../../../shared/message.ts"/>

// Test using shared code
const msg: Message = new Message();
console.log(msg);

// Make a request
$.get('/api/test', function (data) { console.log(data); });
