module Main exposing ( main )

-- Core Dependencies
import Html exposing
  ( Html
  , br
  , button
  , div
  , text
  )
import Html.Events exposing ( onClick )

-- Package Dependencies
import Navigation as Navigation exposing ( Location )

-- Model/Msg Types
type alias Model =
  { history : List String
  }

type Msg
  = GoBack
  | Navigate String
  | UrlChange Location

-- Update Function
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    GoBack ->
      model ! [ Cmd.none ]

    Navigate url ->
      { model | history = url :: model.history }
      ! [ Navigation.newUrl url ]

    UrlChange _ ->
      model ! [ Cmd.none ]

-- View Functions
buttons : List String
buttons =
  [ "/landing"
  , "/about"
  , "/contact"
  , "/portfolio"
  ]

renderButton : String -> Html Msg
renderButton button_text =
  button
    [ onClick ( Navigate button_text ) ]
    [ text <| String.dropLeft 1 button_text ]

renderHistory : List String -> String
renderHistory history =
  history
    |> List.map (\ hs -> String.dropLeft 1 hs )
    |> String.join ", "

view : Model -> Html Msg
view model =
  div
    []
    [ div [] ( List.map renderButton buttons )
    , br [] []
    , text <| renderHistory model.history
    ]

-- Init Function
init : Location -> ( Model, Cmd Msg )
init location =
  ( initModel
  , Cmd.none
  )

initModel : Model
initModel =
  { history = []
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
