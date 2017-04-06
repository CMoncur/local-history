module History exposing
  ( Base
  , History
  , back
  -- , forward
  , init
  , push
  , revise
  )

{-| Full package description goes here

# Types
@docs Base
@docs History

# Session Storage Utilities
@docs back
@docs init
@docs push
@docs revise
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
  { back    : List Int
  , current : Int
  , history : List Int
  , next    : List Int
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

    History.back model GoBack
-}
back : History a
  -> ( History a -> msg )
  -> ( History a, Cmd msg )
back model msg =
  let
    ( key, remainder ) =
      getBack model.local_history.back

    fresh_model =
      historyBack model remainder

    cmd =
      if ( List.isEmpty model.local_history.back ) then
        Cmd.none
      else
        Native.get key model False
          |> Task.andThen (\ m -> restoreHistory m fresh_model )
          |> Task.perform msg
  in
    fresh_model !
    [ cmd ]

-- {-| Returns model from an older state to a newer state.
--
--     History.forward model GoForward
-- -}
-- forward : History a
--   -> ( History a -> msg )
--   -> ( History a, Cmd msg )
-- forward model msg =
--   let
--     ( key, remainder ) =
--       getBack model.local_history.back
--
--     fresh_model =
--       historyBack model remainder
--
--     cmd =
--       if ( List.isEmpty model.local_history.back ) then
--         Cmd.none
--       else
--         Native.get key model False
--           |> Task.andThen (\ m -> restoreHistory m fresh_model )
--           |> Task.perform msg
--   in
--     fresh_model !
--     [ cmd ]

{-| Returns initial values that the
local_history package relies upon

    History.init
-}
init : Base
init =
  { back    = []
  , current = 0
  , history = []
  , next    = []
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
      ( List.length hist.history )

    fresh_model =
      historyPush model key
  in
    fresh_model !
    [ Native.push key model False
      |> Task.perform msg
    ]

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
key of the storage entry, as well as a list
of previous keys.
-}
getBack : List Int -> ( Int, List Int )
getBack back =
  case back of
    []      -> ( 0, [] )
    [ a ]   -> ( a, [] )
    a :: b  -> ( a, b )

{-| Returns a list of keys that have already
been visited.
-}
getNext : List Int -> Int -> List Int -> List Int
getNext back cur next =
  case back of
    []  -> next
    _   -> cur :: next

{-| Returns each session value as items
within a tuple.
-}
getSessionState : Base
  -> ( List Int, Int, List Int, List Int )
getSessionState base =
  ( base.back
  , base.current
  , base.history
  , base.next
  )

{-| Updates session history after record has
been restored from session storage
-}
historyBack : History a
  -> List Int
  -> History a
historyBack model remainder =
  let
    history =
      model.local_history

    fresh_current =
      Maybe.withDefault 0 ( List.head remainder )

    ( back, cur, _, next ) =
      getSessionState history

    fresh_history =
      { history
      | back    = remainder
      , current = fresh_current
      , next    = getNext back cur next
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
      | back    = key :: back
      , current = key
      , history = key :: hist
      , next    = []
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
