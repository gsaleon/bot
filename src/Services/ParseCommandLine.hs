module Services.ParseCommandLine ( parseLine, findStr
                                 , Parse(Err, Value)
                                 ) where

data Parse a b = Err String | Value [(String, String)]
  deriving (Show)

parseLine :: [String] -> Parse a b
parseLine str = if null str
                  then Err "notInput"
                  else let pars = parseLine' [] str in
                    if elem "help" pars
                      then Err "help"
                      else if elem "parsingError" pars
                             then Err "parsingError"
                             else
  if 
      length (filter (\x -> take 7 x == "polling" ) pars) > 1 ||
      length (filter (\x -> take 6 x == "repeat"  ) pars) > 1 ||
      length (filter (\x -> take 7 x == "service" ) pars) > 1 ||
      length (filter (\x -> take 8 x == "loglevel") pars) > 1
    then Err "multipleValue"
    else Value (parsingValue pars)

parseLine' :: [String] -> [String] -> [String]
parseLine' acc [] = acc
parseLine' acc (x:xs) = parseLine' (acc ++ (f x)) xs
  where
    f x = if take 2 x == "--"
            then [parsingLong x]
            else if head x == '-'
                   then if length x > 1
                          then together [] (drop 1 x)
                          else ["parsingError"]
                   else ["parsingError"]

parsingLong :: String -> String
parsingLong x =
  if findStr x "repeat"
    then "repeat: " ++ drop 9 x
    else if findStr x "polling"
      then "polling: " ++ drop 10 x
      else case take 15 x of
        "--service=teleg" -> "service: telegram"
        "--service=vcont" -> "service: vcontakte"
        "--loglevel=debu" -> "loglevel: debug"
        "--loglevel=info" -> "loglevel: info"
        "--loglevel=warn" -> "loglevel: warning"
        "--loglevel=erro" -> "loglevel: error"
        _                 -> "parsingError"

together :: [String] -> String -> [String]
together acc []     = acc
together acc (y:ys) = if y == 'r' || y == 'p'
                        then together (acc ++ [parsingShort y (y:ys)]) []
                        else together (acc ++ [parsingShort y (y:ys)]) ys

parsingShort :: Char -> String -> String
parsingShort y l = if length l > 1 && (y == 'r' || y == 'p')
                     then case y of
                       'r' -> "repeat: " ++ drop 2 l
                       'p' -> "polling: " ++ drop 2 l
                     else case y of 
                       'h' -> "help"
                       't' -> "service: telegram"
                       'v' -> "service: vcontakte"
                       'd' -> "loglevel: debug"
                       'i' -> "loglevel: info"
                       'w' -> "loglevel: warning"
                       'e' -> "loglevel: error"
                       _   -> "parsingError"

parsingValue :: [String] -> [(String,String)]
parsingValue = map (\x -> (head $ words x, last $ words x))

findStr :: String -> String -> Bool
findStr [] _ = False
findStr s@(x:xs) pat
  | pat == (take (length pat) s) = True
  | otherwise                    = findStr xs pat