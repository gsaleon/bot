-- file: repstring.hs
import Options.Applicative
import Data.Monoid ((<>))

data Sample = Sample
  { string :: String
  , n :: Int
  , flip :: Bool }

replicateString :: Sample -> IO ()
replicateString (Sample string n flip) = 
    do 
      if not flip then putStrLn repstring else putStrLn $ reverse repstring
          where repstring = foldr (++) "" $ replicate n string

sample :: Parser Sample
sample = Sample
     <$> argument str 
          ( metavar "STRING"
         <> help "String to replicate" )
     <*> argument auto
          ( metavar "INTEGER"
         <> help "Number of replicates" )
     <*> switch
          ( long "flip"
         <> short 'f'
         <> help "Whether to reverse the string" )

main :: IO ()
main = execParser opts >>= replicateString
  where
    opts = info (helper <*> sample)
      ( fullDesc
     <> progDesc "Replicate a string"
     <> header "repstring - an example of the optparse-applicative package" )
