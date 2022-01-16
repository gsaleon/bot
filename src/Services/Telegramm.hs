{-# LANGUAGE OverloadedStrings #-}

module Services.Telegramm where

import           Network.HTTP.Client
import           Network.HTTP.Client.TLS
import           Data.Aeson                       (decode, encode)
import           Network.HTTP.Types.Status        (statusCode)

import           Services.LogM
import           App.Handlers.HandleLog

-- makeRequest :: String -> String -> Object -> String -> [String, FilePath] -> String -> ...]
makeRequest token url object logLevel logLevelInfo message = do
  manager <- newManager tlsManagerSettings
  let requestObject = object
  let requestUrl = "https://api.telegram.org/" ++ "bot" ++ token ++ "/" ++ url
  request' <- parseRequest requestUrl
  let request = request'
              { method = "GET"
              , requestBody = RequestBodyLBS $ encode requestObject
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
      logDebug handleLogDebug  logLevel logLevelInfo
        $ message ++ "The status code " ++ url ++ " was: " ++ show statusCodeResponse
    else do
      logError handleLogError logLevel logLevelInfo
        $ message ++ "The status code " ++ url ++ " was: " ++ show statusCodeResponse ++ " error response"
      logDebug handleLogDebug  logLevel logLevelInfo
        $ message ++ "The status code " ++ url ++ " was: " ++ show statusCodeResponse ++ " error response"
  let responseGet = decode $ responseBody response
  case responseGet of
    Nothing          -> logError handleLogError logLevel logLevelInfo
                          $ message ++ "Error decode body response Get " ++ url
    Just responseGet -> logInfo handleLogInfo logLevel logLevelInfo
                          $ message ++ "Ok decode body response Get " ++ url
  return responseGet