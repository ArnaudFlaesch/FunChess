module Server exposing (..)

import Http exposing (..)
import Json.Decode as Decode exposing (int, string, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode exposing (..)

import Model exposing (..)

serverUrl : String
serverUrl =
  "ws://localhost:2337/movePawn"

initBoard : Cmd Msg
initBoard =
  let
    url =
      "http://localhost:1337/start"
  in
    Http.send GetGameState (Http.get url decodeGameState)

decodeGameState : Decode.Decoder GameState
decodeGameState =
  decode GameState
    |> required "winner" Decode.string
    |> required "currentPlayer" Decode.string
    |> required "playerColor" Decode.string
    |> required "pieces" (Decode.list decodePawn)

decodePawn =
  decode Pawn
    |> required "pawnType" Decode.string
    |> required "pawnColor" Decode.string
    |> required "positionX" Decode.int
    |> required "positionY" Decode.int

encodeServerRequest : ServerRequest -> String
encodeServerRequest serverRequest =
    Encode.encode 0 (Encode.object [("pawn", (encodePawn serverRequest.movingPawn)), ("destinationX", (Encode.int serverRequest.destinationX)), ("destinationY", (Encode.int serverRequest.destinationY)) ])

encodePawn : Pawn -> Value
encodePawn pawn =
    Encode.object
        [ ("pawnType", Encode.string pawn.pawnType)
         ,("pawnColor", Encode.string pawn.pawnColor)
         ,("positionX", Encode.int pawn.positionX)
         ,("positionY", Encode.int pawn.positionY)
        ]