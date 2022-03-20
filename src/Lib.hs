module Lib where

import           Data.Maybe           (fromJust, isJust)
import           Data.List            (find)
import           Prelude       hiding (id)
-- import           System.Info          (os)

import           Services.ParseCommandLine (Parse(Err, Value))
import           App.Types.Config
import           App.Types.ConfigTelegram
import           App.Types.ConfigVkontakte


printPrettyworkGeneral :: SetupGeneral -> String
printPrettyworkGeneral (SetupGeneral pollingGeneral repeatGeneral
                          logLevelGeneral serviceGeneral) =
  "Polling: " ++ show pollingGeneral ++ " sek" ++
  ", Number repeat: " ++  show repeatGeneral ++
  ", Loglevel: " ++ show logLevelGeneral ++
  ", Service: " ++ serviceGeneral

printPrettyVkontakte :: SetupVkontakte -> String
printPrettyVkontakte (SetupVkontakte groupVkId tokenVkontakte
  descriptionVk aboutVk commandVk questionVk) = ""
{-  "\n" ++
  "urlVkontakte -         " ++ urlVkontakte         ++ "\n" ++
  "tokenVkontakte -       " ++ tokenVkontakte       ++ "\n" ++
  "userNameVkontakte -    " ++ userNameVkontakte    ++ "\n" ++
  "tokenVkontakte -       " ++ tokenVkontakte       ++ "\n" ++
  "descriptionVkontakte - " ++ descriptionVkontakte ++ "\n" ++
  "aboutVkontakte -       " ++ aboutVkontakte       ++ "\n" ++
  "commandVkontakte -     " ++ commandVkontakte     ++ "\n" ++
  "----------------------end printPrettyVkontakte------------"-}

printPrettyTelegram :: SetupTelegram -> String
printPrettyTelegram (SetupTelegram tokenTelegram
  descriptionTelegram aboutTelegram commandTelegram
  questionTelegramRepeat) = ""
{-  "\n" ++
  "tokenTelegram -       " ++ tokenTelegram          ++ "\n" ++
  "descriptionTelegram - " ++ descriptionTelegram    ++ "\n" ++
  "aboutTelegram -       " ++ aboutTelegram          ++ "\n" ++
  "commandTelegram -     " ++ commandTelegram        ++ "\n" ++
  "questionTelegramRepeat" ++ questionTelegramRepeat ++"\n" ++
  "----------------------end printPrettyTelegram------------"-}

{-printPrettySetup' :: SetupGeneral' -> String
printPrettySetup' (SetupGeneral pollingGeneral' repeatGeneral'
  logLevelGeneral' serviceGeneral' tokenTelegram' descriptionTelegram'
  aboutTelegram' commandTelegram' questionTelegramRepeat' clientVkId'
  groupVkId' tokenVkontakte' descriptionVk' aboutVk' commandVk'
  questionVk' data1' data2' data3' data4' data5')= ""-}
{-  "\n" ++
  "pollingGeneral -       " ++ show pollingGeneral  ++ "\n" ++
  "repeatGeneral -        " ++ show repeatGeneral   ++ "\n" ++
  "logLevelGeneral -      " ++ show logLevelGeneral ++ "\n" ++
  "serviceGeneral -       " ++ show serviceGeneral  ++ "\n" ++
  "----------------------end printPrettySetup----------------"-}

printPrettySetup :: SetupGeneral -> String
printPrettySetup (SetupGeneral pollingGeneral repeatGeneral
  logLevelGeneral serviceGeneral)= ""
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

makeSystemPath :: FilePath -> FilePath
makeSystemPath str =
  if '/' `elem` str      -- if os = "linux" or ""
    then ((makeSystemPath' str) ++ "/bot/")
    else ((makeSystemPath'' str) ++ "\\bot")
  where
    makeSystemPath' [] = []
    makeSystemPath' (x0:x1:x2:x3:x4:xs)
      | x0:x1:x2:x3:x4:[] /= "/bot/" = x0 : makeSystemPath' (x1:x2:x3:x4:xs)
      | otherwise                    = []
    makeSystemPath'' [] = []
    makeSystemPath'' (x0:x1:x2:x3:x4:xs)
      | x0:x1:x2:x3:x4:[] /= "\\bot\\" = x0 : makeSystemPath'' (x1:x2:x3:x4:xs)
      | otherwise                    = []
