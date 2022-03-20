{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}

module App.Types.ConfigVkontakte where

import           Data.Aeson
-- import           Control.Monad        (mzero)
import           Data.Foldable        (asum)
-- import           Data.Text            (unpack)
-- import           Data.Maybe           (catMaybes)
-- import           Control.Applicative
import           Control.Monad

data SetupVkontakte = SetupVkontakte
                    { groupVkId      :: Int
                    , tokenVkontakte :: String
                    , descriptionVk  :: String
                    , aboutVk        :: String
                    , commandVk      :: String
                    , questionVk     :: String
                    } deriving Show

instance FromJSON SetupVkontakte where
  parseJSON = withObject "SetupVkontakte" $ \s -> do
    groupVkId       <- s .: "groupVkId"
    tokenVkontakte <- s .: "tokenVkontakte"
    descriptionVk  <- s .: "descriptionVk"
    aboutVk        <- s .: "aboutVk"
    commandVk      <- s .: "commandVk"
    questionVk     <- s .: "questionVk"
    return SetupVkontakte {..}

-- instance FromJSON SetupVkontakte where
--   parseJSON (Object setupVkontakte) = SetupVkontakte
--     <$> setupVkontakte .: "group_id"
--     <*> setupVkontakte .: "tokenVkontakte"
--     <*> setupVkontakte .: "descriptionVk"
--     <*> setupVkontakte .: "aboutVk"
--     <*> setupVkontakte .: "commandVk"
--     <*> setupVkontakte .: "questionVk"
--   parseJSON _                       = mzero

data SessionKey = SessionKey
                { vkServer :: String
                , vkKey    :: String
                , vkTs     :: String
                -- , vkPts    :: Int
                } deriving (Show)

instance FromJSON SessionKey where
  parseJSON = withObject "SessionKey" $ \s -> do
    r        <- s .: "response"
    vkKey    <- r .: "key"
    vkServer <- r .: "server"
    vkTs     <- r .: "ts"
    -- vkPts    <- r .: "pts"
    return SessionKey {..}

data VkGetUpdate = VkGetUpdate
               { vkTsNew  :: String
               , updates  :: [VkMessage]
               } deriving (Show, Eq)

instance FromJSON VkGetUpdate where
    parseJSON = withObject "VkGetUpdate" $ \v -> VkGetUpdate
        <$> v .: "ts"
        <*> v .: "updates"

{-data VkMessage = VkMessageReplay {fromIdReplay :: Int, peerIdReplay :: Int, textMessageReplay :: String}
               | VkMessageNew {fromIdNew :: Int, peerIdNew :: Int, textMessageNew :: String}
               deriving (Eq, Show)-}

{-instance FromJSON VkMessage where
  parseJSON obj =
    asum
         [ parseVkMessageReplay obj
         , parseVkMessageNew obj
         ]
    where
      parseVkMessageReplay = withObject "VkMessageReplay" $ \obj -> do
        o                 <- obj .: "object"
        fromIdReplay      <- o   .: "from_id"
        peerIdReplay      <- o   .: "peer_id"
        textMessageReplay <- o   .: "text"
        return VkMessageReplay {..}
      parseVkMessageNew = withObject "VkMessageReplay" $ \obj -> do
        o              <- obj .: "object"
        m              <- o   .: "message"
        fromIdNew      <- m   .: "from_id"
        peerIdNew      <- m   .: "peer_id"
        textMessageNew <- m   .: "text"
        return VkMessageNew {..}-}


data VkMessage = VkMessage
               { fromId :: Int
               , peerId :: Int
               , idMess :: Int
               , textMessVk :: String
               , typeMessage :: String } deriving (Eq, Show)

instance FromJSON VkMessage where
  parseJSON obj =
    asum
         [ parseVkMessageReplay obj
         , parseVkMessageNew obj
         , parseVkMessageTypingState obj
         ]
    where
      parseVkMessageReplay = withObject "VkMessageReplay" $ \obj -> do
        typeMessage <- obj .: "type"
        o           <- obj .: "object"
        fromId      <- o   .: "from_id"
        idMess      <- o   .: "id"
        peerId      <- o   .: "peer_id"
        textMessVk  <- o   .: "text"
        return VkMessage {..}
      parseVkMessageNew = withObject "VkMessageNew" $ \obj -> do
        typeMessage <- obj .: "type"
        o           <- obj .: "object"
        m           <- o   .: "message"
        fromId      <- m   .: "from_id"
        idMess      <- m   .: "id"
        peerId      <- m   .: "peer_id"
        textMessVk  <- m   .: "text"
        return VkMessage {..}
      parseVkMessageTypingState = withObject "VkMessageTypingState" $ \obj -> do
        typeMessage <- obj .: "type"
        o           <- obj .: "object"
        fromId      <- o   .: "from_id"
        idMess      <- o   .: "id"
        peerId      <- o   .: "to_id"
        textMessVk  <- o   .: "state"
        return VkMessage {..}

{-data VkGetUpdateMessage = VkGetUpdateMessage
               { vkTsNewMess  :: String
               , updatesMess  :: [Maybe [VkArray String]]
               } deriving (Show, Eq)

instance FromJSON VkGetUpdateMessage where
    parseJSON = withObject "VkGetUpdateMessage" $ \v -> VkGetUpdateMessage
        <$> v .: "ts"
        <*> v .: "updates"

newtype VkArray a = VkArray (Maybe a) deriving (Eq, Ord, Show)

instance FromJSON a => FromJSON (VkArray a) where
  parseJSON v = do
    case fromJSON v of
      Success a -> return (VkArray $ Just a)
      _         -> return (VkArray $ Nothing) :: String
-}

data KeyboardVkSetting = KeyboardVkSetting
                       { one_time :: Bool
                       , inline   :: Bool
                       , buttons  :: [[ButtonArray]]
                       } deriving (Show, Eq)

instance ToJSON KeyboardVkSetting where
  toJSON KeyboardVkSetting {..} = object [
    "one_time" .= one_time,
    "inline"   .= inline,
    "buttons"  .= buttons                ]

data ButtonArray = ButtonArray
                 { color  :: String
                 , action :: ButtonValue
                 } deriving (Show, Eq)

instance ToJSON ButtonArray where
  toJSON ButtonArray {..} = object [
    "action" .= action,
    "color"  .= color              ]

data ButtonValue = ButtonValue
                 { _type :: String
                 , label      :: String
                 , payload    :: PayloadValue
                 } deriving (Show, Eq)

instance ToJSON ButtonValue where
  toJSON ButtonValue {..} = object [
    "type"    .= _type,
    "label"   .= label,
    "payload" .= payload        ]

data PayloadValue = PayloadValue
                  { payloadValue :: String
                  } deriving (Show, Eq)

instance ToJSON PayloadValue where
  toJSON PayloadValue {..} = object [
     "payloadValue" .= payloadValue ]

data ResponseVkSendMessage = ResponseVkSendMessage { messageId :: Int }
  | ErrorVkSendMessage { errorMessVk :: Object, errorMessageVk :: String } deriving (Show)

instance FromJSON ResponseVkSendMessage where
  parseJSON = withObject "ResponseVkSendMessage" $ \r -> asum [
    ResponseVkSendMessage <$> r .: "response",
    ErrorVkSendMessage    <$> r .: "error" <*> r .: "error_msg"
                                                              ]
