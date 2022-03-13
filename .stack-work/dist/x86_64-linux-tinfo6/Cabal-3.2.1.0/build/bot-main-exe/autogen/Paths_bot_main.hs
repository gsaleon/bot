{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_bot_main (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/gsaleon/MyProject/bot/.stack-work/install/x86_64-linux-tinfo6/56460643c5b176e056c45bb0acfc55069e720ccde50cb3aa3515a0861cf1e077/8.10.7/bin"
libdir     = "/home/gsaleon/MyProject/bot/.stack-work/install/x86_64-linux-tinfo6/56460643c5b176e056c45bb0acfc55069e720ccde50cb3aa3515a0861cf1e077/8.10.7/lib/x86_64-linux-ghc-8.10.7/bot-main-0.1.0.0-BTbHi9VCEBxBl5i73vNzRp-bot-main-exe"
dynlibdir  = "/home/gsaleon/MyProject/bot/.stack-work/install/x86_64-linux-tinfo6/56460643c5b176e056c45bb0acfc55069e720ccde50cb3aa3515a0861cf1e077/8.10.7/lib/x86_64-linux-ghc-8.10.7"
datadir    = "/home/gsaleon/MyProject/bot/.stack-work/install/x86_64-linux-tinfo6/56460643c5b176e056c45bb0acfc55069e720ccde50cb3aa3515a0861cf1e077/8.10.7/share/x86_64-linux-ghc-8.10.7/bot-main-0.1.0.0"
libexecdir = "/home/gsaleon/MyProject/bot/.stack-work/install/x86_64-linux-tinfo6/56460643c5b176e056c45bb0acfc55069e720ccde50cb3aa3515a0861cf1e077/8.10.7/libexec/x86_64-linux-ghc-8.10.7/bot-main-0.1.0.0"
sysconfdir = "/home/gsaleon/MyProject/bot/.stack-work/install/x86_64-linux-tinfo6/56460643c5b176e056c45bb0acfc55069e720ccde50cb3aa3515a0861cf1e077/8.10.7/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "bot_main_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "bot_main_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "bot_main_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "bot_main_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "bot_main_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "bot_main_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
