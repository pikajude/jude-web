{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE OverloadedStrings #-}

module Pages.Prelude (
    module Pages.Prelude,
    module X
) where

import           Control.Monad.Writer
import           Data.Acid                 as X
import           Data.ByteString           as X (ByteString)
import           Data.Monoid               as X ((<>))
import           Data.Text                 as X (Text)
import           Data.Text.Encoding        as X
import           Database                  as X
import           HTMLRendering             as X
import           Network.HTTP.Types.Method
import           Network.HTTP.Types.Status as X
import           Network.Wai               as X
import           Network.Wai.Session       as X hiding (Session)
import qualified Network.Wai.Session
import           SessionData               as X
import           Text.Hamlet               as X

type Session = Network.Wai.Session.Session IO ByteString ByteString

type DB = AcidState Database

type Endpoint = Writer [(Method, Request -> IO Response)] ()

respDefaultLayout :: PageWriter -> Response
respDefaultLayout = responseLBS ok200 [("Content-Type", "text/html; charset=utf-8")] . defaultLayout

method :: Method -> (Request -> IO Response) -> Endpoint
method m q = tell [(m, q)]

redirectTo :: ByteString -> Response
redirectTo loc = responseLBS movedPermanently301 [("Location", loc)] ""

requireAuth :: Session -> (User -> IO Response) -> IO Response
requireAuth sess f = do
    mu <- get sess KUser
    case mu of
        Nothing -> do
            put sess KMessage $ Message "Sorry, I'm afraid you can't do that."
            return $ redirectTo "/"
        Just u -> f u
