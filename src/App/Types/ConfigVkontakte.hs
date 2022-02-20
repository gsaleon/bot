{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}

module App.Types.ConfigVkontakte where

import           Data.Aeson
import           Control.Monad        (mzero)

data SetupVkontakte = SetupVkontakte
                    { urlVkontakte   :: String
                    , client_id      :: Int
                    , group_id       :: Int
                    , tokenVkontakte :: String
                    , version        :: Float   -- 5.131 in use
                    , lang           :: Int     -- 0-ru, 3-en
                    , test_mode      :: Int     -- 0-normal, 1-test
                    } deriving Show

instance FromJSON SetupVkontakte where
  parseJSON (Object setupVkontakte) = SetupVkontakte
    <$> setupVkontakte .: "urlVkontakte"
    <*> setupVkontakte .: "client_id"
    <*> setupVkontakte .: "group_id"
    <*> setupVkontakte .: "tokenVkontakte"
    <*> setupVkontakte .: "version"
    <*> setupVkontakte .: "lang"
    <*> setupVkontakte .: "test_mode"
  parseJSON _                       = mzero

data SessionKey = SessionKey
                { vkServer :: String
                , vkKey    :: String
                , vkTs     :: String
                } deriving (Show)

instance FromJSON SessionKey where
  parseJSON = withObject "SessionKey" $ \s -> do
    r        <- s .: "response"
    vkKey    <- r .: "key"
    vkServer <- r .: "server"
    vkTs     <- r .: "ts"
    return SessionKey {..}

data VkConnect = VkConnect
               { vkTsNew  :: String
               , updates  :: [UpdateVk]
               } deriving (Show, Eq)

instance FromJSON VkConnect where
  parseJSON = withObject "VkConnect" $ \v -> do
    vkTsNew  <- v        .: "ts"
    updates  <- v        .: "updates"
    return VkConnect {..}

data UpdateVk = UpdateVk
              { typevk   :: String
              , objectVk :: Object
              , fromId   :: Int              
              , text     :: String
              } deriving (Show, Eq)

instance FromJSON UpdateVk where
  parseJSON = withObject "UpdateVk" $ \u -> do
    typevk   <- u        .: "type"
    case typevk of
      "message_reply" -> do        
        objectVk <- u        .: "object"
        fromId   <- objectVk .: "from_id"
        text     <- objectVk .: "text"
        return UpdateVk {..}
      "message_new"   -> do
        objectVk  <- u         .: "object"
        messageUp <- objectVk  .: "message"
        fromId    <- messageUp .: "from_id"
        text      <- messageUp .: "text"
        return UpdateVk {..}
      _               -> fail ("unknown message type: " ++ typevk)
