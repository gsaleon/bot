module Services.ParseCommandLine where

import Data.List (isPrefixOf)
import Data.Char (isDigit)

str = "-r 5 --service=telegramm --loglevel=warning"
{--
parseLine :: String -> [(String,String)]
parseLine str = if help /= []
                  then help
                  else repeat
--}

main =
  print (help, repeat', service, loglevel)

help = parseLineHelp str

parseLineHelp :: String  -> [(String,String)]
parseLineHelp str = if "-h" `isPrefixOf` str || "--help" `isPrefixOf` str
                      then [("help","")] else []

repeat' = parseLineRepeat str

parseLineRepeat :: String -> [(String,String)]
parseLineRepeat str = if "-r " `isPrefixOf` str || "--repeat=" `isPrefixOf` str
                        then f str else []
  where
    f [] = []
    f (x:xs) = if (isDigit x) then [("repeat","x")] else f xs

service = parseLineService str

parseLineService :: String -> [(String,String)]
parseLineService str
  | ("-s tel" `isPrefixOf` str || "--service=telegramm" `isPrefixOf` str) = [("service","telegramm")]
  | ("-s vc" `isPrefixOf` str  || "--service=vkontakte" `isPrefixOf` str) = [("service","vkontakte")]
  | otherwise                                                             = []

loglevel = parseLineLogLevel str

parseLineLogLevel :: String -> [(String,String)]
parseLineLogLevel str
  | ("-l d" `isPrefixOf` str || "--loglevel=debug" `isPrefixOf` str)   = [("logLevel","debug")]
  | ("-l i" `isPrefixOf` str || "--loglevel=info" `isPrefixOf` str)    = [("logLevel","info")]
  | ("-l w" `isPrefixOf` str || "--loglevel=warning" `isPrefixOf` str) = [("logLevel","warning")]
  | ("-l e" `isPrefixOf` str || "--loglevel=error" `isPrefixOf` str)   = [("logLevel","error")]
  | otherwise                                                          = []
