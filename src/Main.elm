module Main exposing ( main )

-- Core Dependencies
import Html exposing
  ( Html
  , br
  , button
  , div
  , p
  , text
  )
import Html.Events exposing ( onClick )

-- Package Dependencies
import History exposing ( History )
import Navigation exposing ( Location )
import Task

-- Model/Msg Types
type alias Base =
  { route : String
  }

type alias Model = History Base

type Msg
  = GoBack
  | Navigate String
  | UrlChange Location
  | Saved

-- History Functions


-- Update Function
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  let m = model.current in
  case msg of
    GoBack ->
      let
        fresh_model = History.back model
      in
        fresh_model
        ! [ Navigation.modifyUrl fresh_model.current.route ]

    Navigate url ->
      History.push model Saved

    UrlChange _ ->
      model ! [ Cmd.none ]

    Saved ->
      let
        yeah = Debug.log "save succeeded" model
      in
        model ! [ Cmd.none ]

-- View Functions
buttons : List String
buttons =
  [ "/home"
  , "/about"
  , "/contact"
  , "/portfolio"
  , "/transition"
  , "/notfound"
  ]

renderButton : String -> Html Msg
renderButton button_text =
  button
    [ onClick ( Navigate button_text ) ]
    [ text <| String.dropLeft 1 button_text ]

renderHistory : Model -> Html Msg
renderHistory model =
  div [] ( List.map renderHistoryItem model.history )

renderHistoryItem : Base -> Html Msg
renderHistoryItem m =
  p [] [ text <| toString m ]

view : Model -> Html Msg
view model =
  div
    []
    [ div
        []
        ( ( button
            [ onClick GoBack ]
            [ text "Go Back" ]
        ) :: ( List.map renderButton buttons ) )
    , br [] []
    , renderHistory model
    ]


-- Init Function
init : Location -> ( Model, Cmd Msg )
init location =
  ( History.init initModel
  , Cmd.none
  )

initModel : Base
initModel =
  { route = "/"
  }

-- Elm Main
main : Program Never Model Msg
main =
  Navigation.program UrlChange
    { init          = init
    , subscriptions = (\ _ -> Sub.none )
    , update        = update
    , view          = view
    }
