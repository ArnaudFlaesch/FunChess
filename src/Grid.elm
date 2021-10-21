module Grid exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Model exposing (..)


renderGrid : Model -> Html Msg
renderGrid model =
    div [ style [ ( "text-align", "center" ) ] ]
        [ div [ hidden (model.winner == "") ] [ text ("Le joueur " ++ model.winner ++ " a gagné !") ]
        , div [ hidden ((model.playerColor == "") || (model.winner /= "")) ] [ text ("Vous êtes le joueur " ++ model.playerColor) ]
        , div [ hidden ((model.currentPlayer == "") || (model.winner /= "")) ] [ text ("C'est au tour du joueur " ++ model.currentPlayer ++ " de jouer") ]
        , div [ style [ ( "margin-top", "1cm" ) ] ]
            (List.map (renderRow model) (List.range 0 7))
        ]


renderRow : Model -> Int -> Html Msg
renderRow model columnSize =
    div
        [ style
            [ ( "margin-top", "-5px" ) ]
        ]
        (List.map (renderTile model columnSize) (List.range 0 7))


renderTile : Model -> Int -> Int -> Html Msg
renderTile model y x =
    img
        [ onClick (getActionMsg x y model)
        , style
              "background-image", "url(images/" ++ getTileColorToDisplay x y ++ ".png)" 
            ,  "min-height", "64px" 
            ,  "min-width", "64px" 
            ,  "border", "solid 0.2em" 
            ,  "border-color"
              , if canPawnMoveHere model x y then
                    "red"

                else
                    "#340000"
              
            
        , src (getImageToDisplay x y model)
        ]
        []


getTileColorToDisplay : Int -> Int -> String
getTileColorToDisplay x y =
    if modBy (x + y)  2 == 0 then
        "whiteTile"

    else
        "blackTile"


getImageToDisplay : Int -> Int -> Model -> String
getImageToDisplay x y model =
    case searchIfPieceIsOnTile model.pawnsList x y of
        Just value ->
            "images/pawns/" ++ value.pawnColor ++ "/" ++ value.pawnType ++ ".png"

        Nothing ->
            "images/" ++ getTileColorToDisplay x y ++ ".png"
