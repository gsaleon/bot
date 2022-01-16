{-# LANGUAGE OverloadedStrings #-}
import Network.HTTP.Client
import Network.HTTP.Client.TLS
import Network.HTTP.Types.Status (statusCode)
import Data.Aeson (object, (.=), encode)
-- import Data.Text (Text)

main :: IO ()
main = do
  manager <- newManager tlsManagerSettings
  -- Create the request
  let requestObject = object [ "text" .= ("До рн и ваовдлаофыдвлоа рра флорвы дор " :: String)
                             , "chat_id" .= (2023781845 :: Int)
                             ]

  initialRequest <- parseRequest "https://api.telegram.org/bot2100731571:AAGIjVTEVJXymGPbU31hQGUiz11qmMB_q00/sendMessage"
  let request = initialRequest { method = "GET"
                               , requestBody = RequestBodyLBS $ encode requestObject
                               , requestHeaders =
                                 [ ("Content-Type", "application/json; charset=utf-8")
                                 ]
                                }

  response <- httpLbs request manager
  putStrLn $ "The status code was: " ++ (show $ statusCode $ responseStatus response)
  print $ responseBody response