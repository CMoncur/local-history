module Main exposing ( main )

-- Core Dependencies
import Html exposing
  ( Html
  , div
  , text
  )

-- Package Dependencies
import Navigation as Navigation exposing ( Location )
import UrlParser as Url

-- Model/Msg Types
type alias Model =
  { stuff   : Int
  , history : List String
  }

type Msg
  = ChangeStuff Int
  | ChangeUrl Location

-- Update Function
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ChangeStuff _ ->
      model ! [ Cmd.none ]

    ChangeUrl _ ->
      model ! [ Cmd.none ]

-- View Function
view : Model -> Html Msg
view model =
  div
    []
    [ text "hey"
    ]

-- Supporting Functions
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- Init Function
init : Location -> ( Model, Cmd Msg )
init location =
  ( initModel
  , Cmd.none
  )

initModel : Model
initModel =
  { stuff   = 0
  , history = []
  }

-- Elm Main
main : Program Never Model Msg
main =
  Navigation.program ChangeUrl
    { init          = init
    , subscriptions = subscriptions
    , update        = update
    , view          = view
    }
