/// <reference path="typings/tsd.d.ts"/>

// No typing information for swagger-js :(
declare var SwaggerClient: any;

const swagger = new SwaggerClient({
    url: location.protocol + "//" + location.host + "/api/swagger",
    success: main
});

function main() {
    swagger.apis.cat.create({cat: {name: "wooo"}}, function (response) {
        const cat = response.obj;
        console.log(cat);
        swagger.apis.cat.getById({id: cat._id}, function (otherResponse) {
            const otherCat = otherResponse.obj;
            console.log(otherCat);
        });
    });
}

var socket = io();

socket.on("ping", function () {
    socket.emit("pong");
});