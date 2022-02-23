{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Services.Vkontakte where

import           Network.HTTP.Client
import           Network.HTTP.Client.TLS          (tlsManagerSettings)
import           Data.Aeson                       (decode, encode, ToJSON, FromJSON)
import           Network.HTTP.Types.Status        (statusCode)
import           Data.Maybe                       (fromJust)
import           System.Exit                      (die)
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

vkGroupsGetLongPollServer :: String -> Int -> String ->
               [(String, FilePath)] -> String -> IO (SessionKey)
vkGroupsGetLongPollServer tokenVk groupIdVk logLevel logLevelInfo message = do
  manager <- newManager tlsManagerSettings
  let vkGroupsGetLongPollServer = "https://api.vk.com/method/groups.getLongPollServer"
        ++ "?group_id=" ++ (show groupIdVk)
        ++ "&access_token=" ++ tokenVk
        ++ "&v=5.131"
  request <- parseRequest vkGroupsGetLongPollServer
  response <- httpLbs request manager
  let statusCodeResponse = statusCode $ responseStatus response
  -- let statusCodeResponse = getResponseStatusCode response
  -- putStrLn ("statusCode vkGroupsGetLongPollServer-" ++ (show statusCodeResponse))
  let sessionKey = decode $ responseBody response
  return (fromJust $ sessionKey)

vkConnect :: Int -> SessionKey -> String -> [(String, FilePath)] -> String -> IO (VkConnect)
vkConnect longPolling sessionKey logLevel logLevelInfo message = do
  let pollingTime = responseTimeoutMicro $ (longPolling + 5) * 1000000
  -- putStrLn (show pollingTime)
  manager <- newManager tlsManagerSettings {managerResponseTimeout = pollingTime}
  let vkConnect = (vkServer sessionKey)
        ++ "?act=a_check"
        ++ "&key=" ++ (vkKey sessionKey)
        ++ "&ts=" ++ (vkTs sessionKey)
        ++ "&wait=" ++ (show longPolling)
  -- putStrLn ("vkConnect= " ++ vkConnect)
  request <- parseRequest vkConnect
  response <- retryOnTimeout $ httpLbs request manager
  let updateVk = decode $ responseBody response
  -- putStrLn (show updateVk)
  -- putStrLn ("ts=" ++ (vkTsNew $ fromJust updateVk) ++ ", text=" ++ (text . head . updates $ fromJust updateVk))
  return (fromJust $ updateVk)

-- vkSendMessage :: 
vkSendMessage messageFrom groupIdVk tokenVk messageVk logLevel logLevelInfo message = do
  rnd <- getCurrentTime >>= return . getNineSymbol . head . words . show . toRational . utctDayTime
  manager <- newManager tlsManagerSettings
  let vkSendMes = "https://api.vk.com/method/messages.send"
        ++ "?random_id=" ++ rnd
        -- ++ "&group_id=" ++ (show $ groupIdVk)
        ++ "&peer_id =" ++ (show $ messageFrom)
        ++ "&message=" ++ messageVk
        ++ "&access_token=" ++ tokenVk
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

  --messages.getLongPollServer
  --groups.getLongPollServer
  --https://api.vk.com/method/METHOD?PARAMS&access_token=TOKEN&v=V
  --{$server}?act=a_check&key={$key}&ts={$ts}&wait=25 
