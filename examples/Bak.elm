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
  { history : List History
  }

type History = History ( String, Model )

type Msg
  = GoBack
  | Navigate String
  | UrlChange Location

-- Update Function
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    GoBack ->
      let
        history_item =
          Maybe.withDefault
            ( History ( "/notfound", initModel ) )
            ( List.head model.history )

        destination =
          unpackRoute history_item

        revised_history = List.drop 1 model.history
      in
        { model | history = revised_history }
        ! [ Navigation.modifyUrl destination ]

    Navigate url ->
      case url of
        "/transition" ->
          model
          ! [ Navigation.modifyUrl url ]
        _ ->
          let
            history_item = History ( url, model )
          in
            { model | history = history_item :: model.history }
            ! [ Navigation.newUrl url ]

    UrlChange _ ->
      model ! [ Cmd.none ]

unpackHistoryItem : History -> ( String, Model )
unpackHistoryItem ( History h ) =
  h

unpackRoute : History -> String
unpackRoute history_item =
  Tuple.first ( unpackHistoryItem history_item )

-- View Functions
buttons : List String
buttons =
  [ "/landing"
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

renderHistory : List History -> String
renderHistory history =
  history
    |> List.map unpackRoute
    |> List.map (\ hs -> String.dropLeft 1 hs )
    |> String.join ", "

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
    , text <| renderHistory model.history
    , br [] []
    , text <| toString model.history
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
