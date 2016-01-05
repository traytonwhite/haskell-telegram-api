{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}
{-# LANGUAGE TemplateHaskell   #-}

module Web.Telegram.API.Bot.API
  ( -- * Functions
    getMe
  , sendMessage
  , forwardMessage
  , sendPhoto
  , sendAudio
  , sendDocument
  , sendSticker
  , sendVideo
  , sendVoice
  , sendLocation
  , sendChatAction
  , getUpdates
  , getFile
    -- * API
  , TelegramBotAPI
  , api
    -- * Types
  , Token             (..)
  ) where

import           Control.Applicative
import           Control.Monad.Trans.Either
import           Data.Aeson
import           Data.Aeson.Types
import           Data.Maybe
import           Data.Proxy
import           Data.Text (Text)
import qualified Data.Text as T
import           GHC.Generics
import           GHC.TypeLits
import           Servant.API
import           Servant.Client
import           Web.Telegram.API.Bot.Data
import           Web.Telegram.API.Bot.Responses
import           Web.Telegram.API.Bot.Requests

-- | Telegram Bot's Token
newtype Token = Token Text
  deriving (Show, Eq, Ord)

instance ToText Token where
  toText (Token x) = x

instance FromText Token where
  fromText x = Just (Token (x))

-- | Type for token
type TelegramToken = Capture ":token" Token

-- | Telegram Bot API
type TelegramBotAPI =
         TelegramToken :> "getMe"
         :> Get '[JSON] GetMeResponse
    :<|> TelegramToken :> "sendMessage"
         :> ReqBody '[JSON] SendMessageRequest
         :> Post '[JSON] MessageResponse
    :<|> TelegramToken :> "forwardMessage"
         :> ReqBody '[JSON] ForwardMessageRequest
         :> Post '[JSON] MessageResponse
    :<|> TelegramToken :> "sendPhoto"
         :> ReqBody '[JSON] SendPhotoRequest
         :> Post '[JSON] MessageResponse
    :<|> TelegramToken :> "sendAudio"
         :> ReqBody '[JSON] SendAudioRequest
         :> Post '[JSON] MessageResponse
    :<|> TelegramToken :> "sendDocument"
         :> ReqBody '[JSON] SendDocumentRequest
         :> Post '[JSON] MessageResponse
    :<|> TelegramToken :> "sendSticker"
         :> ReqBody '[JSON] SendStickerRequest
         :> Post '[JSON] MessageResponse
    :<|> TelegramToken :> "sendVideo"
         :> ReqBody '[JSON] SendVideoRequest
         :> Post '[JSON] MessageResponse
    :<|> TelegramToken :> "sendVoice"
         :> ReqBody '[JSON] SendVoiceRequest
         :> Post '[JSON] MessageResponse
    :<|> TelegramToken :> "sendLocation"
         :> ReqBody '[JSON] SendLocationRequest
         :> Post '[JSON] MessageResponse
    :<|> TelegramToken :> "sendChatAction"
         :> ReqBody '[JSON] SendChatActionRequest
         :> Post '[JSON] ChatActionResponse
    :<|> TelegramToken :> "getUpdates"
         :> QueryParam "offset" Int
         :> QueryParam "limit" Int
         :> QueryParam "timeout" Int
         :> Get '[JSON] UpdatesResponse
    :<|> TelegramToken :> "getFile"
         :> QueryParam "file_id" Text
         :> Get '[JSON] FileResponse

-- | Proxy for Thelegram Bot API
api :: Proxy TelegramBotAPI
api = Proxy

getMe_          :: Token -> EitherT ServantError IO GetMeResponse
sendMessage_    :: Token -> SendMessageRequest -> EitherT ServantError IO MessageResponse
forwardMessage_ :: Token -> ForwardMessageRequest -> EitherT ServantError IO MessageResponse
sendPhoto_      :: Token -> SendPhotoRequest -> EitherT ServantError IO MessageResponse
sendAudio_      :: Token -> SendAudioRequest -> EitherT ServantError IO MessageResponse
sendDocument_   :: Token -> SendDocumentRequest -> EitherT ServantError IO MessageResponse
sendSticker_    :: Token -> SendStickerRequest -> EitherT ServantError IO MessageResponse
sendVideo_      :: Token -> SendVideoRequest -> EitherT ServantError IO MessageResponse
sendVoice_      :: Token -> SendVoiceRequest -> EitherT ServantError IO MessageResponse
sendLocation_   :: Token -> SendLocationRequest -> EitherT ServantError IO MessageResponse
sendChatAction_ :: Token -> SendChatActionRequest -> EitherT ServantError IO ChatActionResponse
getUpdates_     :: Token -> Maybe Int -> Maybe Int -> Maybe Int -> EitherT ServantError IO UpdatesResponse
getFile_        :: Token -> Maybe Text -> EitherT ServantError IO FileResponse
getMe_
  :<|> sendMessage_
  :<|> forwardMessage_
  :<|> sendPhoto_
  :<|> sendAudio_
  :<|> sendDocument_
  :<|> sendSticker_
  :<|> sendVideo_
  :<|> sendVoice_
  :<|> sendLocation_
  :<|> sendChatAction_
  :<|> getUpdates_
  :<|> getFile_ =
      client api
          (BaseUrl Https "api.telegram.org" 443)
-- | A simple method for testing your bot's auth token. Requires no parameters.
--   Returns basic information about the bot in form of a 'User' object.
getMe :: Token -> IO (Either ServantError GetMeResponse)
getMe token = runEitherT $ getMe_ token

-- | Use this method to send text messages. On success, the sent 'Message' is returned.
sendMessage :: Token -> SendMessageRequest -> IO (Either ServantError MessageResponse)
sendMessage token request = runEitherT $ sendMessage_ token request

-- | Use this method to forward messages of any kind. On success, the sent 'Message' is returned.
forwardMessage :: Token -> ForwardMessageRequest -> IO (Either ServantError MessageResponse)
forwardMessage token request = runEitherT $ forwardMessage_ token request

-- | Use this method to send photos. On success, the sent 'Message' is returned.
sendPhoto :: Token -> SendPhotoRequest -> IO (Either ServantError MessageResponse)
sendPhoto token request = runEitherT $ sendPhoto_ token request

-- | Use this method to send audio files, if you want Telegram clients to display them in the music player. Your audio must be in the .mp3 format. On success, the sent 'Message' is returned. Bots can currently send audio files of up to 50 MB in size, this limit may be changed in the future.
--
--       For backward compatibility, when the fields __title__ and __performer__ are both empty and the mime-type of the file to be sent is not _audio/mpeg_, the file will be sent as a playable voice message. For this to work, the audio must be in an .ogg file encoded with OPUS. This behavior will be phased out in the future. For sending voice messages, use the 'sendVoice' method instead.
sendAudio :: Token -> SendAudioRequest -> IO (Either ServantError MessageResponse)
sendAudio token request = runEitherT $ sendAudio_ token request

-- | Use this method to send general files. On success, the sent 'Message' is returned. Bots can currently send files of any type of up to 50 MB in size, this limit may be changed in the future.
sendDocument :: Token -> SendDocumentRequest -> IO (Either ServantError MessageResponse)
sendDocument token request = runEitherT $ sendDocument_ token request

-- | Use this method to send .webp stickers. On success, the sent 'Message' is returned.
sendSticker :: Token -> SendStickerRequest -> IO (Either ServantError MessageResponse)
sendSticker token request = runEitherT $ sendSticker_ token request

-- | Use this method to send video files, Telegram clients support mp4 videos (other formats may be sent as 'Document'). On success, the sent 'Message' is returned. Bots can currently send video files of up to 50 MB in size, this limit may be changed in the future.
sendVideo :: Token -> SendVideoRequest -> IO (Either ServantError MessageResponse)
sendVideo token request = runEitherT $ sendVideo_ token request

-- | Use this method to send audio files, if you want Telegram clients to display the file as a playable voice message. For this to work, your audio must be in an .ogg file encoded with OPUS (other formats may be sent as 'Audio' or 'Document'). On success, the sent 'Message' is returned. Bots can currently send voice messages of up to 50 MB in size, this limit may be changed in the future.
sendVoice :: Token -> SendVoiceRequest -> IO (Either ServantError MessageResponse)
sendVoice token request = runEitherT $ sendVoice_ token request

-- | Use this method to send point on the map. On success, the sent 'Message' is returned.
sendLocation :: Token -> SendLocationRequest -> IO (Either ServantError MessageResponse)
sendLocation token request = runEitherT $ sendLocation_ token request

-- | Use this method when you need to tell the user that something is happening on the bot's side.
--   The status is set for 5 seconds or less (when a message arrives from your bot,
--   Telegram clients clear its typing status).
sendChatAction :: Token -> SendChatActionRequest -> IO (Either ServantError ChatActionResponse)
sendChatAction token request = runEitherT $ sendChatAction_ token request

-- | Use this method to receive incoming updates using long polling. An Array of 'Update' objects is returned.
getUpdates :: Token -> Maybe Int -> Maybe Int -> Maybe Int -> IO (Either ServantError UpdatesResponse)
getUpdates token offset limit timeout = runEitherT $ getUpdates_ token offset limit timeout

getFile :: Token -> Text -> IO (Either ServantError FileResponse)
getFile token file_id = runEitherT $ getFile_ token (Just file_id)