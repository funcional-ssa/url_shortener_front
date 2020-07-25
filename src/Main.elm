port module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, h2, img, input, button, a, form)
import Html.Attributes exposing (src, type_, placeholder, value, class, href, target)
import Html.Events exposing (onInput, onClick, onSubmit)
import Http exposing (Body)
import Json.Encode as Encode
import Json.Decode exposing (Decoder, field, string)

apiUrl : String
apiUrl = "http://localhost:25565/"

---- PORTS ----

port toggleDarkMode : Bool ->  Cmd msg

---- MODEL ----
type Status
      = Failure String
      | Waiting
      | Success String
    
type alias Model =
    { link : String
    , darkMode: Bool
    , status: Status
    }


init : Bool -> (Model, Cmd Msg)
init isDarkModeOn =
    (Model "" isDarkModeOn Waiting, Cmd.none)

---- UPDATE ----

type Msg
    = Link String
    | GotText (Result Http.Error String)
    | ToggleDarkMode
    | SendRequest

encodeJson : String -> Encode.Value
encodeJson str = Encode.object [ ("url", Encode.string str) ]

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

        SendRequest ->
            (model, sendLink <| Http.jsonBody <| encodeJson model.link)

        GotText result ->
            case result of
                Ok url ->
                    ({ model | status = Success url }
                    , Cmd.none)
                Err (Http.BadStatus _ ) ->
                    ({model | status = Failure "Url inválida" }, Cmd.none)
                Err _ ->
                    ({ model | status = Failure "Erro interno" }, Cmd.none)

---- VIEW ----

view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ img [ src "/logo.svg" ] []
        , button [ onClick ToggleDarkMode, class "darkModeButton" ] [ text "ToggleDarkMode" ]
        , h1 [] [ text "Insira o Link a ser encurtado"]
        , form [ onSubmit SendRequest ] [
        input [ type_ "text", placeholder "Insira a URL aqui", value model.link, onInput Link ] []
        , button [ ] [ text "Encurtar" ]

        ]
        , showResult model.status
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

urlDecoder : Decoder String
urlDecoder =
    field "url" string

sendLink : Body -> Cmd Msg
sendLink urlToShorten =
            Http.request
                { method = "POST"
                , url = apiUrl
                , headers = []
                , body = urlToShorten
                , expect = Http.expectJson GotText urlDecoder
                , timeout = Just 2000.0
                , tracker = Nothing }

showResult : Status -> Html msg
showResult status =
    case status of
            Waiting ->
                Html.text ""
            Failure errMsg ->
                h2
                    [ class "error" ]
                    [ text <| errMsg]
            Success url ->
                h2
                    [ ]
                    [ text <| "Link encurtado: ",
                        a
                            [ href <| apiUrl ++ url, target "_blank" ]
                            [ text <| apiUrl ++ url ]]