{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Services.Vkontakte where

import           Network.HTTP.Client
import           Network.HTTP.Client.TLS          (tlsManagerSettings)
import           Data.Aeson                       (decode, encode, ToJSON, FromJSON)
import           Data.List                        (intercalate)
import           Network.HTTP.Types.Status        (statusCode)
import           Data.Maybe                       (fromJust)
import           System.Exit                      (die, ExitCode(..))
import           Data.Time.Clock                  (getCurrentTime, utctDayTime)
import           Data.Either                      (fromRight, isRight)
import           Control.Monad                    (when)
import           Control.Exception                (try, catch)
import           Control.Concurrent               (threadDelay)
-- import           System.Timeout                   (timeout)

-- import qualified Data.ByteString.Lazy.Char8    as BLC

import           Services.LogM
import           App.Handlers.HandleLog
import           App.Types.ConfigVkontakte

{--- vkImplicitFlow ::
vkImplicitFlow clientIdVk groupIdVk logLevel logLevelInfo message = do
  manager <- newManager tlsManagerSettings
  rnd <- rndNumber
  let vkImplicitFlowURL = "https://oauth.vk.com/authorize"
        ++ "?client_id" ++ (show clientIdVk)
        ++ "&redirect_uri=https://oauth.vk.com/blank.html"
        ++ "&group_ids=" ++ (show groupIdVk)
        ++ "&display=page"
        ++ "&scope=messages"
        ++ "response_type=token"
        ++ "&v=5.131"
        ++ "state=" ++ rnd
  putStrLn ("vkImplicitFlowURL- " ++ vkImplicitFlowURL)
  -- openBrowserOn vkImplicitFlowURL
  -- request <- parseRequest vkImplicitFlow
  -- response <- httpLbs request manager
  -- putStrLn (show response)
  -- -- let statusCodeResponse = statusCode $ responseStatus response
  -- -- let sessionKey = decode $ responseBody response :: Maybe SessionKey
  -- -- putStrLn ("VkSessionKey-" ++ (show sessionKey))
  return ()

-}

vkGroupsGetLongPollServer :: String -> Int -> String ->
               [(String, FilePath)] -> String -> IO (SessionKey)
vkGroupsGetLongPollServer tokenVk groupIdVk logLevel logLevelInfo message = do
  manager <- newManager tlsManagerSettings
{-  let vkGroupsGetLongPollServer = "https://api.vk.com/method/messages.getLongPollServer"
        ++ "?need_pts=0"
        ++ "&group_id=" ++ (show groupIdVk)
        ++ "&lp_version=3"
        ++ "&access_token=" ++ tokenVk
        ++ "&v=5.131"-}
  -- putStrLn vkGroupsGetLongPollServer
  let vkGroupsGetLongPollServer = "https://api.vk.com/method/groups.getLongPollServer"
        ++ "?group_id=" ++ (show groupIdVk)
        ++ "&access_token=" ++ tokenVk
        ++ "&v=5.131"
  -- putStrLn (vkGroupsGetLongPollServer)
  request <- parseRequest vkGroupsGetLongPollServer
  response <- httpLbs request manager
  -- putStrLn (show . responseBody $ response)
  let statusCodeResponse = statusCode $ responseStatus response
  let sessionKey = decode $ responseBody response :: Maybe SessionKey
  -- putStrLn ("VkSessionKey-" ++ (show sessionKey))
  return (fromJust $ sessionKey)

-- vkGetUpdate :: Int -> SessionKey -> String -> [(String, FilePath)] -> String -> IO ([Maybe [VkArray Int]], String)
vkGetUpdate longPolling sessionKey logLevel logLevelInfo message = do
  let pollingTime = responseTimeoutMicro $ (longPolling + 5) * 1000000
  -- putStrLn (show pollingTime)
  manager <- newManager tlsManagerSettings {managerResponseTimeout = pollingTime}
  let vkGetUpdate = (vkServer sessionKey)
        ++ "?act=a_check"
        ++ "&key=" ++ (vkKey sessionKey)
        ++ "&ts=" ++ (vkTs sessionKey)
        ++ "&wait=" ++ (show longPolling)
  -- putStrLn ("vkGetUpdate= " ++ vkGetUpdate)
  request <- parseRequest vkGetUpdate
  response <- retryOnTimeout $ httpLbs request manager
  putStrLn (show . responseBody $ response)
  let updateVk = decode $ responseBody response :: Maybe VkGetUpdate
  -- putStrLn (show $ updateVk)
  return (fromJust updateVk)

-- vkSendMessage :: 
vkAllowMessagesFromGroup groupIdVk tokenVk logLevel logLevelInfo message = do
  rnd <- rndNumber
  manager <- newManager tlsManagerSettings
  let messagesAllowMessagesFromGroup = "https://api.vk.com/method/messages.allowMessagesFromGroup"
        ++ "?group_id" ++ (show groupIdVk)
        ++ "&key=" ++ rnd
        ++ "&access_token=" ++ tokenVk
        ++ "&v=5.131"
  request <- parseRequest messagesAllowMessagesFromGroup
  response <- httpLbs request manager
  putStrLn (show $ responseBody response)
  let vkAllowMessagesFromGroup = decode $ responseBody response :: Maybe Int
  putStrLn ("vkAllowMessagesFromGroup-" ++ (show $ vkAllowMessagesFromGroup))
  return (fromJust $ vkAllowMessagesFromGroup)

-- vkSendMessage :: 
vkSendMessage peerIdMessage groupIdVk tokenVk messageVk logLevel logLevelInfo message = do
  rnd <- rndNumber
  manager <- newManager tlsManagerSettings
  let vkSendMes = "https://api.vk.com/method/messages.send"
        ++ "?access_token=" ++ tokenVk
        ++ "&random_id=" ++ rnd
        ++ "&peer_id=" ++ (show $ peerIdMessage)
        ++ "&message=" ++ messageVk
        ++ "&v=5.131"
  putStrLn ("vkSendMes= " ++ vkSendMes)
  request <- parseRequest vkSendMes
  response <- httpLbs request manager
  let statusCodeResponse = statusCode $ responseStatus response
  putStrLn (show $ responseBody response)
  let vkSendMes = decode $ responseBody response
  putStrLn ("vkSendMes-" ++ (show $ vkSendMes))
  return (fromJust $ vkSendMes)



--additional functions
retryOnTimeout :: IO a -> IO a
retryOnTimeout action = catch action $ \(_ :: HttpException) -> do
    putStrLn "Timed out. Trying again."
    threadDelay 1000000
    retryOnTimeout action

getNineSymbol :: String -> String
getNineSymbol lst = let numberSymbol = length lst in
  if numberSymbol > 9
    then drop (numberSymbol - 9) lst
    else lst

rndNumber :: IO String
rndNumber = do
  rnd <- getCurrentTime >>= return . getNineSymbol . head . words . show . toRational . utctDayTime
  return (rnd)


  --messages.getLongPollServer
  --groups.getLongPollServer
  --https://api.vk.com/method/METHOD?PARAMS&access_token=TOKEN&v=V
  --{$server}?act=a_check&key={$key}&ts={$ts}&wait=25 
