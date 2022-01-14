{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

module App.Types.ConfigTelegram where

import           Data.Aeson
import           Control.Monad         (mzero)
import           Prelude       hiding  (id)
import           Data.Time.LocalTime   (getCurrentTimeZone, utcToLocalTime)
import           Data.Time             (formatTime, defaultTimeLocale)
import           Data.Time.Clock.POSIX (posixSecondsToUTCTime)
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
                       }

instance FromJSON ResultRequest where
  parseJSON (Object r) = ResultRequest
    <$> r .: "result"
  parseJSON _          = mzero

data ValueReq = ValueReq
              { update_id      :: Int
              , message_id     :: Int              
              , idChat         :: Int
              , first_nameChat :: String
              , last_nameChat  :: String
              , typeChat       :: String
              -- , date           :: Int
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
    -- date           <- message .: "data"
    text           <- message .: "text"
    return ValueReq{..}


{-instance FromJSON ValueReq where
  parseJSON (Object valueReq) = ValueReq
    <$> valueReq .: "update_id"
    -- <*> valueReq .: "message"
    <$> message .: "message_id"
  parseJSON _                 = mzero
-}

{-
data Message = Message
            { message_id  :: Int
            -- , fromMessage :: FromMessage
            -- , chatMessage :: ChatMessage
            -- , dateMessage :: String
            -- , textMessage :: String
            -- , entities    :: [Entities]
             } deriving (Show)

instance FromJSON Message where
  parseJSON (Object message) = Message
    <$> message .: "message_id"
    -- <*> message .: "date"
    -- <*> message .: "text"
  parseJSON _                 = mzero
-}
{-
instance FromJSON Message where
  parseJSON = withObject "message" $ \m -> do
    message_id    <- m .: "message_id"
    fromMessage   <- parseJSON (Object m)
    chatMessage   <- parseJSON (Object m)
    dateMessage   <- m .: "date"
    textMessage   <- m .: "text"
    entities      <- parseJSON (Object m)
    return Message{..}
-}
{-
data FromMessage = FromMessage
            { idFrom         :: Int
            , is_botFrom     :: Bool
            , first_nameFrom :: String
            , last_nameFrom  :: String
            , language_code  :: String
             } deriving (Show, Generic)

instance FromJSON FromMessage where
  parseJSON = withObject "fromMessage" $ \f -> do
    idFrom         <- f .: "id"
    is_botFrom     <- f .: "is_bot"
    first_nameFrom <- f .: "first_name"
    last_nameFrom  <- f .: "last_name"
    language_code  <- f .: "language_code"
    return FromMessage{..}


data ChatMessage = ChatMessage
             { idChat         :: Int
             , first_nameChat :: String
             , last_nameChat  :: String
             , typeChat       :: String
              } deriving (Show, Generic)

instance FromJSON ChatMessage where
  parseJSON = withObject "chatMessage" $ \c -> do
    idChat         <- c .: "chat"
    first_nameChat <- c .: "chat"
    last_nameChat  <- c .: "chat"
    typeChat       <- c .: "chat"
    return ChatMessage{..}

data Entities = Entities
              { offset  :: Int
              , lengthE :: Int
              , typeE   :: String
               } deriving (Show, Generic)

instance FromJSON Entities where
  parseJSON = withObject "entities" $ \e -> do
    offset  <- e .: "offset"
    lengthE <- e .: "length"
    typeE   <- e .: "type"
    return Entities{..}
-}
{-Update okUpdate resultUpdate
                ResultUpdate update_id message
                                       Message message_id from chate dateMessage textMessage
                                                          From idFrom is_botFrom first_nameFrom last_nameFrom language_code
                                                               Chat idChat first_nameChat last_nameChat typeChat
Update okUpdate ResultUpdate update_id
  Message message_id dateMessage textMessage
    From idFrom is_botFrom first_nameFrom last_nameFrom language_code
      Chat idChat first_nameChat last_nameChat typeChat
-}
-- data Update = Update Bool ResultUpdate Int Message Int String String FromMessage Int Bool String String ChatMessage Int String String String