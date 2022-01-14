
{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.ByteString as B
import           Control.Monad (mzero)
import           Control.Applicative ((<$>), (<*>))
import           Data.Aeson
{-
data Host = Host { ip   :: String
                 , port :: Int
                 }

instance FromJSON Host where
    parseJSON (Object host) = Host <$> host .: "ip"
                                   <*> host .: "port"
    parseJSON _             = mzero

data Hosts = Hosts { ok :: Bool, hosts :: [Host]}
                    

instance FromJSON Hosts where
    parseJSON (Object hosts) = do
        ok      <- hosts .: "ok"
        anArray <- hosts .: "hosts"
        return $ Hosts ok anArray

printPretty :: Host -> String
printPretty (Host ip port) = ip ++ ":" ++ show port

main :: IO ()
main = do
    rawJSON <- B.readFile "our.json"
    let result = decodeStrict rawJSON
    putStrLn $ case result of
        Nothing    -> "Invalid JSON!"
        Just (Hosts ok hosts) -> show $ printPretty <$> hosts-}
main :: IO ()
main = do
    let str = "{\"total\":1,\"movies\":[ {\"id\":\"771315522\",\"title\":\"Harry Potter and the Philosophers Stone (Wizard's Collection)\",\"posters\":{\"thumbnail\":\"http://content7.flixster.com/movie/11/16/66/11166609_mob.jpg\",\"profile\":\"http://content7.flixster.com/movie/11/16/66/11166609_pro.jpg\",\"detailed\":\"http://content7.flixster.com/movie/11/16/66/11166609_det.jpg\",\"original\":\"http://content7.flixster.com/movie/11/16/66/11166609_ori.jpg\"}}]}"
    print $ movieList <$> decode str 

newtype MovieList = MovieList {movieList :: [Movie]} deriving Show

instance FromJSON MovieList where
    parseJSON (Object o) = MovieList <$> o .: "movies"
    parseJSON _ = mzero

data Movie = Movie {id :: String, title :: String}  deriving Show

instance FromJSON Movie where
    parseJSON (Object o) = Movie <$> o .: "id" <*> o .: "title"
    parseJSON _ = mzero