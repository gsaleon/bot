{-# LANGUAGE OverloadedStrings #-}

module Services.Server where

import           Data.Aeson                       ((.=), object)
import           System.Exit                      (die)
import           Data.Maybe                       (fromJust)
import           Control.Monad                    (replicateM_)

import           App.Types.ConfigTelegram
import           Services.Telegramm               (makeRequest)

server :: Maybe SetupTelegramm -> String -> [(String, FilePath)] ->
                          String -> String -> [(String, Int)] -> Int -> Int -> IO ()
server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate = do
  putStrLn "Start server"
  let repeatN = (snd . head) userList
  let requestGetUpdateObject = object [ "timeout" .= (longPolling     :: Int)
                                      , "limit"   .= (1               :: Int)
                                      , "offset"  .= (offsetGetUpdate :: Int)
                                      ]
  let requestGetUpdate = "getUpdates"
  responseGetUpdate <- makeRequest token requestGetUpdate requestGetUpdateObject
                         logLevel logLevelInfo message  :: IO (Maybe ResultRequest)
{-  putStrLn $ case responseGetUpdate of
        Nothing                -> "Error decode response getUpdate"
        Just responseGetUpdate -> show responseGetUpdate-}
  if (result $ fromJust responseGetUpdate) == []
    then server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate
    else do
      let offsetGetUpdate = (update_id $ head $ result $ fromJust responseGetUpdate) + 1
      putStrLn ("offsetGetUpdate - " ++ show offsetGetUpdate)
      let value = head $ result $ fromJust responseGetUpdate
      if (head $ text $ value) /= '/'
        then do
          let textAnswer          = text $ head $ result $ fromJust responseGetUpdate
          let chat_id             = idChat $ head $ result $ fromJust responseGetUpdate
          let reply_to_message_id = message_id $ head $ result $ fromJust responseGetUpdate
          let requestSendMessageObject = object [ "text"                .= (textAnswer          :: String)
                                                , "chat_id"             .= (chat_id             :: Int)
                                                , "reply_to_message_id" .= (reply_to_message_id :: Int)
                                                ]
          let requestSendMessage = "sendMessage"
          replicateM_ repeatN ((makeRequest token requestSendMessage requestSendMessageObject
            logLevel logLevelInfo message :: IO (Maybe SendMessage)) >>= \responseSendMessage -> return ())
        else case head $ words $ text $ value of
          "/start"    -> do
              let textPost            = aboutTelegramm $ fromJust setupTelegramm
              let chat_id             = idChat $ head $ result $ fromJust responseGetUpdate
              let reply_to_message_id = message_id $ value
              let requestSendMessageObject = object [ "text"                .= (textPost            :: String)
                                                    , "chat_id"             .= (chat_id             :: Int)
                                                    , "reply_to_message_id" .= (reply_to_message_id :: Int)
                                                    ]
              let requestSendMessage = "sendMessage"
              responseSendMessage <- makeRequest token requestSendMessage requestSendMessageObject
                                       logLevel logLevelInfo message :: IO (Maybe SendMessage)
              server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate
          "/help"     -> do
              let textPost            = commandTelegramm $ fromJust setupTelegramm
              let chat_id             = idChat $ value
              let reply_to_message_id = message_id $ value
              let requestSendMessageObject = object [ "text"                .= (textPost            :: String)
                                                    , "chat_id"             .= (chat_id             :: Int)
                                                    , "reply_to_message_id" .= (reply_to_message_id :: Int)
                                                    ]
              let requestSendMessage = "sendMessage"
              responseSendMessage <- makeRequest token requestSendMessage requestSendMessageObject
                                       logLevel logLevelInfo message :: IO (Maybe SendMessage)
              server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate
          "/settings" -> do
              let textPost            = questionTelegrammRepeat $ fromJust setupTelegramm
              let chat_id             = idChat $ value
              let reply_to_message_id = message_id $ value
              let requestSendMessageObject =
                    object [ "text"                .= (textPost            :: String)
                           , "chat_id"             .= (chat_id             :: Int)
                           , "reply_to_message_id" .= (reply_to_message_id :: Int)
                           , "reply_markup"        .= ("inline_keyboard":[ {"text" .= ('1' :: Char), "callback_data" .= ('1' :: Char)}
                                                                         , {"text" .= ('2' :: Char), "callback_data" .= ('2' :: Char)}
                                                                         , {"text" .= ('3' :: Char), "callback_data" .= ('3' :: Char)}
                                                                         , {"text" .= ('4' :: Char), "callback_data" .= ('4' :: Char)}
                                                                         , {"text" .= ('5' :: Char), "callback_data" .= ('5' :: Char)}
                                                                         , {"text" .= ('6' :: Char), "callback_data" .= ('6' :: Char)}
                                                                         ]
                                                       )
                           ]
              let requestSendMessage = "sendMessage"
              responseSendMessage <- makeRequest token requestSendMessage requestSendMessageObject
                                       logLevel logLevelInfo message :: IO (Maybe SendMessage)
              putStrLn (show responseSendMessage)
              let userListNew = (first_nameChat value ++ last_nameChat value, 1) : userList :: [(String, Int)]
              server setupTelegramm logLevel logLevelInfo token message userListNew longPolling offsetGetUpdate
          "/quit"     -> die "Senk you very much, bye..."
      -- putStrLn (show userList)
      server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate