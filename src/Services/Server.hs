{-# LANGUAGE OverloadedStrings #-}

module Services.Server where

-- import           Data.Aeson                       (encode)
import           Data.Char                        (digitToInt)
import           System.Exit                      (die)
import           Data.Maybe                       (fromJust)
import           Control.Monad                    (replicateM_)
-- import qualified Data.ByteString.Lazy.Char8 as LC      -- только для контроля
import           Prelude                  hiding  (id)

import           App.Types.ConfigTelegram
import           Services.Telegramm               (makeRequest)

server :: Maybe SetupTelegramm -> String -> [(String, FilePath)] ->
                          String -> String -> [(Int, Int)] -> Int -> Int -> IO ()
server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate = do
  putStrLn "Start server"
  let requestSendMessageObject = SendGetUpdate longPolling 1 offsetGetUpdate  -- SendGetUpdate timeout limit offset
  -- let typeResponse = "getUpdates"
  responseGetUpdate <- makeRequestTelegrammGetUpdates token requestSendMessageObject logLevel logLevelInfo message
{-  putStrLn $ case responseGetUpdate of
        Nothing                -> "Error decode response getUpdate"
        Just responseGetUpdate -> show responseGetUpdate-}
  if (result <$> responseGetUpdate) == Just []
    then server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate
    else do
      let value = messageUpdate . head . result <$> responseGetUpdate
      let offsetGetUpdate = (fromJust $ update_idUpdate . head . result <$> responseGetUpdate) + 1
      -- putStrLn ("offsetGetUpdate - " ++ show offsetGetUpdate)
      -- let callbackQueryIdUser = idUser . from . messageCallbackQuery . callback_query . head . result <$> responseGetUpdate
      let callbackQueryIdUser = init $ fromJust $ textMessage <$> value
      if (callbackQueryIdUser) == "The number of repetitions - "
        then do
          -- let button = read (fromJust $ dataCallbackQuery . callback_query . head . result <$> responseGetUpdate) :: Int
          -- let userListNew = (fromJust callbackQueryIdUser, button) : userList :: [(Int, Int)]          
          let button = digitToInt (last $ fromJust $ textMessage <$> value)
          let userID = fromJust $ idUser . from <$> value
          let userListNew = (userID, button) : userList :: [(Int, Int)]
          let requestSendMessageObject = SendMessageHideKeyboard           -- SendMessageHideKeyboard {textHideKeyboard, chat_idHideKeyboard, reply_markupHideKeyboard}
                                          ("HideKeyboard")
                                          (fromJust $ idChat <$> chat <$> value)
                                          (ReplyKeyboardHide {hide_keyboard = True})
          -- putStrLn $ show requestSendMessageObject
          responseGetUpdate <- makeRequestTelegrammSendMessage token requestSendMessageObject logLevel logLevelInfo message
          putStrLn ("For userId - " ++ show userID ++ ", set namber repeat - " ++ show button ++ ", userList: " ++ show userListNew)
          server setupTelegramm logLevel logLevelInfo token message userListNew longPolling offsetGetUpdate
        else
          if (head . textMessage <$> value) /= Just '/'
            then do
              let userID = fromJust $ idUser . from <$> value
              -- putStrLn $ show userID
              -- putStrLn $ show userList
              let repeatN = if (filter (\x -> fst x == userID) userList) /= []
                              then (snd . head) $ filter (\x -> fst x == userID) userList
                              else (snd . head) userList
              let requestSendMessageObject = SendMessageTo    -- SendMessageTo {textTo, chat_idTo, reply_to_message_idTo}
                                              (fromJust $ textMessage <$> value)
                                              (fromJust $ idChat <$> chat <$> value)
                                              (fromJust $ message_idMessage <$> value)
              -- putStrLn $ show requestSendMessageObject
              replicateM_ repeatN ((makeRequestTelegrammSendMessage token requestSendMessageObject logLevel
                logLevelInfo message) >>= \responseSendMessage -> return ())
            else case head $ words $ fromJust $ textMessage <$> value of
              "/start"    -> do
                  let requestSendMessageObject = SendMessageTo  --SendMessageTo {textTo, chat_idTo, reply_to_message_idTo}
                                                  (fromJust $ aboutTelegramm <$> setupTelegramm)
                                                  (fromJust $ idChat <$> chat <$> value)
                                                  (fromJust $ message_idMessage <$> value)
                  responseSendMessage <- makeRequestTelegrammSendMessage token requestSendMessageObject
                                           logLevel logLevelInfo message :: IO (Maybe SendMessage)
                  server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate
              "/help"     -> do
                  let requestSendMessageObject = SendMessageTo  --SendMessageTo {textTo, chat_idTo, reply_to_message_idTo}
                                                  (fromJust $ commandTelegramm <$> setupTelegramm)
                                                  (fromJust $ idChat <$> chat <$> value)
                                                  (fromJust $ message_idMessage <$> value)
                  responseGetUpdate <- makeRequestTelegrammSendMessage token requestSendMessageObject logLevel logLevelInfo message
                  server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate
              "/settings" -> do
{-                  putStrLn ("chat_id - " ++ show (idChat (fromJust value))
                         ++ " reply_to_message_id - " ++ show (message_id (fromJust value)))-}
{-                  let requestSendMessageObject = SendMessageWithKey  --SendMessageWithKey {textWithKey chat_idWithKey reply_to_message_idWithKey reply_markup}
                                                  (fromJust $ questionTelegrammRepeat <$> setupTelegramm)
                                                  (fromJust $ idChat <$> chat <$> value)
                                                  (fromJust $ message_idMessage <$> value)
                                                  (InlineKeyboardMarkup [ [InlineKeyboardButton "1" "1"]
                                                                        , [InlineKeyboardButton "2" "2"]
                                                                        , [InlineKeyboardButton "3" "3"]
                                                                        , [InlineKeyboardButton "4" "4"]
                                                                        , [InlineKeyboardButton "5" "5"]
                                                                        ]
                                                  )-}
                  let requestSendMessageObject = SendMessageWithKey  --SendMessageWithKey {textWithKey chat_idWithKey reply_to_message_idWithKey reply_markup}
                                                  (fromJust $ questionTelegrammRepeat <$> setupTelegramm)
                                                  (fromJust $ idChat <$> chat <$> value)
                                                  (fromJust $ message_idMessage <$> value)
                                                  (ReplyKeyboardMarkup [ [KeyboardButton "The number of repetitions - 1"]
                                                                       , [KeyboardButton "The number of repetitions - 2"]
                                                                       , [KeyboardButton "The number of repetitions - 3"]
                                                                       , [KeyboardButton "The number of repetitions - 4"]
                                                                       , [KeyboardButton "The number of repetitions - 5"]
                                                                       ]
                                                  )
                  -- LC.putStrLn $ encode requestSendMessageObject
                  responseGetUpdate <- makeRequestTelegrammSendMessage token requestSendMessageObject logLevel logLevelInfo message
                  server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate
              "/quit"     -> do
                  let requestSendMessageObject = SendMessageTo  --SendMessageTo {textTo, chat_idTo, reply_to_message_idTo}
                                                  ("Senk you very much, bye...")
                                                  (fromJust $ idChat . chat <$> value)
                                                  (fromJust $ message_idMessage <$> value)
                  responseGetUpdate <- makeRequestTelegrammSendMessage token requestSendMessageObject logLevel logLevelInfo message
                  die "Senk you very much, bye..."
          -- putStrLn (show userList)
      server setupTelegramm logLevel logLevelInfo token message userList longPolling offsetGetUpdate

-- makeRequestTelegramm ::
makeRequestTelegrammSendMessage token requestSendMessageObject logLevel logLevelInfo message = do
  responseSendMessage <- makeRequest token "sendMessage" requestSendMessageObject logLevel logLevelInfo message :: IO (Maybe SendMessage)
  return (responseSendMessage)

-- makeRequestTelegramm ::
makeRequestTelegrammGetUpdates token requestSendMessageObject logLevel logLevelInfo message = do
  responseGetUpdate <- makeRequest token "getUpdates" requestSendMessageObject logLevel logLevelInfo message    :: IO (Maybe ResultRequest)
  return (responseGetUpdate)