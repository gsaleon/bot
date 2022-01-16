{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

module App.Types.ConfigTelegram where

import           Data.Aeson
import           Control.Monad         (mzero)
import           Prelude       hiding  (id)
import           Data.Time.LocalTime   (getCurrentTimeZone, utcToLocalTime)
import           Data.Time             (formatTime, defaultTimeLocale)
import           Data.Time.Clock.POSIX (posixSecondsToUTCTime)
import           Network.HTTP.Client   (Request, Manager)
-- import           GHC.Generics
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

-- makeLocalTime :: String -> String
makeLocalTime timeEpoch = do
  timezone  <- getCurrentTimeZone
  let timeNow = show $ formatTime defaultTimeLocale "%Y-%m-%d %H:%M:%S"
           $ utcToLocalTime timezone $ posixSecondsToUTCTime timeEpoch
  return timeNow

newtype ResultRequest = ResultRequest
                      { result :: [ValueReq]
                       } deriving (Show)

instance FromJSON ResultRequest where
  parseJSON (Object r) = ResultRequest
    <$> r .: "result"
  parseJSON _          = mzero

newtype SendMessage = SendMessage
                      { result' :: ValueReq
                       } deriving (Show)

instance FromJSON SendMessage where
  parseJSON (Object s) = SendMessage
    <$> s .: "result"
  parseJSON _          = mzero

data ValueReq = ValueReq
              { update_id      :: Int
              , message_id     :: Int              
              , idChat         :: Int
              , first_nameChat :: String
              , last_nameChat  :: String
              , typeChat       :: String
              , text           :: String
               } deriving (Show)

instance FromJSON ValueReq where
  parseJSON = withObject "ValueReq" $ \o -> do
    update_id      <- o       .: "update_id"
    message        <- o       .: "message"
    message_id     <- message .: "message_id"
    chat           <- message .: "chat"
    idChat         <- chat    .: "id"
    first_nameChat <- chat    .: "first_name"
    last_nameChat  <- chat    .: "last_name"
    typeChat       <- chat    .: "type"
    text           <- message .: "text"
    return ValueReq{..}

data HandleTelegram = HandleTelegram
    { requestTelegram :: Request -> Manager -> IO () }
