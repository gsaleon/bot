{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}


module App.Types.Config where

import           Control.Monad        (mzero)
import           Data.Aeson
import           Prelude hiding       (id)
-- import           Data.Text.Lazy.Encoding

data Os = Linux | Windows
  deriving (Show)

data Service = Telegramm | Vcontakte
  deriving (Show)

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

data SetupVcontakte = SetupVcontakte
                    { urlVcontakte         :: String
                    , nameVcontakte        :: String
                    , userNameVcontakte    :: String
                    , tokenVcontakte       :: String
                    , descriptionVcontakte :: String
                    , aboutVcontakte       :: String
                    , commandVcontakte     :: String
                    } deriving Show

instance FromJSON SetupVcontakte where
  parseJSON (Object setupVcontakte) = SetupVcontakte
    <$> setupVcontakte .: "urlVcontakte"
    <*> setupVcontakte .: "nameVcontakte"
    <*> setupVcontakte .: "userNameVcontakte"
    <*> setupVcontakte .: "tokenVcontakte"
    <*> setupVcontakte .: "descriptionVcontakte"
    <*> setupVcontakte .: "aboutVcontakte"
    <*> setupVcontakte .: "commandVcontakte"
  parseJSON _                       = mzero

data SetupGeneral = SetupGeneral
                  { pollingGeneral    :: Int
                  , repeatGeneral     :: Int
                  , logLevelGeneral   :: String
                  , serviceGeneral    :: String
                  } deriving Show

instance FromJSON SetupGeneral where
  parseJSON (Object setupGeneral) = SetupGeneral
    <$> setupGeneral .: "pollingGeneral"
    <*> setupGeneral .: "repeatGeneral"
    <*> setupGeneral .: "logLevelGeneral"
    <*> setupGeneral .: "serviceGeneral"
  parseJSON _                     = mzero

data ResponseGetMe  = ResponseGetMe
                    { ok                          :: Bool
                    , id                          :: Int
                    , is_bot                      :: Bool
                    , first_name                  :: String
                    , username                    :: String
                    , can_join_groups             :: Bool
                    , can_read_all_group_messages :: Bool
                    , supports_inline_queries     :: Bool
                     } deriving (Show)

instance FromJSON ResponseGetMe where
  parseJSON = withObject "ResponseGetMe" $ \o -> do
    ok                          <- o .: "ok"
    result                      <- o .: "result"
    id                          <- result .: "id"
    is_bot                      <- result .: "is_bot"
    first_name                  <- result .: "first_name"
    username                    <- result .: "username"
    can_join_groups             <- result .: "can_join_groups"
    can_read_all_group_messages <- result .: "can_read_all_group_messages"
    supports_inline_queries     <- result .: "supports_inline_queries"
    -- And finally return the value.
    return ResponseGetMe{..}

{-
data ResponseGetMe = ResponseGetMe
                   { ok                     :: Bool
                   , result                 :: !Object
                    } deriving (Show)

instance FromJSON ResponseGetMe where
  parseJSON (Object responseGetMe) = ResponseGetMe
    <$> responseGetMe .: "ok"
    <*> responseGetMe .: "result"
  parseJSON _                      = mzero

data ResultGetMe = ResultGetMe
              { id                          :: Int
              , is_bot                      :: Bool
              , first_name                  :: String
              , username                    :: String
              , can_join_groups             :: Bool
              , can_read_all_group_messages :: Bool
              , supports_inline_queries     :: Bool
               }  deriving (Show)

instance FromJSON ResultGetMe where
  parseJSON (Object resultGetMe) = ResultGetMe
    <$> resultGetMe .: "id"
    <*> resultGetMe .: "is_bot"
    <*> resultGetMe .: "first_name"
    <*> resultGetMe .: "username"
    <*> resultGetMe .: "can_join_groups"
    <*> resultGetMe .: "can_read_all_group_messages"
    <*> resultGetMe .: "supports_inline_queries"
  parseJSON _                    = mzero
-}