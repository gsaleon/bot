{-# LANGUAGE OverloadedStrings #-}

module Services.Server where

-- import           Data.Aeson                       (encode)
import           Data.Char                        (digitToInt, isDigit)
import           System.Exit                      (die)
import           Data.Maybe                       (fromJust)
import           Control.Monad                    (replicateM_)
import           Prelude                  hiding  (id)
import           Control.Concurrent
import qualified Data.Text.Lazy.IO           as T
import           Data.Text.Encoding               (decodeUtf8)
import           Data.Text                        (Text, unpack, drop, pack)
import           Data.ByteString.Lazy             (toStrict)
import           Data.Aeson                       (encode)
import qualified Network.URI.Encode        as NUE (encode, decode)

import           App.Types.ConfigTelegram
import           App.Types.ConfigVkontakte
import           App.Handlers.HandleLog           (handleLogWarning, handleLogDebug, handleLogInfo)
import           Services.Telegram                (makeRequest, makeSendMessage)
import           Services.LogM
import           Services.Vkontakte               (vkGroupsGetLongPollServer, vkGetUpdate, vkSendMessage
                                                  , vkSendMessageWithKeyboard)

serverTelegram :: Maybe SetupTelegram -> String -> [(String, FilePath)] ->
                          String -> String -> [(Int, Int)] -> Int -> Int -> IO ()
serverTelegram setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate = do
  let requestSendMessageObject = SendGetUpdate longPolling 1 offsetGetUpdate
  -- putStrLn ("offsetGetUpdate old valee" ++ show offsetGetUpdate)
  responseGetUpdate <- makeTelegramGetUpdates token requestSendMessageObject logLevel logLevelInfo message
  if (result $ responseGetUpdate) == []
    then do
      threadDelay 100000
      serverTelegram setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
    else do
      let value = messageUpdate . head . result $ responseGetUpdate
      let textTelegram = textMessage $ value
      let idChatTelegram = idChat . chat $ value
      -- let messageId = message_idMessage $ value
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
              serverTelegram setupTelegram logLevel logLevelInfo token message userListNew longPolling offsetGetUpdate
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
                  serverTelegram setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
                else case head $ words $ textTelegram of
                  "/start"    -> do
                      let requestSendMessageObject = SendMessageTo
                                                      (fromJust $ aboutTelegram <$> setupTelegram)
                                                      (idChatTelegram)
                      (makeTelegramSendMessage token requestSendMessageObject logLevel logLevelInfo message) >>= \r -> return ()
                      logDebug handleLogDebug logLevel logLevelInfo $ message ++ "command /start"
                      serverTelegram setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
                  "/help"     -> do
                      let requestSendMessageObject = SendMessageTo
                                                      (fromJust $ commandTelegram <$> setupTelegram)
                                                      (idChatTelegram)
                      (makeTelegramSendMessage token requestSendMessageObject logLevel logLevelInfo message) >>= \r -> return ()
                      logDebug handleLogDebug logLevel logLevelInfo $ message ++ "command /help"
                      serverTelegram setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
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
                      serverTelegram setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
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
                      serverTelegram setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
        else
          if (stickerValue) /= []
            then do
              let repeatNumber = if (filter (\x -> fst x == userID) userList) /= []
                                    then (snd . head) $ filter (\x -> fst x == userID) userList
                                    else (snd . head) userList
              let requestSendMessageObject = SendStickerTo idChatTelegram stickerValue
              replicateM_ repeatNumber ((makeTelegramSendSticker token requestSendMessageObject logLevel
                                        logLevelInfo message) >>= \responseSendMessage -> return ())
              serverTelegram setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
            else do
              logDebug handleLogDebug logLevel logLevelInfo
                $ message ++ "Unknow value parametr: not text, not sticker"
              logWarning handleLogWarning logLevel logLevelInfo
                $ message ++ "Unknow value parametr: not text, not sticker"
              putStrLn "Unknow value parametr: not text, not sticker"
              serverTelegram setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate

serverVkontakte :: Maybe SetupVkontakte -> String -> [(String, FilePath)] -> String -> [(Int, Int)] -> Int -> SessionKey -> IO ()
serverVkontakte setupVkontakte logLevel logLevelInfo message userList longPolling sessionKey = do
  let tokenVk = tokenVkontakte $ fromJust setupVkontakte
  let groupIdVk = group_id $ fromJust setupVkontakte
  updateVk <- vkGetUpdate longPolling sessionKey logLevel logLevelInfo message
  let sessionKeyNewValue = vkTsNew $ updateVk
  let updateVkValue    = updates $ updateVk
  -- putStrLn ("sessionKeyNew- " ++ sessionKeyNewValue)
  -- putStrLn ("updateVkValue- " ++ show updateVkValue)
  -- vkAllowMessFromGroup <- vkAllowMessagesFromGroup groupIdVk tokenVk logLevel logLevelInfo message
  if updateVkValue /= []
    then do
      let from_Id = fromId . head $ updateVkValue
      let id_Mess = idMess . head $ updateVkValue
      let typeMessVk = typeMessage . head $ updateVkValue
      let peer_Id = peerId . head $ updateVkValue
      let messageVk = textMessVk . head $ updateVkValue
      let sessionKeyNew = sessionKey {vkTs = sessionKeyNewValue}
      let repeatNumber = if (filter (\x -> fst x == from_Id) userList) /= []
                            then (snd . head) $ filter (\x -> fst x == from_Id) userList
                            else (snd . head) userList
      -- putStrLn ("from_Id- " ++ show from_Id ++ ", peer_Id- " ++ show peer_Id ++ ", id_Mess- " ++ show id_Mess ++"\n" ++
      --           "messageVk- " ++ messageVk ++ ", typeMessVk- " ++ typeMessVk)
      -- if and [from_Id > 0, or [typeMessVk == "message_new", typeMessVk == "message_reply"]]
      if and [(isDigit . head $ messageVk), ((digitToInt . head $ messageVk) >= 1), ((digitToInt . head $ messageVk) <= 5)]
        then do
          let userListNew = (from_Id, digitToInt . head $ messageVk) : userList :: [(Int, Int)]
          threadDelay 100000
          serverVkontakte setupVkontakte logLevel logLevelInfo message userListNew longPolling sessionKeyNew
        else case messageVk of
          "/About" -> do
            makeVkSendMessageWithKeyboard peer_Id keyboardHelp tokenVk "/About-dfsdf" logLevel logLevelInfo message
            serverVkontakte setupVkontakte logLevel logLevelInfo message userList longPolling sessionKeyNew
          "/Help"  -> do
            makeVkSendMessageWithKeyboard peer_Id keyboardHelp tokenVk "/Help-sdsdf" logLevel logLevelInfo message
            serverVkontakte setupVkontakte logLevel logLevelInfo message userList longPolling sessionKeyNew
          "/Setting" -> do
            makeVkSendMessageWithKeyboard peer_Id keyboardNumber tokenVk "Enter number repeat- " logLevel logLevelInfo message
            serverVkontakte setupVkontakte logLevel logLevelInfo message userList longPolling sessionKeyNew
          "/Quit" -> do
            makeVkSendMessage from_Id id_Mess tokenVk "/Bye..." logLevel logLevelInfo message
            die "Senk you very much, bye..."
          _ -> do
            replicateM_ (repeatNumber - 1) ((makeVkSendMessage from_Id id_Mess tokenVk messageVk logLevel
                                               logLevelInfo message) >>= \r -> return ())
            makeVkSendMessageWithKeyboard peer_Id keyboardHelp tokenVk messageVk logLevel logLevelInfo message
            threadDelay 100000
            serverVkontakte setupVkontakte logLevel logLevelInfo message userList longPolling sessionKeyNew
    else do
      threadDelay 100000
      serverVkontakte setupVkontakte logLevel logLevelInfo message userList longPolling sessionKey

  -- serverVkontakte setupVkontakte logLevel logLevelInfo message userList longPolling sessionKey


--additional functions
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

-- makeVkSendMessage
makeVkSendMessage peerIdMessage id_Mess tokenVk messageVk logLevel logLevelInfo message = do
  responseSendMessage <- vkSendMessage peerIdMessage id_Mess tokenVk messageVk logLevel logLevelInfo message :: IO ResponseVkSendMessage
  return (responseSendMessage)

makeVkSendMessageWithKeyboard peerIdMessage keyboardHelp tokenVk messageVk logLevel logLevelInfo message = do
  responseSendMessage <- vkSendMessageWithKeyboard peerIdMessage keyboardHelp tokenVk messageVk logLevel logLevelInfo message :: IO ResponseVkSendMessage
  return (responseSendMessage)

keyboardHelp :: String
keyboardHelp = NUE.encode . unpack . decodeUtf8 . toStrict $ encode KeyboardVkSetting {
    one_time = True,
    inline = False,
    buttons = [[
        ButtonArray {color = "negative",  action = ButtonValue {label = "/About",   payload = PayloadValue "", _type = "text"}},
        ButtonArray {color = "positive",  action = ButtonValue {label = "/Help",    payload = PayloadValue "", _type = "text"}},
        ButtonArray {color = "primary",   action = ButtonValue {label = "/Setting", payload = PayloadValue "", _type = "text"}},
        ButtonArray {color = "secondary", action = ButtonValue {label = "/Quit",    payload = PayloadValue "", _type = "text"}}
              ]]                                                                      }

keyboardNumber :: String
keyboardNumber = NUE.encode . unpack . decodeUtf8 . toStrict $ encode KeyboardVkSetting {
    one_time = False,
    inline = True,
    buttons = [[
        ButtonArray {color = "negative",  action = ButtonValue {label = "1", payload = PayloadValue "", _type = "text"}},
        ButtonArray {color = "positive",  action = ButtonValue {label = "2", payload = PayloadValue "", _type = "text"}},
        ButtonArray {color = "primary",   action = ButtonValue {label = "3", payload = PayloadValue "", _type = "text"}},
        ButtonArray {color = "secondary", action = ButtonValue {label = "4", payload = PayloadValue "", _type = "text"}},
        ButtonArray {color = "negative",  action = ButtonValue {label = "5", payload = PayloadValue "", _type = "text"}}
              ]]                                                                        }

-- getValue :: VkMessage -> p1 -> p2 -> a
-- getValue mess f1 f2 = case mess of
--   VkMessageReplay f1 g1 h1 -> f1 $ mess
--   VkMessageNew    f2 g2 h2 -> f2 $ mess 