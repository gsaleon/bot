{-# LANGUAGE OverloadedStrings #-}

module Services.Vkontakte where

import           Network.HTTP.Client
import           Network.HTTP.Client.TLS          (tlsManagerSettings)
import           Data.Aeson                       (decode, encode, ToJSON, FromJSON)
import           Network.HTTP.Types.Status        (statusCode)
import           Data.Maybe                       (fromJust)
import           System.Exit                      (die)

import           Services.LogM
import           App.Handlers.HandleLog

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
  putStrLn vkUrlImplicitFlow
  request <- parseRequest vkUrlImplicitFlow
  response <- httpLbs request manager
  let statusCodeResponse = statusCode $ responseStatus response
  putStrLn ("---------------------------------------------------")
  putStrLn (show statusCodeResponse)
  print (response)

vkMessagesGetLongPollServer :: String -> Int -> String ->
               [(String, FilePath)] -> String -> IO (String)
vkMessagesGetLongPollServer tokenVk groupIdVk logLevel logLevelInfo message = do
  manager <- newManager tlsManagerSettings
  let vkMessagesGetLongPollServer = "https://api.vk.com/method/messages.getLongPollServer"
        ++ "?need_pts=0"
        ++ "&access_token=" ++ tokenVk
        ++ "&v=5.131"
  putStrLn ("vkGroupsGetLongPollServer= " ++ vkMessagesGetLongPollServer)
  request <- parseRequest vkMessagesGetLongPollServer
  response <- httpLbs request manager
  let statusCodeResponse = statusCode $ responseStatus response
  let responseGetLongPollServer = decode $ responseBody response
  putStrLn ("---------------------------------------------------")
  putStrLn (show statusCodeResponse)
  putStrLn (show responseGetLongPollServer)
  return (fromJust responseGetLongPollServer)


  --messages.getLongPollServer
  --groups.getLongPollServer
  --https://api.vk.com/method/METHOD?PARAMS&access_token=TOKEN&v=V