{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

module App.Types.ConfigTelegram where


import           Data.Aeson
import           Control.Monad         (mzero)
import           Prelude       hiding  (id, Enum)
import           Data.Time.LocalTime   (getCurrentTimeZone, utcToLocalTime)
import           Data.Time             (formatTime, defaultTimeLocale)
import           Data.Time.Clock.POSIX (posixSecondsToUTCTime)
import           Network.HTTP.Client   (Request, Manager)
-- import           GHC.Generics
-- import           Data.Time.Format     (makeLocalTime)

data SetupTelegramm = SetupTelegramm
                    { urlTelegramm            :: String
                    , nameTelegramm           :: String
                    , userNameTelegramm       :: String
                    , tokenTelegramm          :: String
                    , descriptionTelegramm    :: String
                    , aboutTelegramm          :: String
                    , commandTelegramm        :: String
                    , questionTelegrammRepeat :: String
                    } deriving Show

instance FromJSON SetupTelegramm where
  parseJSON (Object setupTelegramm) = SetupTelegramm
    <$> setupTelegramm .: "urlTelegramm"
    <*> setupTelegramm .: "nameTelegramm"
    <*> setupTelegramm .: "userNameTelegramm"
    <*> setupTelegramm .: "tokenTelegramm"
    <*> setupTelegramm .: "descriptionTelegramm"
    <*> setupTelegramm .: "aboutTelegramm"
    <*> setupTelegramm .: "commandTelegramm"
    <*> setupTelegramm .: "questionTelegrammRepeat"
  parseJSON _                       = mzero

data ResponseGetMe  = ResponseGetMe
                    { okResponseGetMe             :: Bool
                    , idResponseGetMe             :: Int
                    , is_botResponseGetMe         :: Bool
                    , first_nameResponseGetMe     :: String
                    , usernameResponseGetMe       :: String
                    , can_join_groups             :: Bool
                    , can_read_all_group_messages :: Bool
                    , supports_inline_queries     :: Bool
                    } deriving (Show)

instance FromJSON ResponseGetMe where
  parseJSON = withObject "ResponseGetMe" $ \o -> do
    okResponseGetMe             <- o      .: "ok"
    result                      <- o      .: "result"
    idResponseGetMe             <- result .: "id"
    is_botResponseGetMe         <- result .: "is_bot"
    first_nameResponseGetMe     <- result .: "first_name"
    usernameResponseGetMe       <- result .: "username"
    can_join_groups             <- result .: "can_join_groups"
    can_read_all_group_messages <- result .: "can_read_all_group_messages"
    supports_inline_queries     <- result .: "supports_inline_queries"
    return ResponseGetMe{..}

data SendGetUpdate = SendGetUpdate
                   { timeout :: Int
                   , limit   :: Int
                   , offset  :: Int
                   } deriving (Show)

instance ToJSON SendGetUpdate where
  toJSON SendGetUpdate {..} = object [
    "timeout" .= timeout,
    "limit"   .= limit,
    "offset"  .= offset              ]

-- makeLocalTime :: String -> String
makeLocalTime timeEpoch = do
  timezone  <- getCurrentTimeZone
  let timeNow = show $ formatTime defaultTimeLocale "%Y-%m-%d %H:%M:%S"
           $ utcToLocalTime timezone $ posixSecondsToUTCTime timeEpoch
  return timeNow

newtype ResultRequest = ResultRequest
                      { result :: [Update]    --ValueReq
                      } deriving (Show)

instance FromJSON ResultRequest where
  parseJSON (Object r) = ResultRequest
    <$> r .: "result"
  parseJSON _          = mzero

newtype SendMessage = SendMessage
                      { result' :: Update
                      } deriving (Show)

instance FromJSON SendMessage where
  parseJSON (Object s) = SendMessage
    <$> s .: "result"
  parseJSON _          = mzero

data Update = Update
            { update_idUpdate :: Int
            , messageUpdate   :: Message
            , callback_query  :: CallbackQuery
            } deriving (Show, Eq)

instance FromJSON Update where
  parseJSON = withObject "Update" $ \u -> do
    update_idUpdate <- u .: "update_id"
    messageUpdate   <- u .:? "message"        .!= Message {message_idMessage = 0, from = User {idUser = 0, first_name = "", last_name = "", username = ""}, date = 0, chat = Chat {idChat = 0, typeChat = "", title = "", usernameChat = "", first_nameChat = "", last_nameChat = ""}, forward_from = User {idUser = 0, first_name = "", last_name = "", username = ""}, forward_date = 0, textMessage = ""}
    callback_query  <- u .:? "callback_query" .!= CallbackQuery {idCallbackQuery = "", fromCallbackQuery = User {idUser = 0, first_name = "", last_name = "", username = ""}, dataCallbackQuery = "", messageCallbackQuery = Message {message_idMessage = 0, from = User {idUser = 0, first_name = "", last_name = "", username = ""}, date = 0, chat = Chat {idChat = 0, typeChat = "", title = "", usernameChat = "", first_nameChat = "", last_nameChat = ""}, forward_from = User {idUser = 0, first_name = "", last_name = "", username = ""}, forward_date = 0, textMessage = ""}, inline_message_id = ""}
    return Update {..}

data CallbackQuery = CallbackQuery
                   { idCallbackQuery      :: String
                   , fromCallbackQuery    :: User
                   , messageCallbackQuery :: Message
                   , inline_message_id    :: String
                   , dataCallbackQuery    :: String
                   } deriving (Show, Eq)

instance FromJSON CallbackQuery where
  parseJSON = withObject "CallbackQuery" $ \c -> do
    idCallbackQuery      <- c .: "id"
    fromCallbackQuery    <- c .: "from"
    messageCallbackQuery <- c .:? "message"           .!= Message {message_idMessage = 0, from = User {idUser = 0, first_name = "", last_name = "", username = ""}, date = 0, chat = Chat {idChat = 0, typeChat = "", title = "", usernameChat = "", first_nameChat = "", last_nameChat = ""}, forward_from = User {idUser = 0, first_name = "", last_name = "", username = ""}, forward_date = 0, textMessage = ""}
    inline_message_id    <- c .:? "inline_message_id" .!= ""
    dataCallbackQuery    <- c .: "data"
    return CallbackQuery{..}

data User = User
          { idUser     :: Int
          , first_name :: String
          , last_name  :: String
          , username   :: String
          } deriving (Show, Eq)

instance FromJSON User where
  parseJSON = withObject "User" $ \u -> do
    idUser     <- u .: "id"
    first_name <- u .: "first_name"
    last_name  <- u .:? "last_name" .!= ""
    username   <- u .:? "username"  .!= ""
    return User{..}

data Message = Message
             { message_idMessage :: Int
             , from              :: User
             , date              :: Int
             , chat              :: Chat
             , forward_from      :: User
             , forward_date      :: Int
             -- , reply_to_message  :: Message
             , textMessage       :: String
             } deriving (Show, Eq)

instance FromJSON Message where
  parseJSON = withObject "Message" $ \m -> do
    message_idMessage <- m .: "message_id"
    from              <- m .:? "from"             .!= User {idUser = 0, first_name = "", last_name = "", username = ""}
    date              <- m .: "date"
    chat              <- m .: "chat"
    forward_from      <- m .:? "forward_from"     .!= User {idUser = 0, first_name = "", last_name = "", username = ""}
    forward_date      <- m .:? "forward_date"     .!= 0
    -- reply_to_message  <- m .:? "reply_to_message" .!= Message {message_idMessage = 0, from = User {idUser = 0, first_name = "", last_name = "", username = ""}, date = 0, chat = Chat {idChat = 0, typeChat = "", title = "", usernameChat = "", first_nameChat = "", last_nameChat = ""}, forward_from = User {idUser = 0, first_name = "", last_name = "", username = ""}, forward_date = 0, textMessage = ""}
    textMessage       <- m .:? "text"      .!= ""
    return Message{..}

data Chat = Chat
          { idChat         :: Int
          , typeChat       :: String   --Enum
          , title          :: String
          , usernameChat   :: String
          , first_nameChat :: String
          , last_nameChat  :: String
          } deriving (Show, Eq)

instance FromJSON Chat where
  parseJSON = withObject "Chat" $ \c -> do
    idChat                         <- c .: "id"
    typeChat                       <- c .: "type"
    title                          <- c .:? "title"      .!= ""
    usernameChat                   <- c .:? "username"   .!= ""
    first_nameChat                 <- c .:? "first_name" .!= ""
    last_nameChat                  <- c .:? "last_name"  .!= ""
    return Chat {..}

data SendMessageTo = SendMessageTo
                 { textTo                :: String
                 , chat_idTo             :: Int
                 , reply_to_message_idTo :: Int
                 } deriving (Show)

instance ToJSON SendMessageTo where
  toJSON SendMessageTo {..} = object [
    "text"                .= textTo,
    "chat_id"             .= chat_idTo,
    "reply_to_message_id" .= reply_to_message_idTo
                                     ]

data SendMessageWithKey = SendMessageWithKey
                 { textWithKey                :: String
                 , chat_idWithKey             :: Int
                 , reply_to_message_idWithKey :: Int
                 , reply_markup               :: ReplyKeyboardMarkup            --InlineKeyboardMarkup
                 }

instance ToJSON SendMessageWithKey where
  toJSON SendMessageWithKey {..} = object [
      "text"                .= textWithKey,
      "chat_id"             .= chat_idWithKey,
      "reply_to_message_id" .= reply_to_message_idWithKey,
      "reply_markup"        .= reply_markup
                                          ]

data SendMessageHideKeyboard = SendMessageHideKeyboard
                             { textHideKeyboard         :: String
                             , chat_idHideKeyboard      :: Int
                             , reply_markupHideKeyboard :: ReplyKeyboardHide
                             } deriving (Show)

instance ToJSON SendMessageHideKeyboard where
  toJSON SendMessageHideKeyboard {..} = object [
      "text"         .= textHideKeyboard,
      "chat_id"      .= chat_idHideKeyboard,
      "reply_markup" .= reply_markupHideKeyboard
                                               ]

-- ----------------------------------------------------------------------
{-data InlineKeyboardMarkup = InlineKeyboardMarkup [[InlineKeyboardButton]]

instance ToJSON InlineKeyboardMarkup where
    toJSON (InlineKeyboardMarkup inline_keyboard) =
      object  [ "inline_keyboard" .= inline_keyboard
              ]

data InlineKeyboardButton = InlineKeyboardButton
                          { textKeyboardButton ::String
                          , callback_data      ::String
                          }

instance ToJSON InlineKeyboardButton where
    toJSON (InlineKeyboardButton textKeyboardButton callback_data) = object
      [ "text"          .= textKeyboardButton
      , "callback_data" .= callback_data
      ]-}
-- ------------------------------------------------------------------------

data ReplyKeyboardMarkup = ReplyKeyboardMarkup
                         { keyboard          :: [[KeyboardButton]]
                         -- , resize_keyboard   :: Bool
                         -- , one_time_keyboard :: Bool
                         -- , selective         :: Bool
                         }

instance ToJSON ReplyKeyboardMarkup where
  toJSON ReplyKeyboardMarkup {..} = object [
    "keyboard"          .= keyboard
    -- "resize_keyboard"   .= resize_keyboard,
    -- "one_time_keyboard" .= one_time_keyboard
    -- "selective"         .= selective
                                           ]

{-instance ToJSON ReplyKeyboardMarkup where
  toJSON = withObject "ReplyKeyboardMarkup" $ \r -> do
    keyboard          <- r .: "keyboard"
    resize_keyboard   <- r .:? "resize_keyboard"   .!= False
    one_time_keyboard <- r .:? "one_time_keyboard" .!= False
    selective         <- r .:? "selective"         .!= False
    return ReplyKeyboardMarkup {..}-}

data  KeyboardButton = KeyboardButton {text :: String}

instance ToJSON KeyboardButton where
    toJSON (KeyboardButton textKeyboardButton) = object
      [ "text" .= textKeyboardButton
      ]

data  ReplyKeyboardHide =  ReplyKeyboardHide
                        { hide_keyboard :: Bool
                        } deriving (Show)

instance ToJSON ReplyKeyboardHide where
  toJSON (ReplyKeyboardHide hide_keyboard) = object
    [ "hide_keyboard" .= hide_keyboard
    ]  

data HandleTelegram = HandleTelegram
    { requestTelegram :: Request -> Manager -> IO () }


