module Services.ParseCommandLine where

import Data.Char (isDigit)

main = do
  str <- getLine
  putStrLn ("str - " ++ show str)
  putStrLn (show $ parseLine' str arg)
  putStrLn (show $ parseLine str arg)

arg :: [(String,String)]
arg = [("-h","--help")
      ,("-s tel","--service=telegramm")
      ,("-s vc","--service=vkontakte")
      ,("-l d","--loglevel=debug")
      ,("-l i","--loglevel=info")
      ,("-l w","--loglevel=warning")
      ,("-l e","--loglevel=error")
      ,("-r ","--repeat=")      
      ]

parseLine :: String -> [(String,String)]-> [String]
parseLine str arg = let parse = map snd $ parseLine' str arg in
  if (null parse) && (not $ null str)
    then ["errorParsing"]
    else if head parse == "help"
           then ["help"]
           else if (null $ findNumber str) && (findStr (concat parse) "repeat=")
                  then ["errorParsing"]
                  else if (length parse == 1)
                         then [head parse ++ findNumber str]
                         else init parse ++ [last parse ++ findNumber str]

parseLine' :: String -> [(String,String)] -> [(Bool,String)]
parseLine' str arg =
  filter (\x -> fst x) $
    map (\x -> ((findStr str (fst x))
             || (findStr str (snd x)),(tail . tail $ snd x))) arg

findStr :: String -> String -> Bool
findStr [] _ = False
findStr s@(x:xs) pat
  | pat == (take (length pat) s) = True
  | otherwise                    = findStr xs pat

findNumber :: String -> String
findNumber [] = []
findNumber (x:xs) = if (isDigit x) then [x] else findNumber xs

