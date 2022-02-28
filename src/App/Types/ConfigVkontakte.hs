{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}

module App.Types.ConfigVkontakte where

import           Data.Aeson
-- import           Control.Monad        (mzero)
import           Data.Foldable        (asum)
import           Data.Text            (unpack)
import           Data.Maybe           (catMaybes)
import           Control.Applicative
import           Control.Monad

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
                , vkTs     :: Int
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
               { vkTsNew  :: Int
               , updates  :: [Maybe [Maybe' Int]]
               } deriving (Show, Eq)

instance FromJSON VkGetUpdate where
    parseJSON = withObject "VkGetUpdate" $ \v -> VkGetUpdate
        <$> v .: "ts"
        <*> v .: "updates"

data VkGetUpdateMessage = VkGetUpdateMessage
               { vkTsNewMess  :: Int
               , updatesMess  :: [Maybe [Maybe' String]]
               } deriving (Show, Eq)

instance FromJSON VkGetUpdateMessage where
    parseJSON = withObject "VkGetUpdateMessage" $ \v -> VkGetUpdateMessage
        <$> v .: "ts"
        <*> v .: "updates"

newtype Maybe' a = Maybe' (Maybe a) deriving (Eq, Ord, Show)

instance FromJSON a => FromJSON (Maybe' a) where
  parseJSON v = do
    case fromJSON v of
      Success a -> return (Maybe' $ Just a)
      _         -> return (Maybe' $ Nothing)


data ResponseVkSendMessage = ResponseVkSendMessage {messageId :: Int}
  | ErrorVkSendMessage {errorMessVk :: Object, errorMessageVk :: String} deriving (Show)

instance FromJSON ResponseVkSendMessage where
  parseJSON = withObject "ResponseVkSendMessage" $ \r -> asum [
    ResponseVkSendMessage <$> r .: "response",
    ErrorVkSendMessage    <$> r .: "error" <*> r .: "error_msg"
                                                              ]
