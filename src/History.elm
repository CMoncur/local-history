module History exposing
  ( History
  , back
  , push
  , revise
  )

{-|
# Types
@docs History

# Utilities
@docs back, push, revise
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
  | local_history : ( Int, List Int )
  }

{-| Reverts model back to the it's most recent state.

    History.back model
-}
back : History a
  -> ( History a -> msg )
  -> ( History a, Cmd msg )
back model msg =
  let
    cmd =
      Native.get 1 model
        |> Task.perform msg
  in
    model ! [ cmd ]

{-| Updates the model and logs the new model
state as a session storage entry.

    History.push model url Saved
-}
push : History a
  -> String
  -> ( Int -> msg )
  -> ( History a, Cmd msg )
push model url msg =
  let
    cmd =
      Native.push 1 model
        |> Task.perform msg
  in
    model !
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
