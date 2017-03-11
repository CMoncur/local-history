module History exposing
  ( Entry
  , History
  , back
  , init
  , push
  , revise
  )

{-|
# Types
@docs Entry, History

# Utilities
@docs back, init, push, revise
-}

-- Core Dependencies
import Navigation as Nav

{-| Entry item type, where `a` represents the base
model to be revised and stored within the history
-}
type alias Entry a =
  { model     : History a
  , revisions : a
  , url       : String
  }

{-| History data type, where `a` represents the base
model or record that will be recorded.
-}
type alias History a =
  { current : a
  , history : List a
  }

{-| Reverts model back to the it's most recent state.

    History.back model
-}
back : History a -> History a
back model =
  let
    recent = Maybe.withDefault
      model.current
      ( List.head model.history )

    remainder =
      remaining model.history
  in
    { history = remainder
    , current = recent
    }

{-| Creates an inital model which includes the
history list and initial state of base model. Can
simply wrap an init function.

    main : Program Never Model Msg
    main =
      Navigation.program UrlChange
        { init = ( History.init initModel, Cmd.none )
        , subscriptions = (\ _ -> Sub.none )
        , update = update
        , view = view
        }
-}
init : a -> History a
init initial_state =
  { history = []
  , current = initial_state
  }

{-| Updates the model and logs the new model
state as a history entry.

    History.push
      { model     = model
      , revisions = { m | route = url }
      , url       = url
      }
-}
push : Entry a -> ( History a, Cmd msg )
push entry =
  let
    m = entry.model
  in
    { m
    | history = m.current :: m.history
    , current = entry.revisions
    }
    ! [ Nav.newUrl entry.url ]

{-| Revise the model without logging the model
as a history entry.

    History.revise
      { model     = model
      , revisions = { m | route = url }
      , url       = url
      }
-}
revise : Entry a -> ( History a, Cmd msg )
revise entry =
  let
    m = entry.model
  in
    { m | current = entry.revisions }
    ! [ Nav.modifyUrl entry.url ]


{-------------------------------}
{--- Private Functions ---------}
{-------------------------------}

{-| Return a list with one less history entry.

    remaining [ a, b ] == [ b ]
-}
remaining : List a -> List a
remaining history =
  case history of
    []       -> []
    [ a ]    -> []
    [ a, b ] -> [ b ]
    a :: b   -> b
