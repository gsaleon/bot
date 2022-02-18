{-# LANGUAGE OverloadedStrings #-}

module Services.Vkontakte where

import           Network.HTTP.Client
import           Network.HTTP.Client.TLS          (tlsManagerSettings)
import           Data.Aeson                       (decode, encode, ToJSON, FromJSON)
import           Network.HTTP.Types.Status        (statusCode)
import           Data.Maybe                       (fromJust)
import           System.Exit                      (die)
-- import qualified Data.ByteString.Lazy.Char8    as BLC

import           Services.LogM
import           App.Handlers.HandleLog
import           App.Types.ConfigVkontakte

vkAuhorize :: Int -> Int -> String ->
               [(String, FilePath)] -> String -> IO ()
vkAuhorize clientIdVk groupIdVk logLevel logLevelInfo message = do
  manager <- newManager tlsManagerSettings
  let vkUrlImplicitFlow = "https://oauth.vk.com/authorize?client_id="
        ++ (show clientIdVk)
        ++ "&group_ids=" ++ (show groupIdVk)
        ++ "&display=page"
        ++ "&redirect_uri=https://oauth.vk.com/blank.htmlk"
        ++ "&scope=messages"
        ++ "&response_type=code"
        ++ "&v=5.131"
        ++ "&state=123456"
  Prelude.putStrLn vkUrlImplicitFlow
  request <- parseRequest vkUrlImplicitFlow
  response <- httpLbs request manager
  let statusCodeResponse = statusCode $ responseStatus response
  Prelude.putStrLn ("---------------------------------------------------")
  Prelude.putStrLn (show statusCodeResponse)
  print (response)

vkGroupsGetLongPollServer :: String -> Int -> String ->
               [(String, FilePath)] -> String -> IO (SessionKey)
vkGroupsGetLongPollServer tokenVk groupIdVk logLevel logLevelInfo message = do
  manager <- newManager tlsManagerSettings
  let vkGroupsGetLongPollServer = "https://api.vk.com/method/groups.getLongPollServer"
        ++ "?group_id=" ++ (show groupIdVk)
        ++ "&access_token=" ++ tokenVk
        ++ "&v=5.131"
  putStrLn ("vkGroupsGetLongPollServer= " ++ vkGroupsGetLongPollServer)
  request <- parseRequest vkGroupsGetLongPollServer
  response <- httpLbs request manager
  let statusCodeResponse = statusCode $ responseStatus response
  let sessionKey = decode $ responseBody response
  putStrLn (show sessionKey)
  --let responseGetLongPollServer = BLU.pack answer
  putStrLn ("---------------------------------------------------")
  -- putStrLn (show statusCodeResponse)
  --Prelude.putStrLn (show responseGetLongPollServer)
  return (fromJust $ sessionKey)

vkConnect :: SessionKey -> String -> [(String, FilePath)] -> String -> IO (VkConnect)
vkConnect sessionKey logLevel logLevelInfo message = do
  manager <- newManager tlsManagerSettings
  let vkConnect = (vkServer sessionKey)
        ++ "?act=a_check"
        ++ "&key=" ++ (vkKey sessionKey)
        ++ "&ts=" ++ (vkTs sessionKey)
        ++ "&wait=25"
  putStrLn ("vkConnect= " ++ vkConnect)
  request <- parseRequest vkConnect
  response <- httpLbs request manager
  let statusCodeResponse = statusCode $ responseStatus response
  putStrLn (show $ responseBody response)
  let vkConnect = decode $ responseBody response
  putStrLn (show vkConnect)
  return (fromJust $ vkConnect)

  --messages.getLongPollServer
  --groups.getLongPollServer
  --https://api.vk.com/method/METHOD?PARAMS&access_token=TOKEN&v=V
  --{$server}?act=a_check&key={$key}&ts={$ts}&wait=25 