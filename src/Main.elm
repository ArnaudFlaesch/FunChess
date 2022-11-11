port module Main exposing (..)

import Browser
import Grid exposing (renderGrid)
import Json.Decode exposing (decodeString)
import Model exposing (..)
import Server exposing (decodeGameState, encodeServerRequest, initBoard)


port incomingMessage : (String -> msg) -> Sub msg


port outgoingMessage : String -> Cmd msg


init : () -> ( Model, Cmd Msg )
init flags =
    ( { pawnsList = []
      , selectedPawn = Nothing
      , state = Select 0 0
      , currentPlayer = ""
      , playerColor = ""
      , winner = ""
      }
    , initBoard
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    incomingMessage NextTurn


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Select coordsX coordsY ->
            ( Model model.pawnsList (searchIfPieceIsOnTile model.pawnsList coordsX coordsY) (Move coordsX coordsY) model.currentPlayer model.playerColor "", Cmd.none )

        Move coordsX coordsY ->
            case model.selectedPawn of
                Just pawn ->
                    ( Model model.pawnsList Nothing (Select coordsX coordsY) model.currentPlayer model.playerColor "", outgoingMessage (encodeServerRequest (ServerRequest pawn coordsX coordsY)) )

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


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = renderGrid
        , subscriptions = subscriptions
        , update = update
        }
