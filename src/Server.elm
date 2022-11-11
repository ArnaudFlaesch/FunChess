module Server exposing (..)

import Http exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (..)
import Model exposing (..)


initBoard : Cmd Msg
initBoard =
    let
        url =
            "http://localhost:1337/start"
    in
    Http.get { url = url, expect = Http.expectJson GetGameState decodeGameState }


decodeGameState : Decode.Decoder GameState
decodeGameState =
    Decode.succeed GameState
        |> required "winner" Decode.string
        |> required "currentPlayer" Decode.string
        |> required "playerColor" Decode.string
        |> required "pieces" (Decode.list decodePawn)


decodePawn : Decoder Pawn
decodePawn =
    Decode.succeed Pawn
        |> required "pawnType" Decode.string
        |> required "pawnColor" Decode.string
        |> required "positionX" Decode.int
        |> required "positionY" Decode.int


encodeServerRequest : ServerRequest -> String
encodeServerRequest serverRequest =
    Encode.encode 0 (Encode.object [ ( "pawn", encodePawn serverRequest.movingPawn ), ( "destinationX", Encode.int serverRequest.destinationX ), ( "destinationY", Encode.int serverRequest.destinationY ) ])


encodePawn : Pawn -> Value
encodePawn pawn =
    Encode.object
        [ ( "pawnType", Encode.string pawn.pawnType )
        , ( "pawnColor", Encode.string pawn.pawnColor )
        , ( "positionX", Encode.int pawn.positionX )
        , ( "positionY", Encode.int pawn.positionY )
        ]
