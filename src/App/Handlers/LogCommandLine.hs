module App.Handlers.LogCommandLine (logCommandLine) where


data LogCommandLine m = LogCommandLine
  {logCommandLine :: IO [String] -> (IO String -> IO ()) -> IO [String]}





