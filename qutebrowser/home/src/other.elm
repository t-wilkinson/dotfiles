{-
   module Main exposing (Model, Msg(..), Palette, init, main, palette, polygons, update, view)

   import Animation exposing (px)
   import Browser
   import Color.Palette as Color exposing (green, purple, rgb)
   import Html exposing (Html, div, h1)
   import Html.Attributes as Attr
   import Html.Events exposing (..)
   import Svg exposing (..)
   import Svg.Attributes exposing (..)
   import Time


   type alias Model =
       { styles : List Animation.State
       , index : Int
       }


   type Msg
       = EverybodySwitch
       | Animate Animation.Msg


   type alias Palette =
       { orange : Color.Color
       , green : Color.Color
       , lavender : Color.Color
       , blue : Color.Color
       }


   palette : Palette
   palette =
       { orange = rgb 240 173 0
       , green = rgb 127 209 59
       , lavender = rgb 90 99 120
       , blue = rgb 96 181 204
       }


   polygons : List (List Animation.Property)
   polygons =
       [ [ Animation.points
               [ ( 161.649, 152.782 )
               , ( 231.514, 82.916 )
               , ( 91.783, 82.916 )
               ]
         , Animation.fill palette.orange
         ]
       , [ Animation.points
               [ ( 8.867, 0 )
               , ( 79.241, 70.375 )
               , ( 232.213, 70.375 )
               , ( 161.838, 0 )
               ]
         , Animation.fill palette.green
         ]
       , [ Animation.points
               [ ( 323.298, 143.724 )
               , ( 323.298, 0 )
               , ( 179.573, 0 )
               ]
         , Animation.fill palette.blue
         ]
       , [ Animation.points
               [ ( 152.781, 161.649 )
               , ( 0, 8.868 )
               , ( 0, 314.432 )
               ]
         , Animation.fill palette.lavender
         ]
       , [ Animation.points
               [ ( 255.522, 246.655 )
               , ( 323.298, 314.432 )
               , ( 323.298, 178.879 )
               ]
         , Animation.fill palette.orange
         ]
       , [ Animation.points
               [ ( 161.649, 170.517 )
               , ( 8.869, 323.298 )
               , ( 314.43, 323.298 )
               ]
         , Animation.fill palette.blue
         ]
       ]


   update : Msg -> Model -> ( Model, Cmd Msg )
   update action model =
       case action of
           EverybodySwitch ->
               let
                   wrappedIndex =
                       if List.length model.styles < model.index then
                           model.index - List.length model.styles

                       else
                           model.index

                   newStyles =
                       List.drop wrappedIndex polygons ++ List.take wrappedIndex polygons
               in
               ( { model
                   | index = wrappedIndex + 1
                   , styles =
                       List.map3
                           (\i style newStyle ->
                               Animation.interrupt
                                   [ Animation.wait (Time.millisToPosix (i * 50))
                                   , Animation.to newStyle
                                   ]
                                   style
                           )
                           (List.range 0 (List.length model.styles))
                           model.styles
                           newStyles
                 }
               , Cmd.none
               )

           Animate time ->
               ( { model
                   | styles = List.map (Animation.update time) model.styles
                 }
               , Cmd.none
               )


   view : Model -> Html Msg
   view model =
       div
           [ onClick EverybodySwitch
           , Attr.style "margin" "200px auto"
           , Attr.style "width" "500px"
           , Attr.style "height" "500px"
           , Attr.style "cursor" "pointer"
           ]
           [ h1 [] [ text "Click to morph!" ]
           , svg
               [ version "1.1"
               , x "0"
               , y "0"
               , viewBox "0 0 323.141 322.95"
               ]
             <|
               [ rect
                   [ fill "#0F013B"
                   , x "192.99"
                   , y "107.392"
                   , width "107.676"
                   , height "108.167"
                   , transform "matrix(0.7071 0.7071 -0.7071 0.7071 186.4727 -127.2386)"
                   ]
                   []
               , Svg.g []
                   (List.map (\poly -> polygon (Animation.render poly) []) model.styles)
               ]
           ]


   init : ( Model, Cmd Msg )
   init =
       ( { styles = List.map Animation.style polygons
         , index = 1
         }
       , Cmd.none
       )


   main : Program () Model Msg
   main =
       Browser.element
           { init = always init
           , view = view
           , update = update
           , subscriptions =
               \model ->
                   Animation.subscription
                       Animate
                       model.styles
           }



-}
{-

   module Main exposing (Model, init, main, update, view)

   import Animation as A
   import Browser
   import Element exposing (..)
   import Html
   import Html.Attributes as HA
   import Html.Events
   import Svg exposing (..)
   import Svg.Attributes exposing (..)


   type Msg
       = Animate A.Msg
       | Show


   type alias Model =
       { style : A.State }


   init : flags -> ( Model, Cmd Msg )
   init flags =
       ( { style =
               A.style
                   [ A.left (A.px 0.0)
                   , A.opacity 1.0
                   ]
         }
       , Cmd.none
       )


   main : Program () Model Msg
   main =
       Browser.element
           { init = init
           , view = view
           , update = update
           , subscriptions = subscriptions
           }


   view : Model -> Html.Html Msg
   view model =
       Html.div
           (List.concat <|
               [ A.render model.style
               , [ HA.style "position" "absolute"
                 , HA.style "border-style" "dotted"
                 , HA.style "translateX" "500px"
                 , Html.Events.onClick Show
                 ]
               ]
           )
           [ Html.text "This is being Animated!"
           ]


   update : Msg -> Model -> ( Model, Cmd Msg )
   update msg model =
       case msg of
           Show ->
               let
                   newStyle =
                       A.interrupt
                           [ A.to
                               [ A.left (A.px 1000.0)
                               , A.opacity 1.0
                               ]
                           ]
                           model.style
               in
               ( { model
                   | style = newStyle
                 }
               , Cmd.none
               )

           Animate animationMsg ->
               ( { model
                   | style = A.update animationMsg model.style
                 }
               , Cmd.none
               )


   subscriptions : Model -> Sub Msg
   subscriptions model =
       A.subscription Animate [ model.style ]
-}
{-

   module Main exposing (Model, Msg(..), main, update, view)

   import Animation exposing (px, turn)
   import Browser
   import Html exposing (div)
   import Html.Attributes as H
   import Svg
   import Svg.Attributes exposing (..)


   type alias Model =
       {}


   type Msg
       = NoOp


   main : Program () Model Msg
   main =
       Browser.sandbox
           { init = {}
           , view = view
           , update = update
           }


   view : Model -> Html.Html Msg
   view model =
       div []
           [ Svg.svg
               [ width "250", height "340" ]
               [ Svg.g [ transform "translate(120,120)scale(0.5)" ]
                   [ Svg.g (Animation.render (Animation.style [ Animation.rotate (turn 0) ]))
                       [ Svg.g []
                           [ Svg.path
                               (Animation.render (Animation.style [ Animation.rotate (turn 0) ])
                                   ++ [ d "m 111.42237,87.857503 a 33.072916,33.072916 0 0 1 27.07846,16.499257 33.072916,33.072916 0 0 1 0,33.07291 33.072916,33.072916 0 0 1 -28.64218,16.53646 33.072916,33.072916 0 0 0 -28.642183,16.53646 33.072916,33.072916 0 0 0 0,33.07291 33.072916,33.072916 0 0 0 28.642183,16.53646 66.145835,66.145835 0 0 0 57.28384,-33.07291 66.145835,66.145835 0 0 0 0,-66.14584 66.145835,66.145835 0 0 0 -55.72012,-33.035707 z"
                                      , style "opacity:1;fill:#282a36;fill-opacity:1;stroke:none;stroke-width:0.21218663;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:stroke markers fill"
                                      ]
                               )
                               []
                           ]
                       , Svg.g []
                           [ Svg.path
                               (Animation.render (Animation.style [ Animation.rotate (turn 0) ])
                                   ++ [ d "m 126.67001,187.03917 a 16.536459,16.536459 0 0 1 -16.53646,16.53645 16.536459,16.536459 0 0 1 -16.536457,-16.53645 16.536459,16.536459 0 0 1 16.536457,-16.53646 16.536459,16.536459 0 0 1 16.53646,16.53646 z"
                                      , style "opacity:1;fill:#bd93f9;fill-opacity:1;stroke:none;stroke-width:0.21218663;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:stroke markers fill"
                                      ]
                               )
                               []
                           ]
                       ]
                   , Svg.g []
                       [ Svg.path
                           (Animation.render (Animation.style [ Animation.rotate (turn 0) ])
                               ++ [ style "opacity:1;fill:#bd93f9;fill-opacity:1;stroke:none;stroke-width:0.21218663;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:stroke markers fill"
                                  , d "m 108.29493,220.07475 a 33.072916,33.072916 0 0 1 -27.078458,-16.49925 33.072916,33.072916 0 0 1 0,-33.07292 33.072916,33.072916 0 0 1 28.642178,-16.53645 33.072916,33.072916 0 0 0 28.64218,-16.53646 33.072916,33.072916 0 0 0 0,-33.07292 33.072916,33.072916 0 0 0 -28.64218,-16.536457 66.145835,66.145835 0 0 0 -57.283834,33.072917 66.145835,66.145835 0 0 0 0,66.14583 66.145835,66.145835 0 0 0 55.720114,33.03571 z"
                                  ]
                           )
                           []
                       ]
                   , Svg.g []
                       [ Svg.path
                           (Animation.render (Animation.style [ Animation.rotate (turn 0) ])
                               ++ [ d "m 93.04729,120.89309 a 16.536459,16.536459 0 0 1 16.53646,-16.53646 16.536459,16.536459 0 0 1 16.53645,16.53646 16.536459,16.536459 0 0 1 -16.53645,16.53646 16.536459,16.536459 0 0 1 -16.53646,-16.53646 z"
                                  , style "opacity:1;fill:#282a36;fill-opacity:1;stroke:none;stroke-width:0.21218663;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:stroke markers fill"
                                  ]
                           )
                           []
                       ]
                   ]
               ]
           ]



   {-
      [ S.path [ style "stroke-width:2.82940078", d "m 86.850342,144.88495 c -0.51446,0 -0.926029,0.30867 -0.926029,0.97747 0,1.28615 3.241102,3.344 7.408232,3.344 10.546445,0 11.935485,-15.22804 13.684645,-23.4594 1.38905,-6.63654 2.62375,-8.02559 3.13821,-8.23137 0,0 2.6752,0.87458 5.96775,0.87458 3.65267,0 7.09955,-4.93882 7.09955,-5.9163 0,-0.5659 -0.46301,-1.02892 -1.08037,-1.02892 -0.72024,0 -1.33759,1.69772 -6.63654,1.69772 -8.74583,0 -12.19271,-1.69772 -19.035036,-1.69772 -4.012792,0 -10.134872,1.44049 -10.134872,6.73944 0,4.06423 4.938821,6.63654 7.665462,6.63654 0.720244,0 1.080367,-0.30868 1.080367,-0.97748 0,-0.72024 -2.520857,-1.69772 -2.520857,-4.83593 0,-2.36652 2.160734,-3.9099 5.247498,-3.9099 4.115688,0 7.768358,0.97748 9.363178,1.80062 0,0 -3.75556,0.5659 -5.86485,8.33426 -2.263623,8.33426 -5.29894,19.90962 -12.244157,19.90962 -0.977475,0 -1.543382,-0.25723 -2.212181,-0.25723 z" ] []
      , S.path [ style "opacity:1;fill:#bd93f9;fill-opacity:1;stroke:none;stroke-width:0.21218663;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:stroke markers fill", d "m 108.29493,220.07475 a 33.072916,33.072916 0 0 1 -27.078458,-16.49925 33.072916,33.072916 0 0 1 0,-33.07292 33.072916,33.072916 0 0 1 28.642178,-16.53645 33.072916,33.072916 0 0 0 28.64218,-16.53646 33.072916,33.072916 0 0 0 0,-33.07292 33.072916,33.072916 0 0 0 -28.64218,-16.536457 66.145835,66.145835 0 0 0 -57.283834,33.072917 66.145835,66.145835 0 0 0 0,66.14583 66.145835,66.145835 0 0 0 55.720114,33.03571 z" ] []
      , S.path [ style "opacity:1;fill:#282a36;fill-opacity:1;stroke:none;stroke-width:0.21218663;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:stroke markers fill", d "m 111.42237,87.857503 a 33.072916,33.072916 0 0 1 27.07846,16.499257 33.072916,33.072916 0 0 1 0,33.07291 33.072916,33.072916 0 0 1 -28.64218,16.53646 33.072916,33.072916 0 0 0 -28.642183,16.53646 33.072916,33.072916 0 0 0 0,33.07291 33.072916,33.072916 0 0 0 28.642183,16.53646 66.145835,66.145835 0 0 0 57.28384,-33.07291 66.145835,66.145835 0 0 0 0,-66.14584 66.145835,66.145835 0 0 0 -55.72012,-33.035707 z" ] []
      , S.path [ style "opacity:1;fill:#bd93f9;fill-opacity:1;stroke:none;stroke-width:0.21218663;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:stroke markers fill", d "m 126.67001,187.03917 a 16.536459,16.536459 0 0 1 -16.53646,16.53645 16.536459,16.536459 0 0 1 -16.536457,-16.53645 16.536459,16.536459 0 0 1 16.536457,-16.53646 16.536459,16.536459 0 0 1 16.53646,16.53646 z" ] []
      , S.path [ style "opacity:1;fill:#282a36;fill-opacity:1;stroke:none;stroke-width:0.21218663;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:stroke markers fill", d "m 93.04729,120.89309 a 16.536459,16.536459 0 0 1 16.53646,-16.53646 16.536459,16.536459 0 0 1 16.53645,16.53646 16.536459,16.536459 0 0 1 -16.53645,16.53646 16.536459,16.536459 0 0 1 -16.53646,-16.53646 z" ] []
      ]
   -}


   update : Msg -> Model -> Model
   update msg model =
       model

-}
{-
   module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

   import Animation
   import Browser
   import Element exposing (..)
   import Html
   import Svg
   import Svg.Attributes as SA


   type alias Model =
       { style : Animation.State }


   type Msg
       = Animate Animation.Msg
       | Hover


   type alias Color =
       { red : Int, green : Int, blue : Int, alpha : Float }


   rgb : Int -> Int -> Int -> Color
   rgb r g b =
       { red = r, green = g, blue = b, alpha = 1 }


   palette =
       { cyan = rgb 129 233 243
       }


   animation : Element Msg
   animation =
       html <|
           Svg.svg [ SA.x "0", SA.y "0", SA.height "100", SA.width "100" ] <|
               [ Svg.svg [ SA.d "m 85.541907,150.78261 c -0.63201,0 -1.137619,0.37921 -1.137619,1.20082 0,1.58003 3.981667,4.10807 9.100953,4.10807 12.956219,0 14.662649,-18.70751 16.811479,-28.81968 1.70643,-8.15294 3.22326,-9.85937 3.85527,-10.11217 0,0 3.28645,1.07442 7.33132,1.07442 4.48727,0 8.72175,-6.06731 8.72175,-7.26813 0,-0.69521 -0.56881,-1.26402 -1.32723,-1.26402 -0.88481,0 -1.64322,2.08564 -8.15293,2.08564 -10.74418,0 -14.97865,-2.08564 -23.384395,-2.08564 -4.929682,0 -12.450608,1.76963 -12.450608,8.27934 0,4.99288 6.067301,8.15294 9.416957,8.15294 0.884815,0 1.327223,-0.37921 1.327223,-1.20082 0,-0.88482 -3.096852,-2.08564 -3.096852,-5.9409 0,-2.90725 2.654444,-4.80328 6.446508,-4.80328 5.056087,0 9.543357,1.20082 11.502597,2.21203 0,0 -4.61368,0.69522 -7.20493,10.23858 -2.78084,10.23857 -6.509704,24.4588 -15.041847,24.4588 -1.20082,0 -1.896032,-0.316 -2.717646,-0.316 z", SA.style "stroke-width:3" ] []
               ]


   polygons : List (List Animation.Property)
   polygons =
       [ [ Animation.points
               []
         , Animation.fill palette.cyan
         ]
       ]


   update : Msg -> Model -> ( Model, Cmd Msg )
   update msg model =
       case msg of
           Animate animationMsg ->
               ( model, Cmd.none )

           Hover ->
               ( model, Cmd.none )


   view : Model -> Html.Html Msg
   view model =
       Element.layout [] <|
           column
               []
               [ animation
               ]


   subscriptions : Model -> Sub Msg
   subscriptions model =
       Animation.subscription Animate [ model.style ]


   init : flags -> ( Model, Cmd Msg )
   init flags =
       ( { style = Animation.style []
         }
       , Cmd.none
       )


   main : Program () Model Msg
   main =
       Browser.element
           { init = init
           , view = view
           , update = update
           , subscriptions = subscriptions
           }
-}


module Main exposing (..)
