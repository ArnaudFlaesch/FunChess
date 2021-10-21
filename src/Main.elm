module Main exposing (..)

import Grid exposing (renderGrid)
import Html
import Json.Decode exposing (decodeString)
import Model exposing (..)


init : ( Model, Cmd Msg )
init =
    ( Model [] Nothing (Select 0 0) "" "" "", initBoard )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Select coordsX coordsY ->
            ( Model model.pawnsList (searchIfPieceIsOnTile model.pawnsList coordsX coordsY) (Move coordsX coordsY) model.currentPlayer model.playerColor "", Cmd.none )

        Move coordsX coordsY ->
            case model.selectedPawn of
                Just pawn ->
                    ( Model model.pawnsList Nothing (Select coordsX coordsY) model.currentPlayer model.playerColor "", WebSocket.send serverUrl (encodeServerRequest (ServerRequest pawn coordsX coordsY)) )

                Nothing ->
                    ( model, Cmd.none )

        NextTurn gameStateJSON ->
            case decodeString decodeGameState gameStateJSON of
                Ok gameState ->
                    ( Model gameState.pawnsListFromServer Nothing (Select 0 0) gameState.playerColor model.playerColor gameState.winner, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        GetGameState (Ok gameState) ->
            ( Model gameState.pawnsListFromServer Nothing (Select 0 0) gameState.currentPlayer gameState.playerColor gameState.winner, Cmd.none )

        GetGameState (Err _) ->
            ( model, Cmd.none )

        None ->
            ( model, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = renderGrid
        , update = update
        }
