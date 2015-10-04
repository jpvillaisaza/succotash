{-# LANGUAGE CPP #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Site (app)

import Control.Exception (SomeException)
import qualified Control.Exception as Exception
import qualified Data.Text as Text
import qualified System.IO as IO

import Snap.Core
import Snap.Http.Server
import Snap.Snaplet
import Snap.Snaplet.Config

#ifdef DEVELOPMENT
import Snap.Loader.Dynamic (loadSnapTH)
#else
import Snap.Loader.Static (loadSnapTH)
#endif


main :: IO ()
main = do
  (conf, site, cleanup) <- $(loadSnapTH [| getConf |]
                                        'getActions
                                        ["snaplets/heist/templates"])
  _ <- Exception.try (httpServe conf site) :: IO (Either SomeException ())
  cleanup


getConf :: IO (Config Snap AppConfig)
getConf = commandLineAppConfig defaultConfig


getActions :: Config Snap AppConfig -> IO (Snap (), IO ())
getActions conf = do
  (msgs, site, cleanup) <- runSnaplet (appEnvironment =<< getOther conf) app
  IO.hPutStrLn IO.stderr (Text.unpack msgs)
  return (site, cleanup)
