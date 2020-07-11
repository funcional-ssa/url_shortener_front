port module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, h2, img, input, button)
import Html.Attributes exposing (src, type_, placeholder, value, class)
import Html.Events exposing (onInput, onClick)


---- PORTS ----

port toggleDarkMode : Bool ->  Cmd msg

---- MODEL ----


type alias Model =
    { link : String
    , darkMode: Bool }


init : Bool -> (Model, Cmd Msg)
init isDarkModeOn = 
    (Model "" isDarkModeOn, Cmd.none)



---- UPDATE ----


type Msg
    = Link String 
    | ToggleDarkMode


update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        Link link ->
            ({ model | link = link }
            , Cmd.none)

        ToggleDarkMode->   
            let
                newValue = not model.darkMode
            in
            ( { model | darkMode = newValue }
            , toggleDarkMode newValue
            )

            



---- VIEW ----

view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ img [ src "/logo.svg" ] []
        , button [ onClick ToggleDarkMode, class "darkModeButton" ] [ text "ToggleDarkMode" ]  
        , h1 [] [ text "Insira o Link a ser encurtado"]
        , input [ type_ "text", placeholder "Insira a URL aqui", value model.link, onInput Link ] [] 
        ]

---- PROGRAM ----


main : Program Bool Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
