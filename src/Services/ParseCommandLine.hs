module Services.ParseCommandLine where

--import Control.Applicative

--import Data.Bifunctor (second)
--import Data.List (isPrefixOf)

newtype Parser a = Parser { unParser :: String -> [(String, a)] }



data Param = Help
           | Telegramm
           | Vcontakte
           | NumberRepeat
           | LogLevel logType
           deriving (Show)

logType = LogType

data LogType = Debug
             | Info
             | Warning
             | Error
             deriving (Show)

parserLine :: String -> String -> [(String, String)]
parserLine p [] = []
parserLine p (x:xs)
  | x == cs = cd  : replacing cs cd xs
  | otherwise = x : replacing cs cd xs


-- Replacing all symbols 'cs' to symbol 'cd' in string.
replacing :: Char -> Char -> String -> String
replacing _  _ [] = []
replacing cs cd (x:xs)
  | x == cs = cd  : replacing cs cd xs
  | otherwise = x : replacing cs cd xs

{--
-- | Parser as a functor. It maps the function over parsed values.
instance Functor Parser where
  fmap f (Parser p) = Parser (\b -> map (second f) (p b))

-- | Parser as an applicative functor. It "unwraps" the functions
-- and values and "wraps back" the result of applying these functions
-- to values.
instance Applicative Parser where
  pure x = Parser (\s -> [(s, x)])
  pf <*> px = Parser (\s -> [ (sx, f x) | (sf, f) <- unParser pf $ s,
                                          (sx, x) <- unParser px $ sf])

-- | Parser as an alternative. It concatenates the lists of results.
-- The neutral element is the empty parser that always fails.
instance Alternative Parser where
  empty = Parser (const [])
  px <|> py = Parser (\s -> unParser px s ++ unParser py s)
--}
-- | Parse the whole input to some value. It only succeeds on
-- deterministic result with no input left.
parseString :: String -> Parser a -> Maybe a
parseString s (Parser p) = case p s of
    [("", val)] -> Just val
    _           -> Nothing

-- | Parse the first input char if it satisfies given predicate.
predP :: (Char -> Bool) -> Parser Char
predP p = Parser f
  where
    f "" = []
    f (c : cs) | p c = [(cs, c)]
               | otherwise = []

-- | Parse the first input char if it matches given char.
charP :: Char -> Parser Char
charP = predP . (==)

-- | Parse the whole string from the input.
stringP :: String -> Parser String
stringP s = Parser f
  where
    f s' | s == s' = [("", s)]
         | otherwise = []

-- | Skip all input chars while they satisfy given predicate.
skip :: (Char -> Bool) -> Parser ()
skip p = Parser (\s -> [(dropWhile p s, ())])

-- | Parse given prefix from input string.
prefixP :: String -> Parser String
prefixP s = Parser f
  where
    f input = if s `isPrefixOf` input
                then [(drop (length s) input, s)]
                else []

-- | Skip given prefix string.
skipString :: String -> Parser ()
skipString s = () <$ prefixP s

