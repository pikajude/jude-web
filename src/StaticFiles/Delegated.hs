{-# LANGUAGE CPP               #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}

module StaticFiles.Delegated where

import           Crypto.Hash.MD5                (hashlazy)
import qualified Data.ByteString.Base64         as B64
import           Data.ByteString.Lazy
import qualified Data.ByteString.Lazy           as BL
import qualified Data.Text                      as T
import qualified Data.Text.Encoding             as T
import qualified Data.Text.Lazy                 as LT
import           Data.Text.Lazy.Encoding
import           Prelude                        hiding (readFile)
import           System.Exit
import           System.Process.ByteString.Lazy

fetchCss :: IO (T.Text, ByteString)
fetchCss = do
    a <- BL.readFile "css/all.scss"
    (exit, stdout, stderr) <- readProcessWithExitCode "sass" (args ++ extraArgs) a
    case exit of
        ExitSuccess -> return $ etag stdout
        ExitFailure _ -> die $ LT.unpack $ decodeUtf8 stderr
    where
        args = [ "--scss"
               , "-Icss"
               , "-Ibower_components/foundation-sites/scss"
               , "-Ibower_components/font-awesome/scss"
               ]
#ifdef PRODUCTION
        extraArgs = ["--style", "compact"]
#else
        extraArgs = []
#endif

etag :: ByteString -> (T.Text, ByteString)
etag s = (hash s, s) where
    hash = T.take 8 . T.decodeUtf8 . B64.encode . hashlazy
