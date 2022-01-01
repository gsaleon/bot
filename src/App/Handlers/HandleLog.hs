module App.Handlers.HandleLog where


data LogCommandLine m = LogCommandLine
  {logCommandLine :: IO [String] -> (IO String -> IO ()) -> IO [String]}





