module App.Handlers.HandleTelegramm where

import           Network.HTTP.Client              (httpLbs)

import           App.Types.ConfigTelegram
{-
handleTelegram :: HandleTelegram
handleTelegram =  HandleTelegram { requestTelegram =
    \request manager -> httpLbs request manager
                                 }-}


{-
responseGetUpdate <- Cli.httpLbs requestGetUpdate manager

:t Cli.httpLbs 
Cli.httpLbs
  :: Request
     -> Manager
     -> IO (Response Data.ByteString.Lazy.Internal.ByteString)

-}
