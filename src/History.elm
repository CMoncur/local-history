module History exposing
  ( History
  , back
  , cache
  , push
  , revise
  )

{-|
# Types
@docs History

# Session Storage Utilities
@docs back, push, revise

# Local Storage Utilities
@docs cache
-}

-- Core Dependencies
import Navigation as Nav
import Task

-- Local Dependencies
import Native.History as Native

{-| History data type, where `a` represents the base
model or record that will be recorded.
-}
type alias History a =
  { a
  | local_history   : ( Maybe String, List String )
  , session_history : ( Maybe Int, List Int )
  }

{-| Reverts model back to the it's most recent state.

    History.back model
-}
back : History a
  -> ( History a -> msg )
  -> ( History a, Cmd msg )
back model msg =
  let
    ( current, history ) =
      model.session_history

    cmd =
      Native.get 1 model
        |> Task.perform msg
  in
    model ! [ cmd ]

{-| Updates the model and logs the new model
state as a local storage entry.

    History.cache model Cached
-}
cache : History a
  -> ( String -> msg )
  -> ( History a, Cmd msg )
cache model msg =
  let
    history =
      Tuple.second model.local_history

    key =
      getLocalKey True history

    cmd =
      Native.push key model True
        |> Task.perform msg
  in
    model ! [ cmd ]

{-| Updates the model and logs the new model
state as a session storage entry. Also navigates
to supplied URL.

    History.push model url Saved
-}
push : History a
  -> String
  -> ( Int -> msg )
  -> ( History a, Cmd msg )
push model url msg =
  let
    history =
      Tuple.second model.session_history

    key =
      ( List.length history ) + 1

    cmd =
      Native.push key model False
        |> Task.perform msg
  in
    { model | session_history =
      ( Just key
      , key :: history
      )
    } !
    [ cmd
    , Nav.newUrl url
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

{-| Return a string that represents the key of the
local storage entry.

    getLocalKey True [] == "local_history_1"
-}
getLocalKey : Bool -> List String -> String
getLocalKey persistent history =
  let
    len_str : List String -> String
    len_str list =
      toString <| List.length list
  in
    String.concat
      [ "local_history_"
      , len_str history
      ]
