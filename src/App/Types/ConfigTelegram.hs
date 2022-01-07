{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}

module App.Types.ConfigTelegram where

import           Data.Aeson
import           Control.Monad        (mzero)

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
