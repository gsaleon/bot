module Lib where

import           Data.Maybe           (fromJust, isJust)
import           Data.List            (find)
import           Prelude       hiding (id)

import           Services.ParseCommandLine (Parse(Err, Value))
import           App.Types.Config
import           App.Types.ConfigTelegram
import           App.Types.ConfigVcontakte





printPrettyVcontakte :: SetupVcontakte -> String
printPrettyVcontakte (SetupVcontakte urlVcontakte nameVcontakte
      userNameVcontakte tokenVcontakte descriptionVcontakte
      aboutVcontakte commandVcontakte) = ""
{-  "\n" ++
  "urlVcontakte -         " ++ urlVcontakte         ++ "\n" ++
  "tokenVcontakte -       " ++ tokenVcontakte       ++ "\n" ++
  "userNameVcontakte -    " ++ userNameVcontakte    ++ "\n" ++
  "tokenVcontakte -       " ++ tokenVcontakte       ++ "\n" ++
  "descriptionVcontakte - " ++ descriptionVcontakte ++ "\n" ++
  "aboutVcontakte -       " ++ aboutVcontakte       ++ "\n" ++
  "commandVcontakte -     " ++ commandVcontakte     ++ "\n" ++
  "----------------------end printPrettyVcontakte------------"-}

printPrettyTelegramm :: SetupTelegramm -> String
printPrettyTelegramm (SetupTelegramm urlTelegramm nameTelegramm
      userNameTelegramm tokenTelegramm descriptionTelegramm
      aboutTelegramm commandTelegramm questionTelegrammRepeat) = ""
{-  "\n" ++
  "urlTelegramm -         " ++ urlTelegramm            ++ "\n" ++
  "tokenTelegramm -       " ++ tokenTelegramm          ++ "\n" ++
  "userNameTelegramm -    " ++ userNameTelegramm       ++ "\n" ++
  "tokenTelegramm -       " ++ tokenTelegramm          ++ "\n" ++
  "descriptionTelegramm - " ++ descriptionTelegramm    ++ "\n" ++
  "aboutTelegramm -       " ++ aboutTelegramm          ++ "\n" ++
  "commandTelegramm -     " ++ commandTelegramm        ++ "\n" ++
  "questionTelegrammRepeat" ++ questionTelegrammRepeat ++"\n" ++
  "----------------------end printPrettyTelegramm------------"-}

printPrettySetup :: SetupGeneral -> String
printPrettySetup (SetupGeneral pollingGeneral repeatGeneral
      logLevelGeneral serviceGeneral) = ""
{-  "\n" ++
  "pollingGeneral -       " ++ show pollingGeneral  ++ "\n" ++
  "repeatGeneral -        " ++ show repeatGeneral   ++ "\n" ++
  "logLevelGeneral -      " ++ show logLevelGeneral ++ "\n" ++
  "serviceGeneral -       " ++ show serviceGeneral  ++ "\n" ++
  "----------------------end printPrettySetup----------------"-}

printResponseGetMe :: ResponseGetMe -> String
printResponseGetMe (ResponseGetMe okResponseGetMe idResponseGetMe is_botResponseGetMe first_nameResponseGetMe
      username can_join_groups can_read_all_group_messages
      supports_inline_queries) = 
  "okResponseGetMe             - " ++ show okResponseGetMe             ++ "\n" ++
  "idResponseGetMe             - " ++ show idResponseGetMe             ++ "\n" ++
  "is_botResponseGetMe         - " ++ show is_botResponseGetMe         ++ "\n" ++
  "first_nameResponseGetMe     - " ++ show first_nameResponseGetMe     ++ "\n" ++
  "username                    - " ++ show username                    ++ "\n" ++
  "can_join_groups             - " ++ show can_join_groups             ++ "\n" ++
  "can_read_all_group_messages - " ++ show can_read_all_group_messages ++ "\n" ++
  "supports_inline_queries     - " ++ show supports_inline_queries     ++ "\n" ++  
  "----------------------end printResultGetMe---------------"

printResponseGetUpdate :: ResultRequest -> String
printResponseGetUpdate (ResultRequest lst) =
  "message_id - " ++ show (map (message_id) lst)           ++ "\n" ++
  "update_id  - " ++ show (map (update_id) lst)      ++ "\n" ++
  "idChat     - " ++ show (map (idChat) lst)         ++ "\n" ++
  "first_name - " ++ show (map (first_nameChat) lst) ++ "\n" ++
  "last_name  - " ++ show (map (last_nameChat) lst)  ++ "\n" ++
  "text       - " ++ show (map (text) lst)           ++ "\n" ++  
  "----------------------end ResultResponseGetUpdate------------------"

{-fromResultRequest :: ResultRequest -> [ValueReq]
fromResultRequest (ResultRequest lst) = lst-}

fromCommandLine :: SetupGeneral ->[(String, String)] -> SetupGeneral
fromCommandLine s cL = SetupGeneral { pollingGeneral  = a
                                    , repeatGeneral   = b
                                    , logLevelGeneral = c
                                    , serviceGeneral  = d
                                    }
  where
    a = if (isJust $ find ((=="polling:") . fst) cL)
          then read $ snd $ fromJust $ find ((=="polling:") . fst) cL :: Int
          else pollingGeneral s
    b = if (isJust $ find ((=="repeat:") . fst) cL)
          then read $ snd $ fromJust $ find ((=="repeat:") . fst) cL :: Int
          else repeatGeneral s
    c = if (isJust $ find ((=="loglevel:") . fst) cL)
          then snd $ fromJust $ find ((=="loglevel:") . fst) cL
          else logLevelGeneral s 
    d = if (isJust $ find ((=="service:") . fst) cL)
          then snd $ fromJust $ find ((=="service:") . fst) cL
          else serviceGeneral s  

fromLeft :: String -> Parse a b -> String
fromLeft _ (Err a) = a
fromLeft a _       = a

fromRight :: [(String,String)] -> Parse a b -> [(String,String)]
fromRight _ (Value b) = b
fromRight b _         = b

makeSystemPath :: FilePath -> (FilePath, Os)
makeSystemPath str =
  if '/' `elem` str
    then ((makeSystemPath' str) ++ "/bot/", Linux)
    else ((makeSystemPath'' str) ++ "\\bot", Windows)
  where
    makeSystemPath' [] = []
    makeSystemPath' (x0:x1:x2:x3:x4:xs)
      | x0:x1:x2:x3:x4:[] /= "/bot/" = x0 : makeSystemPath' (x1:x2:x3:x4:xs)
      | otherwise                    = []
    makeSystemPath'' [] = []
    makeSystemPath'' (x0:x1:x2:x3:x4:xs)
      | x0:x1:x2:x3:x4:[] /= "\\bot\\" = x0 : makeSystemPath'' (x1:x2:x3:x4:xs)
      | otherwise                    = []
