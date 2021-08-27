#!/bin/sh
set -e
if test "$CONFIGURATION" = "Debug"; then :
  cd /Users/kenneth/dev/cocos/cocos_projects/SharetraceLua/ios-build
  make -f /Users/kenneth/dev/cocos/cocos_projects/SharetraceLua/ios-build/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "Release"; then :
  cd /Users/kenneth/dev/cocos/cocos_projects/SharetraceLua/ios-build
  make -f /Users/kenneth/dev/cocos/cocos_projects/SharetraceLua/ios-build/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "MinSizeRel"; then :
  cd /Users/kenneth/dev/cocos/cocos_projects/SharetraceLua/ios-build
  make -f /Users/kenneth/dev/cocos/cocos_projects/SharetraceLua/ios-build/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "RelWithDebInfo"; then :
  cd /Users/kenneth/dev/cocos/cocos_projects/SharetraceLua/ios-build
  make -f /Users/kenneth/dev/cocos/cocos_projects/SharetraceLua/ios-build/CMakeScripts/ReRunCMake.make
fi

