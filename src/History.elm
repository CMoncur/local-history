module History exposing
  ( History
  , back
  , push
  , pushLocal
  , revise
  )

{-|
# Types
@docs History

# Session Storage Utilities
@docs back, push, revise

# Local Storage Utilities
@docs pushLocal
-}

-- Core Dependencies
import Task

-- Local Dependencies
import Native.History as Native

{-| History data type, where `a` represents the base
model or record that will be recorded.
-}
type alias History a =
  { a
  | local_back      : List Int
  , local_current   : Int
  , local_history   : List Int
  , local_next      : List Int
  , session_back    : List Int
  , session_current : Int
  , session_history : List Int
  , session_next    : List Int
  }

{-| Reverts model or record back to the it's most
recent state.

    History.back model
-}
back : History a
  -> ( History a -> msg )
  -> ( History a, Cmd msg )
back model msg =
  let
    ( key, remainder ) =
      getBack model.session_back

    ( back, cur, hist, next ) =
      getSessionState model
  in
    { model
    | session_back = remainder
    , session_next = next
    } !
    [ Native.get key model
      |> Task.perform msg
    ]

{-| Updates the model and logs the new model
state as a session storage entry.

    History.push model url Saved
-}
push : History a
  -> ( Int -> msg )
  -> ( History a, Cmd msg )
push model msg =
  let
    key =
      ( List.length model.session_history )

    ( back, _, hist, _ ) =
      getSessionState model
  in
    { model
    | session_back = key :: back
    , session_current = key
    , session_history = key :: hist
    , session_next = []
    } !
    [ Native.push key model False
      |> Task.perform msg
    ]

{-| Updates the model and logs the new model
state as a local storage entry.

    History.pushCache model Cached
-}
pushLocal : History a
  -> ( Int -> msg )
  -> ( History a, Cmd msg )
pushLocal model msg =
  let
    key =
      ( List.length model.local_history )
  in
    { model
    | local_back =
        key :: model.local_back
    , local_next = []
    } !
    [ Native.push key model True
      |> Task.perform msg
    ]

{-| Revise the model without logging the model
as a history entry.

    History.revise model url
-}
revise : History a -> String -> ( History a, Cmd msg )
revise model url =
  model ! [ Nav.modifyUrl url ]


{-------------------------------}
{--- Private Functions ---------}
{-------------------------------}

{-| Helper function that returns an integer
representing the key of the storage entry.

    getBack [1, 2, 3] == 1
-}
getBack : List Int -> ( Int, List Int )
getBack back =
  case back of
    []      -> ( 0, [] )
    [ a ]   -> ( a, [] )
    a :: b  -> ( a, b )

{-| Helper function that returns each session
value as items within a tuple.

    getSessionState model == ( [], 0, [], [] )
-}
getSessionState : History a
  -> ( List Int, Int, List Int, List Int )
getSessionState model =
  ( model.session_back
  , model.session_current
  , model.session_history
  , model.session_next
  )
