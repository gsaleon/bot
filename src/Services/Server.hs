{-# LANGUAGE OverloadedStrings #-}

module Services.Server where

-- import           Data.Aeson                       (encode)
import           Data.Char                        (digitToInt)
import           System.Exit                      (die)
import           Data.Maybe                       (fromJust)
import           Control.Monad                    (replicateM_)
import           Prelude                  hiding  (id)

import           App.Types.ConfigTelegram
import           App.Handlers.HandleLog           (handleLogWarning, handleLogDebug, handleLogInfo)
import           Services.Telegram               (makeRequest, makeSendMessage)
import           Services.LogM

server :: Maybe SetupTelegram -> String -> [(String, FilePath)] ->
                          String -> String -> [(Int, Int)] -> Int -> Int -> IO ()
server setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate = do
  putStr "."
  let requestSendMessageObject = SendGetUpdate longPolling 1 offsetGetUpdate
  -- putStrLn ("offsetGetUpdate old valee" ++ show offsetGetUpdate)
  responseGetUpdate <- makeTelegramGetUpdates token requestSendMessageObject logLevel logLevelInfo message
  if (result $ responseGetUpdate) == []
    then server setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
    else do
      let value = messageUpdate . head . result $ responseGetUpdate
      let textTelegram = textMessage $ value
      let idChatTelegram = idChat . chat $ value
      let messageId = message_idMessage $ value
      let offsetGetUpdate = (update_idUpdate . head . result $ responseGetUpdate) + 1
      -- putStrLn ("offsetGetUpdate new valee" ++ show offsetGetUpdate)
      let userID = idUser . from $ value
      let stickerValue = file_id . sticker $ value
      if (textTelegram) /= ""
        then 
          if (init $ textTelegram) == "The number of repetitions - "
            then do      
              let button = digitToInt (last $ textTelegram)
              let userListNew = (userID, button) : userList :: [(Int, Int)]
              -- putStrLn ("userListNew = " ++ show userListNew)
              let requestSendMessageObject = SendMessageHideKeyboard
                                              ("HideKeyboard")
                                              (idChatTelegram)
                                              (ReplyKeyboardHide {hide_keyboard = True})
              (makeTelegramSendMessage token requestSendMessageObject logLevel logLevelInfo message) >>= \r -> return ()
              -- putStrLn ("For userId - " ++ show userID ++ ", set namber repeat - " ++ show button ++ ", userList: " ++ show userListNew)
              logDebug handleLogDebug logLevel logLevelInfo $ message ++ "hide keyboard"
              server setupTelegram logLevel logLevelInfo token message userListNew longPolling offsetGetUpdate
            else
              if (head $ textTelegram) /= '/'
                then do
                  let repeatNumber = if (filter (\x -> fst x == userID) userList) /= []
                                       then (snd . head) $ filter (\x -> fst x == userID) userList
                                       else (snd . head) userList
                  -- putStrLn ("repeatNumber = " ++ show repeatNumber)
                  let requestSendMessageObject = SendMessageTo textTelegram idChatTelegram
                  replicateM_ repeatNumber ((makeTelegramSendMessage token requestSendMessageObject logLevel
                                                logLevelInfo message) >>= \responseSendMessage -> return ())
                  server setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
                else case head $ words $ textTelegram of
                  "/start"    -> do
                      let requestSendMessageObject = SendMessageTo
                                                      (fromJust $ aboutTelegram <$> setupTelegram)
                                                      (idChatTelegram)
                      (makeTelegramSendMessage token requestSendMessageObject logLevel logLevelInfo message) >>= \r -> return ()
                      logDebug handleLogDebug logLevel logLevelInfo $ message ++ "command /start"
                      server setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
                  "/help"     -> do
                      let requestSendMessageObject = SendMessageTo
                                                      (fromJust $ commandTelegram <$> setupTelegram)
                                                      (idChatTelegram)
                      (makeTelegramSendMessage token requestSendMessageObject logLevel logLevelInfo message) >>= \r -> return ()
                      logDebug handleLogDebug logLevel logLevelInfo $ message ++ "command /help"
                      server setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
                  "/settings" -> do
                      let requestSendMessageObject = SendMessageWithKey
                                                      (fromJust $ questionTelegramRepeat <$> setupTelegram)
                                                      (idChatTelegram)
                                                      (ReplyKeyboardMarkup [ [KeyboardButton "The number of repetitions - 1"]
                                                                           , [KeyboardButton "The number of repetitions - 2"]
                                                                           , [KeyboardButton "The number of repetitions - 3"]
                                                                           , [KeyboardButton "The number of repetitions - 4"]
                                                                           , [KeyboardButton "The number of repetitions - 5"]
                                                                           ]
                                                      )
                      (makeTelegramSendMessage token requestSendMessageObject logLevel logLevelInfo message) >>= \r -> return ()
                      logInfo handleLogInfo logLevel logLevelInfo $ message ++ "command /settings"
                      logDebug handleLogDebug logLevel logLevelInfo $ message ++ "command /settings"
                      server setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
                  "/quit" -> do
                      let requestSendMessageObject = SendMessageTo "Senk you very much, bye..." idChatTelegram
                      (makeTelegramSendMessage token requestSendMessageObject logLevel logLevelInfo message) >>= \r -> return ()
                      logInfo handleLogInfo logLevel logLevelInfo $ message ++ "command /quit"
                      logDebug handleLogDebug logLevel logLevelInfo $ message ++ "command /quit"
                      die "Senk you very much, bye..."
                  _ -> do
                      let requestSendMessageObject = SendMessageTo "Unknow command, please insert value without '/'" idChatTelegram
                      (makeTelegramSendMessage token requestSendMessageObject logLevel logLevelInfo message) >>= \r -> return ()
                      logWarning handleLogWarning logLevel logLevelInfo $ message ++ "Unknow command (include first '/')"
                      server setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
        else
          if (stickerValue) /= []
            then do
              let repeatNumber = if (filter (\x -> fst x == userID) userList) /= []
                                    then (snd . head) $ filter (\x -> fst x == userID) userList
                                    else (snd . head) userList
              let requestSendMessageObject = SendStickerTo idChatTelegram stickerValue
              replicateM_ repeatNumber ((makeTelegramSendSticker token requestSendMessageObject logLevel
                                        logLevelInfo message) >>= \responseSendMessage -> return ())
              server setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
            else do
              logDebug handleLogDebug logLevel logLevelInfo
                $ message ++ "Unknow value parametr: not text, not sticker"
              logWarning handleLogWarning logLevel logLevelInfo
                $ message ++ "Unknow value parametr: not text, not sticker"
              putStrLn "Unknow value parametr: not text, not sticker"
              server setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate

-- makeRequestTelegram ::
makeTelegramSendMessage token requestSendMessageObject logLevel logLevelInfo message = do
  responseSendMessage <- makeSendMessage token "sendMessage" requestSendMessageObject logLevel logLevelInfo message :: IO SendMessage
  return (responseSendMessage)

-- makeRequestTelegram ::
makeTelegramGetUpdates token requestSendMessageObject logLevel logLevelInfo message = do
  responseGetUpdate <- makeRequest token "getUpdates" requestSendMessageObject logLevel logLevelInfo message    :: IO ResultRequest
  return (responseGetUpdate)

-- makeRequestTelegram ::
makeTelegramSendSticker token requestSendMessageObject logLevel logLevelInfo message = do
  responseSendMessage <- makeSendMessage token "sendSticker" requestSendMessageObject logLevel logLevelInfo message :: IO SendMessage
  return (responseSendMessage)