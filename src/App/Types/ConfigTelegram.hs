{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}

module App.Types.ConfigTelegram where

import           Data.Aeson
import           Control.Monad         (mzero)
import           Prelude       hiding  (id)
import           Data.Time.LocalTime   (getCurrentTimeZone, utcToLocalTime)
import           Data.Time             (formatTime, defaultTimeLocale)
import           Data.Time.Clock.POSIX (posixSecondsToUTCTime)
-- import           Data.Time.Format     (makeLocalTime)

data SetupTelegramm = SetupTelegramm
                    { urlTelegramm            :: String
                    , nameTelegramm           :: String
                    , userNameTelegramm       :: String
                    , tokenTelegramm          :: String
                    , descriptionTelegramm    :: String
                    , aboutTelegramm          :: String
                    , commandTelegramm        :: String
                    , questionTelegrammRepeat :: String
                    } deriving Show

instance FromJSON SetupTelegramm where
  parseJSON (Object setupTelegramm) = SetupTelegramm
    <$> setupTelegramm .: "urlTelegramm"
    <*> setupTelegramm .: "nameTelegramm"
    <*> setupTelegramm .: "userNameTelegramm"
    <*> setupTelegramm .: "tokenTelegramm"
    <*> setupTelegramm .: "descriptionTelegramm"
    <*> setupTelegramm .: "aboutTelegramm"
    <*> setupTelegramm .: "commandTelegramm"
    <*> setupTelegramm .: "questionTelegrammRepeat"
  parseJSON _                       = mzero

data ResponseGetMe  = ResponseGetMe
                    { okResponseGetMe             :: Bool
                    , idResponseGetMe             :: Int
                    , is_botResponseGetMe         :: Bool
                    , first_nameResponseGetMe     :: String
                    , username                    :: String
                    , can_join_groups             :: Bool
                    , can_read_all_group_messages :: Bool
                    , supports_inline_queries     :: Bool
                     } deriving (Show)

instance FromJSON ResponseGetMe where
  parseJSON = withObject "ResponseGetMe" $ \o -> do
    okResponseGetMe             <- o      .: "ok"
    result                      <- o      .: "result"
    idResponseGetMe             <- result .: "id"
    is_botResponseGetMe         <- result .: "is_bot"
    first_nameResponseGetMe     <- result .: "first_name"
    username                    <- result .: "username"
    can_join_groups             <- result .: "can_join_groups"
    can_read_all_group_messages <- result .: "can_read_all_group_messages"
    supports_inline_queries     <- result .: "supports_inline_queries"
    return ResponseGetMe{..}

{-data ResponseUpdates = ResponseUpdates
                     { okResponseUpdates    :: Bool
                     , result               :: Array 
                      }

data ResponseUpdatesPost = ResponseUpdatesPost
                         { update_idPost :: Int
                         , messagePost   :: Array
                          }

data MessageUpdatesPost = MessageUpdatesPost
                        { message_id :: Int
                        , from       :: Array
                        , chat       :: Array
                        , date       :: String
                        , text       :: String
                         }

data FromUpdatesPost = FromUpdatesPost
                     { idFromUpdates         :: Int
                     , is_botFromUpdates     :: Bool
                     , first_nameFromUpdates :: String
                     , last_nameFromUpdates  :: String
                     , language_code         :: String
                      }

data ChatUpdatesPost = ChatUpdatesPost
                     { idChatUpdates     :: Int
                     , first_nameUpdates :: String
                     , last_nameUpdates  :: String
                     , typeUpdates       :: String
                      }

-}

data Update = Update
            { update_id :: Int
            , message_id :: Int
            , idUpdate :: Int
            , is_botUpdate :: Bool
            , first_nameUpdate :: String
            , last_name :: String
            , language_code :: String
            , date :: String
            , text :: String
             }

instance FromJSON Update where
  parseJSON = withObject "Update" $ \o -> do
    update_id        <- o .: "update_id"
    message          <- o .: "message"
    message_id       <- message .: "message_id"
    idUpdate         <- message .: "id"
    is_botUpdate     <- message .: "is_bot"
    first_nameUpdate <- message .: "first_name"
    last_name        <- message .: "last_name"
    language_code    <- message .: "language_code"
    date             <- message .: "data"
    text             <- message .: "text"
    return Update{..}

-- makeLocalTime :: String -> String
makeLocalTime timeEpoch = do
  timezone  <- getCurrentTimeZone
  let timeNow = show $ formatTime defaultTimeLocale "%Y-%m-%d %H:%M:%S"
           $ utcToLocalTime timezone $ posixSecondsToUTCTime timeEpoch
  return timeNow
