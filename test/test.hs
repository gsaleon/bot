{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Control.Monad (mzero)
import           Control.Applicative ((<$>), (<*>))
import           Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as LC

data SendMessageWithKey = SendMessageWithKey
                 { textWithKey           :: String
                 , chat_idWithKey        :: Int
                 , reply_to_message_idTo :: Int
                 , reply_markup          :: InlineKeyboardMarkup
                 }

instance ToJSON SendMessageWithKey where
  toJSON (SendMessageWithKey textWithKey chat_idWithKey reply_to_message_idTo reply_markup) =
    object [
      "text"                .= textWithKey,
      "chat_id"             .= chat_idWithKey,
      "reply_to_message_id" .= reply_to_message_idTo,
      "reply_markup"        .= reply_markup
           ]

data InlineKeyboardButton = InlineKeyboardButton
                          { textKeyboardButton ::String
                          , callback_data      ::String
                          }

instance ToJSON InlineKeyboardButton where
    toJSON (InlineKeyboardButton textKeyboardButton callback_data) = object
      [ "text"    .= textKeyboardButton
      , "chat_id" .= callback_data
      ]

data InlineKeyboardMarkup = InlineKeyboardMarkup [InlineKeyboardButton]

instance ToJSON InlineKeyboardMarkup where
    toJSON (InlineKeyboardMarkup inline_keyboard) =
      object  [ "inline_keyboard" .= inline_keyboard
              ]

main :: IO ()
main = do
    let reply_markup' = InlineKeyboardMarkup [ InlineKeyboardButton "1" "1"
                                            , InlineKeyboardButton "2" "2"
                                            , InlineKeyboardButton "3" "3"
                                            , InlineKeyboardButton "4" "4"
                                            , InlineKeyboardButton "5" "5"
                                            ]
    let val = SendMessageWithKey  { textWithKey = "iuiuhikh"
                                  , chat_idWithKey = 9879879
                                  , reply_to_message_idTo =3546565
                                  , reply_markup = reply_markup'
                                  }
    LC.putStrLn $ encode $ val

{-
data V = V { a :: Int, x :: Int, y :: Int }

instance ToJSON V where
    toJSON (V a x y) = object
        [ "a" .= a
        , "nested" .= object
            [ "x" .= x
            , "y" .= y ]
        ]

ghci> import qualified Data.ByteString.Lazy.Char8 as B
ghci> B.putStrLn $ encode (V 1 2 3)
{"nested":{"x":2,"y":3},"a":1}
-}