module History exposing
  ( Base
  , History
  , back
  , init
  , push
  , pushLocal
  , revise
  )

{-| Full package description goes here

# Types
@docs History, Base

# Session Storage Utilities
@docs back, init, push, revise

# Local Storage Utilities
@docs pushLocal
-}

-- Core Dependencies
import Task exposing ( Task )

-- Local Dependencies
import Native.History as Native

--Types
{-| Base record that the local_history package
leverages.
-}
type alias Base =
  { local_back      : List Int
  , local_current   : Int
  , local_history   : List Int
  , local_next      : List Int
  , session_back    : List Int
  , session_current : Int
  , session_history : List Int
  , session_next    : List Int
  }

{-| History data type, where `a` represents the base
model or record that will be recorded.
-}
type alias History a =
  { a
  | local_history : Base
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
      getBack model.local_history.session_back

    fresh_model =
      historyBack model key remainder
  in
    fresh_model !
    [ Native.get key model False
      |> Task.andThen (\ m -> restoreHistory m fresh_model )
      |> Task.perform msg
    ]

{-| Returns initial values that the
local_history package relies upon

    History.init
-}
init : Base
init =
  { local_back      = []
  , local_current   = 0
  , local_history   = []
  , local_next      = []
  , session_back    = []
  , session_current = 0
  , session_history = []
  , session_next    = []
  }

{-| Updates the model and logs the new model
state as a session storage entry.

    History.push model Saved
-}
push : History a
  -> ( Int -> msg )
  -> ( History a, Cmd msg )
push model msg =
  let
    hist =
      model.local_history

    key =
      ( List.length hist.session_history )

    fresh_model =
      historyPush model key
  in
    fresh_model !
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
  ( model, Cmd.none )

{-| Revise the model without logging the model
as a history entry.

    History.revise model
-}
revise : History a -> ( History a, Cmd msg )
revise model =
  ( model, Cmd.none )


{-------------------------------}
{--- Private Functions ---------}
{-------------------------------}

{-| Returns an integer representing the
key of the storage entry.
-}
getBack : List Int -> ( Int, List Int )
getBack back =
  case back of
    []      -> ( 0, [] )
    [ a ]   -> ( a, [] )
    a :: b  -> ( a, b )

{-| Returns each session value as items
within a tuple.
-}
getSessionState : Base
  -> ( List Int, Int, List Int, List Int )
getSessionState base =
  ( base.session_back
  , base.session_current
  , base.session_history
  , base.session_next
  )

{-| Updates session history after record has
been restored from session storage
-}
historyBack : History a
  -> Int
  -> List Int
  -> History a
historyBack model key remainder =
  let
    history =
      model.local_history

    ( _, cur, _, next ) =
      getSessionState model.local_history

    fresh_history =
      { history
      | session_back    = remainder
      , session_current = key
      , session_next    = cur :: next
      }
  in
    { model | local_history = fresh_history }

{-| Updates session history after record has
been pushed to session storage
-}
historyPush : History a -> Int -> History a
historyPush model key =
  let
    history =
      model.local_history

    ( back, _, hist, _ ) =
      getSessionState model.local_history

    fresh_history =
      { history
      | session_back    = key :: back
      , session_current = key
      , session_history = key :: hist
      , session_next    = []
      }
  in
    { model | local_history = fresh_history }

{-| Restores history information after retrieving
a history entry from local or session storage.
-}
restoreHistory : History a
  -> History a
  -> Task x ( History a )
restoreHistory res back =
  let
    fresh_history =
      back.local_history
  in
    Task.succeed
      { res | local_history = fresh_history }
