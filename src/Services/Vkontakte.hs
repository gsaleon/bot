{-# LANGUAGE OverloadedStrings #-}

module Services.Vkontakte where

import           Network.HTTP.Client
import           Network.HTTP.Client.TLS
import           Data.Aeson                       (decode, encode, ToJSON, FromJSON)
import           Network.HTTP.Types.Status        (statusCode)
import           Data.Maybe                       (fromJust)
import           System.Exit                      (die)

import           Services.LogM
import           App.Handlers.HandleLog

makeRequestVk :: (ToJSON a1, FromJSON a2) => String -> String -> a1 -> String ->
               [(String, FilePath)] -> String -> IO a2
makeRequestVk tokenVk url object logLevel logLevelInfo message = do
  manager <- newManager tlsManagerSettings
  let requestUrl = "https://api.telegram.org/" ++ "bot" ++ tokenVk ++ "/" ++ url
  request' <- parseRequest requestUrl
  let request = request'
              { method = "GET"
              , requestBody = RequestBodyLBS $ encode object
              , requestHeaders = [ ("Content-Type", "application/json; charset=utf-8")]
               }
  logInfo handleLogInfo logLevel logLevelInfo $ message ++ "Send GET request " ++ url
  logDebug handleLogDebug  logLevel logLevelInfo $ message ++ "Send GET request " ++ url
  response <- httpLbs request manager
  let statusCodeResponse = statusCode $ responseStatus response
  if statusCodeResponse == 200
    then do
{-      logInfo handleLogInfo logLevel logLevelInfo
        $ message ++ "The status code " ++ url ++ " was: " ++ show statusCodeResponse-}
      logDebug handleLogDebug logLevel logLevelInfo
        $ message ++ "The status code " ++ url ++ " was: " ++ show statusCodeResponse
    else do
      logError handleLogError logLevel logLevelInfo
        $ message ++ "The status code " ++ url ++ " was: " ++ show statusCodeResponse ++ " error response"
      logDebug handleLogDebug logLevel logLevelInfo
        $ message ++ "The status code " ++ url ++ " was: " ++ show statusCodeResponse ++ " error response"
  let responseGet = decode $ responseBody response
  case responseGet of
    Nothing          -> do
                          logError handleLogError logLevel logLevelInfo
                            $ message ++ "Error decode body response Get " ++ url
                          die "Value responseGet Telegram is Nothing - abort programm"
    Just responseGet -> do
                          logInfo handleLogInfo logLevel logLevelInfo
                            $ message ++ "Ok decode response Get " ++ url
  return (fromJust responseGet)

makeSendMessageVk :: (ToJSON a1, FromJSON a2) => String -> String -> a1 -> String ->
               [(String, FilePath)] -> String -> IO a2
makeSendMessageVk tokenVk url object logLevel logLevelInfo message = do
  manager <- newManager tlsManagerSettings
  let requestUrl = "https://api.telegram.org/" ++ "bot" ++ tokenVk ++ "/" ++ url
  request' <- parseRequest requestUrl
  let request = request'
              { method = "GET"
              , requestBody = RequestBodyLBS $ encode object
              , requestHeaders = [ ("Content-Type", "application/json; charset=utf-8")]
               }
  logInfo handleLogInfo logLevel logLevelInfo $ message ++ "Send GET request " ++ url
  logDebug handleLogDebug  logLevel logLevelInfo $ message ++ "Send GET request " ++ url
  response <- httpLbs request manager
  let statusCodeResponse = statusCode $ responseStatus response
  if statusCodeResponse == 200
    then do
      logInfo handleLogInfo logLevel logLevelInfo
        $ message ++ "The status code " ++ url ++ " was: " ++ show statusCodeResponse
      logDebug handleLogDebug logLevel logLevelInfo
        $ message ++ "The status code " ++ url ++ " was: " ++ show statusCodeResponse
    else do
      logError handleLogError logLevel logLevelInfo
        $ message ++ "The status code " ++ url ++ " was: " ++ show statusCodeResponse ++ " error response"
      logDebug handleLogDebug logLevel logLevelInfo
        $ message ++ "The status code " ++ url ++ " was: " ++ show statusCodeResponse ++ " error response"
  let responseGet = decode $ responseBody response
  case responseGet of
    Nothing          -> do
                          logError handleLogError logLevel logLevelInfo
                            $ message ++ "Error decode send message " ++ url
                          logDebug handleLogDebug logLevel logLevelInfo
                            $ message ++ "Error decode send message " ++ url
    Just responseGet -> do
                          logInfo handleLogInfo logLevel logLevelInfo
                            $ message ++ "Ok send message " ++ url
  return (fromJust responseGet)