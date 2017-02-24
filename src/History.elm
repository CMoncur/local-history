module History exposing
  ( History
  , pack
  , unpack
  -- , goBack
  -- , goBackNum
  )

{-|
# Primitives
@docs History

# Utilities
@docs unpack, pack
-}

{-| History item type, where `a` represents route and
`b` represents a model or similar record to store.
-}
type History a
  = History a

{-| Subscribe to browser's onPopState event

    unpack yeah == "yeah"
-}
pack : a -> ( History a )
pack a =
  History a

{-| Subscribe to browser's onPopState event

    unpack yeah == "yeah"
-}
unpack : ( History a ) -> a
unpack ( History a ) =
  a
