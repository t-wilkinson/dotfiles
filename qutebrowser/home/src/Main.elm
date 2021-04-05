module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html


color =
    { accent = rgb255 189 147 249
    , blue = rgb255 139 233 253
    , background = rgb255 40 42 54
    , subAccent = rgb255 98 114 164
    , black = rgb255 0 0 0
    }


type alias Model =
    {}


type Msg
    = NoOp


header : Model -> Element Msg
header model =
    row
        [ spacing 50, padding 80, Font.size 250 ]
        [ el [ Font.color color.blue ] <| text "Welcome"
        , el [ Font.color color.accent ] <| text "Trey"
        ]


sites : Model -> Element Msg
sites model =
    let
        img name =
            image [ width (px 300) ] { src = "icons/" ++ name ++ ".svg", description = name }
    in
    wrappedRow [ moveUp 90, centerX, width (fill |> maximum 1024) ]
        [ link [] { url = "https://reddit.com", label = img "reddit" }
        , link [] { url = "https://youtube.com", label = img "youtube" }
        , link [] { url = "https://hoogle.haskell.org/", label = img "haskell" }
        , link [] { url = "https://package.elm-lang.org/", label = img "elm" }
        , link [] { url = "https://wikipedia.com", label = img "wikipedia" }
        , link [] { url = "https://wiki.archlinux.org/", label = img "archlinux" }
        ]


view : Model -> Html.Html Msg
view model =
    layout [ Background.color color.background, Font.family [ Font.typeface "Pincoya" ] ] <|
        column
            [ centerX ]
            [ header model
            , sites model
            ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model


init : Model
init =
    {}


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }
