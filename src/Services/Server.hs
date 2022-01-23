{-# LANGUAGE OverloadedStrings #-}

module Services.Server where

import           Data.Aeson                       (encode)
import           System.Exit                      (die)
import           Data.Maybe                       (fromJust)
import           Control.Monad                    (replicateM_)
import qualified Data.ByteString.Lazy.Char8 as LC      -- только для контроля
import           Prelude                  hiding  (id)

import           App.Types.ConfigTelegram
import           Services.Telegramm               (makeRequest)

server :: Maybe SetupTelegramm -> String -> [(String, FilePath)] ->
                          String -> String -> [(String, Int)] -> Int -> Int -> IO ()
server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate = do
  putStrLn "Start server"
  let repeatN = (snd . head) userList
  let requestGetUpdateObject = SendGetUpdate longPolling 1 offsetGetUpdate
  responseGetUpdate <- makeRequest token "getUpdates" requestGetUpdateObject
                         logLevel logLevelInfo message  :: IO (Maybe ResultRequest)
  putStrLn $ case responseGetUpdate of
        Nothing                -> "Error decode response getUpdate"
        Just responseGetUpdate -> show responseGetUpdate
  if (result <$> responseGetUpdate) == Just []
    then server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate
    else do
      let value = messageUpdate <$> head <$> result <$> responseGetUpdate
      let offsetGetUpdate = (fromJust $ update_idUpdate <$> head <$> result <$> responseGetUpdate) + 1
      putStrLn ("offsetGetUpdate - " ++ show offsetGetUpdate)
      if (head <$> textMessage <$> value) /= Just '/'
        then do
          let requestSendMessageObject = SendMessageTo    -- SendMessageTo {textTo, chat_idTo, reply_to_message_idTo}
                                          (fromJust $ textMessage <$> value)
                                          (fromJust $ idChat <$> chat <$> value)
                                          (fromJust $ message_idMessage <$> value)
          replicateM_ repeatN ((makeRequest token "sendMessage" requestSendMessageObject
            logLevel logLevelInfo message :: IO (Maybe SendMessage)) >>= \responseSendMessage -> return ())
        else case head $ words $ fromJust $ textMessage <$> value of
          "/start"    -> do
              let requestSendMessageObject = SendMessageTo  --SendMessageTo {textTo, chat_idTo, reply_to_message_idTo}
                                              (fromJust $ aboutTelegramm <$> setupTelegramm)
                                              (fromJust $ idChat <$> chat <$> value)
                                              (fromJust $ message_idMessage <$> value)
              responseSendMessage <- makeRequest token "sendMessage" requestSendMessageObject
                                       logLevel logLevelInfo message :: IO (Maybe SendMessage)
              server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate
          "/help"     -> do
              let requestSendMessageObject = SendMessageTo  --SendMessageTo {textTo, chat_idTo, reply_to_message_idTo}
                                              (fromJust $ commandTelegramm <$> setupTelegramm)
                                              (fromJust $ idChat <$> chat <$> value)
                                              (fromJust $ message_idMessage <$> value)
              responseSendMessage <- makeRequest token "sendMessage" requestSendMessageObject
                                       logLevel logLevelInfo message :: IO (Maybe SendMessage)
              server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate
          "/settings" -> do
{-              putStrLn ("chat_id - " ++ show (idChat (fromJust value))
                     ++ " reply_to_message_id - " ++ show (message_id (fromJust value)))-}
              let requestSendMessageObject = SendMessageWithKey  --SendMessageWithKey {textWithKey chat_idWithKey reply_to_message_idWithKey reply_markup}
                                              (fromJust $ questionTelegrammRepeat <$> setupTelegramm)
                                              (fromJust $ idChat <$> chat <$> value)
                                              (fromJust $ message_idMessage <$> value)
                                              (InlineKeyboardMarkup [ [InlineKeyboardButton "1" "1"]
                                                                    , [InlineKeyboardButton "2" "2"]
                                                                    , [InlineKeyboardButton "3" "3"]
                                                                    , [InlineKeyboardButton "4" "4"]
                                                                    , [InlineKeyboardButton "5" "5"]
                                                                    ]
                                              )
              -- LC.putStrLn $ encode requestSendMessageObject
              let requestSendMessage = "sendMessage"
              responseSendMessage <- makeRequest token requestSendMessage requestSendMessageObject
                                       logLevel logLevelInfo message :: IO (Maybe SendMessage)
              putStrLn ("/settings answer keyboard - " ++ show responseSendMessage)
              let userListNew = (first_nameChat (fromJust $ chat <$> value) ++ last_nameChat (fromJust $ chat <$> value), 1) : userList :: [(String, Int)]
              server setupTelegramm logLevel logLevelInfo token message userListNew longPolling offsetGetUpdate
          "/quit"     -> die "Senk you very much, bye..."
      -- putStrLn (show userList)
      server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate