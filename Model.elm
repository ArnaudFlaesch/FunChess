module Model exposing (..)

import Http exposing (..)

type alias Model =
 {
   pawnsList : List Pawn,
   selectedPawn: Maybe Pawn,
   state : Msg,
   currentPlayer : String,
   playerColor : String,
   winner : String
 }

type alias Pawn =
 {
    pawnType : String,
    pawnColor : String,
    positionX : Int,
    positionY : Int
 }

type alias GameState =
 {
    winner : String,
    currentPlayer : String,
    playerColor : String,
    pawnsListFromServer : List Pawn
 }

type alias ServerRequest =
 {
    movingPawn : Pawn,
    destinationX : Int,
    destinationY : Int
 }

type Msg = Select Int Int
         | Move Int Int
         | GetGameState (Result Http.Error GameState)
         | NextTurn String
         | None

getActionMsg : Int -> Int -> Model -> Msg
getActionMsg x y model =
 if model.currentPlayer == model.playerColor && model.winner == "" then
     case searchIfPieceIsOnTile model.pawnsList x y of
         Just pawn ->
            if pawn.pawnColor == model.currentPlayer then Select x y
            else if canPawnMoveHere model x y then Move x y
                else None
         Nothing ->
            if canPawnMoveHere model x y then Move x y
            else None
 else None

searchIfPieceIsOnTile : List Pawn -> Int -> Int -> Maybe Pawn
searchIfPieceIsOnTile activePawns x y = List.foldl
 (\piece pawn -> case pawn of
    Just _ ->
        pawn
    Nothing ->
     if piece.positionX == x && piece.positionY == y then
        Just piece
     else
        Nothing
 ) Nothing activePawns

canPawnMoveHere : Model -> Int -> Int -> Bool
canPawnMoveHere model tileX tileY =
 case model.selectedPawn of
     Just pawn ->
         case searchIfPieceIsOnTile model.pawnsList tileX tileY of
             Just hasPawnOnTile -> if hasPawnOnTile.pawnColor == pawn.pawnColor then False
                                   else (getPawnAvailableMovements pawn tileX tileY model.pawnsList)
             Nothing ->
                 (getPawnAvailableMovements pawn tileX tileY model.pawnsList)
     Nothing -> False

getPawnAvailableMovements : Pawn -> Int -> Int -> List Pawn -> Bool
getPawnAvailableMovements pawn tileX tileY pawnsList =
 case pawn.pawnType of
     "king"      -> if abs(pawn.positionX - tileX) <= 1 && abs(pawn.positionY - tileY) <= 1 then True else False
     "queen"     -> if abs(pawn.positionX - tileX) == abs(pawn.positionY - tileY) || (abs(pawn.positionX - tileX) == 0 || abs(pawn.positionY - tileY) == 0) then True else False
     "bishop"    -> if abs(pawn.positionX - tileX) == abs(pawn.positionY - tileY) then True else False
     "knight"    -> if abs(pawn.positionX - tileX) == 2 && abs(pawn.positionY - tileY) == 1 || abs(pawn.positionX - tileX) == 1 && abs(pawn.positionY - tileY) == 2 then True else False
     "tower"     -> if abs(pawn.positionX - tileX) == 0 || abs(pawn.positionY - tileY) == 0 then True else False
     "pawn"      -> case (searchIfPieceIsOnTile pawnsList tileX tileY) of
                     Just anotherPawn ->
                         case pawn.pawnColor of
                             "white"     -> if abs(tileX - pawn.positionX) == 1 && (tileY - pawn.positionY) == -1 then True else False
                             "gold"      -> if abs(tileX - pawn.positionX) == 1 && (tileY - pawn.positionY) == 1 then True else False
                             _           -> False
                     Nothing ->
                         case pawn.pawnColor of
                             "white"     -> if pawn.positionX == tileX && pawn.positionY - 1 == tileY || pawn.positionY == 6 && (tileY == 4 && tileX == pawn.positionX) then True else False
                             "gold"      -> if pawn.positionX == tileX && pawn.positionY + 1 == tileY || pawn.positionY == 1 && (tileY == 3 && tileX == pawn.positionX) then True else False
                             _           -> False
     _           -> False