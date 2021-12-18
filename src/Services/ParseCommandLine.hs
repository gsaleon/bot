module Services.ParseCommandLine (parseLine) where


parseLine :: [String] -> [String]
parseLine str = if null str
                  then ["notInput"]
                  else let pars = parseLine' str in
                    if elem "help" pars
                      then ["help"]
                      else if elem "parsingError" pars
                             then ["parsingError"]
                             else pars

parseLine' :: [String] -> [String]
parseLine' str = map (\x -> f x) str
  where
    f x = let cas = if (filter (== '=') x) == ['=']
                      then if length x > 7 then x!!2 else x!!1
                      else if length x > 2 then x!!2 else x!!1
            in case cas of
              'h' -> "help"
              't' -> "telegramm"
              'v' -> "vkontakte"
              'd' -> "debug"
              'w' -> "warning"
              'e' -> "error"
              'r' -> if take 3 x == "-r="
                       then "repeat=" ++ drop 3 x
                       else if take 9 x == "--repeat="
                              then "repeat=" ++ drop 9 x
                              else "parsingError"
              'p' -> if take 3 x == "-p="
                       then "polling=" ++ drop 3 x
                       else if take 10 x == "--polling="
                              then "polling=" ++ drop 10 x
                              else "parsingError"
              _   -> cas : " parsingError!!! " ++ x

{--
parseLine :: [String] -> [String]
parseLine str = parseLine' (unwords str) arg

parseLine' :: String -> [(String,String)]-> [String]
parseLine' str arg = let parse = map snd $ parseLine'' str arg in
  if (null parse) && (not $ null str)
    then ["errorParsing"]
    else if head parse == "help"
           then ["help"]
           else parse
  where

    parseLine'' :: String -> [(String,String)] -> [(Bool,String)]
    parseLine'' str arg =
      filter (\x -> fst x) $
        map (\x -> ((findStr str (fst x))
                 || (findStr str (snd x)),(tail . tail $ snd x))) arg

    findStr :: String -> String -> Bool
    findStr [] _ = False
    findStr s@(x:xs) pat
      | pat == (take (length pat) s) = True
      | otherwise                    = findStr xs pat

arg :: [(String,String)]
arg = [("-h","--help")
      ,("-s=tel","--service=telegramm")
      ,("-s=vc", "--service=vkontakte")
      ,("-l=d",  "--loglevel=debug")
      ,("-l=i",  "--loglevel=info")
      ,("-l=w",  "--loglevel=warning")
      ,("-l=e",  "--loglevel=error")
      ,("-r=1",  "--repeat=1")
      ,("-r=2",  "--repeat=2")
      ,("-r=3",  "--repeat=3")
      ,("-r=4",  "--repeat=4")
      ,("-r=5",  "--repeat=5")
      ,("-r=6",  "--repeat=6")
      ]
--}

