{-# LANGUAGE OverloadedStrings #-}

module Services.Vkontakte where

import           Network.HTTP.Client
import           Network.HTTP.Client.TLS          (tlsManagerSettings)
import           Data.Aeson                       (decode, encode, ToJSON, FromJSON)
import           Network.HTTP.Types.Status        (statusCode)
import           Data.Maybe                       (fromJust)
import           System.Exit                      (die)
import           Data.Time.Clock                  (getCurrentTime, utctDayTime)
import           Control.Exception                (throwIO, try, IOException)
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
  let sessionKey = decode $ responseBody response
  return (fromJust $ sessionKey)

vkConnect :: SessionKey -> String -> [(String, FilePath)] -> String -> IO (VkConnect)
vkConnect sessionKey logLevel logLevelInfo message = do
  manager <- newManager tlsManagerSettings
  let vkConnect = (vkServer sessionKey)
        ++ "?act=a_check"
        ++ "&key=" ++ (vkKey sessionKey)
        ++ "&ts=" ++ (vkTs sessionKey)
        ++ "&wait=25"
  -- putStrLn ("vkConnect= " ++ vkConnect)
  request <- parseRequest vkConnect
  resp <- try $ httpLbs request manager :: IO (Either IOException a)
  response <- case resp of
                Left err  -> do
                               throwIO err
                Right res -> do
                               return res
  let statusCodeResponse = statusCode $ responseStatus response
  putStrLn (show $ responseBody response)
  let updateVk = decode $ responseBody response
  -- putStrLn ("ts=" ++ (vkTsNew $ fromJust updateVk) ++ ", text=" ++ (text . head . updates $ fromJust updateVk))
  return (fromJust $ updateVk)

{-vkSendMessage :: 
vkSendMessage
  rnd <- getCurrentTime >>= return . head . words . show . toRational . utctDayTime
  manager <- newManager tlsManagerSettings
  let vkConnect = "https://api.vk.com/method/messages.send"
        ++ "?random_id=" ++ rnd
        ++ "&group_id=" ++ show $ groupIdVk
        ++ "&message=" ++ 
        ++ "&access_token=" ++ tokenVk
        ++ "&v=5.131"
  -- putStrLn ("vkConnect= " ++ vkConnect)
  request <- parseRequest vkConnect
  response <- httpLbs request manager
  let statusCodeResponse = statusCode $ responseStatus response
  putStrLn (show $ responseBody response)
  let updateVk = decode $ responseBody response
-}




  --messages.getLongPollServer
  --groups.getLongPollServer
  --https://api.vk.com/method/METHOD?PARAMS&access_token=TOKEN&v=V
  --{$server}?act=a_check&key={$key}&ts={$ts}&wait=25 