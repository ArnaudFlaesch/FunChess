var express = require("express");
var app = express();
const WebSocket = require("ws");

var portNumber = process.env.PORT || 1337;
const wss = new WebSocket.Server({port: 2337, path: "/movePawn"});

var currentNumberOfPlayers = 0;
var currentPlayerColor = "white";

function switchPlayers() {
    if (currentPlayerColor === "white") {
        return "gold";
    }
    else {
        return "white";
    }
}

function searchIfKingIsStillAlive(color) {
    for (var index = 0; index < pieces.length; index += 1) {
        if (pieces[index].pawnColor === color && pieces[index].pawnType === "king") {
            return (true);
        }
    }
    return (false);
}

function removePieceFromList(positionX, positionY) {
    pieces = pieces.filter(function (piece) {
        return (!(piece.positionX === positionX && piece.positionY === positionY));
    });
}

function initWhitePieces() {
    var whitePieces = [];
    for (var column = 0; column < 8; column += 1) {
        whitePieces.push({"pawnType": "pawn", "pawnColor": "white", "positionX": column, "positionY": 6});
    }
    return (whitePieces.concat(addSpecialPieces(7, "white")));
}

function initGoldenPieces() {
    var goldenPieces = [];
    for (var column = 0; column < 8; column += 1) {
        goldenPieces.push({"pawnType": "pawn", "pawnColor": "gold", "positionX": column, "positionY": 1});
    }
    return (goldenPieces.concat(addSpecialPieces(0, "gold")));
}

function addSpecialPieces(row, color) {
    var specialPieces = [];
    specialPieces.push({"pawnType": "tower", "pawnColor": color, "positionX": 0, "positionY": row});
    specialPieces.push({"pawnType": "knight", "pawnColor": color, "positionX": 1, "positionY": row});
    specialPieces.push({"pawnType": "bishop", "pawnColor": color, "positionX": 2, "positionY": row});
    specialPieces.push({"pawnType": "king", "pawnColor": color, "positionX": 3, "positionY": row});
    specialPieces.push({"pawnType": "queen", "pawnColor": color, "positionX": 4, "positionY": row});
    specialPieces.push({"pawnType": "bishop", "pawnColor": color, "positionX": 5, "positionY": row});
    specialPieces.push({"pawnType": "knight", "pawnColor": color, "positionX": 6, "positionY": row});
    specialPieces.push({"pawnType": "tower", "pawnColor": color, "positionX": 7, "positionY": row});
    return (specialPieces);
}

var pieces = initWhitePieces().concat(initGoldenPieces());

app.get("/start", function (request, resource) {
    var playerColor = "";
    currentNumberOfPlayers += 1;

    if (currentNumberOfPlayers === 1) {
        playerColor = "white";
    }
    else if (currentNumberOfPlayers === 2) {
        playerColor = "gold";
    }
    resource.header("Access-Control-Allow-Origin", "*");
    resource.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    resource.header("Content-Type", "application/json");
    resource.send(JSON.stringify({"winner": "", "currentPlayer": currentPlayerColor, "playerColor": playerColor, "pieces": pieces}));
});

wss.on("connection", function connection(ws) {
    ws.on("message", function incoming(data) {
        var data = JSON.parse(data);
        removePieceFromList(data.pawn.positionX, data.pawn.positionY);
        removePieceFromList(data.destinationX, data.destinationY);
        data.pawn.positionX = data.destinationX;
        data.pawn.positionY = data.destinationY;
        pieces.push(data.pawn);
        var winner = "";
        if (!searchIfKingIsStillAlive(switchPlayers())) {
            winner = currentPlayerColor;
        }
        currentPlayerColor = switchPlayers();
        wss.clients.forEach(function each(client) {
            if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({"winner": winner, "currentPlayer": currentPlayerColor, "playerColor": currentPlayerColor, "pieces": pieces}));
            }
        });
    });
});

app.listen(portNumber);