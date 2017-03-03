module History exposing
  ( Entry
  , History
  , back
  , init
  , push
  , revise
  )

{-|
# Primitives
@docs Entry, History

# Utilities
@docs back, init, push, revise
-}

-- Core Dependencies
import Navigation as Nav

{-| Entry item type, where `a` represents route and
`b` represents a model or similar record to store.
-}
type alias Entry a =
  { model     : History a
  , revisions : a
  , url       : String
  }

{-| History item type, where `a` represents route and
`b` represents a model or similar record to store.
-}
type alias History a =
  { current : a
  , history : List a
  }

{-| Subscribe to browser's onPopState event

    pack yeah == "yeah"
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

{-| Subscribe to browser's onPopState event

    pack yeah == "yeah"
-}
init : a -> History a
init initial_state =
  { history = []
  , current = initial_state
  }

{-| Subscribe to browser's onPopState event

    pack yeah == "yeah"
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

{-| Subscribe to browser's onPopState event

    pack yeah == "yeah"
-}
revise : History a -> a -> History a
revise model revisions =
  { model | current = revisions }


{-------------------------------}
{--- Private Functions ---------}
{-------------------------------}

{-| Subscribe to browser's onPopState event

    pack yeah == "yeah"
-}
remaining : List a -> List a
remaining history =
  case history of
    []       -> []
    [ a ]    -> []
    [ a, b ] -> [ b ]
    a :: b   -> b
