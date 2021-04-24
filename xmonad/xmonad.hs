{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}

import           System.Exit
import           XMonad
import qualified XMonad.StackSet               as W
import           XMonad.Actions.CycleWS                       -- Cycle between workspaces and screens
import           XMonad.Actions.DynamicProjects
import           XMonad.Actions.UpdatePointer   ( updatePointer ) -- Keep pointer on active workspace
import           XMonad.Actions.WithAll         ( killAll )
import           XMonad.Layout.SimpleFloat ( simpleFloat )
import           XMonad.Layout.BinarySpacePartition
import           XMonad.Layout.PerScreen        ( ifWider )
import           XMonad.Layout.PerWorkspace     ( onWorkspace )
import           XMonad.Layout.Spacing                        -- Gap-like spacing
import           XMonad.Layout.Tabbed                            -- Multi-purpose browser tabs
import XMonad.Layout.SimplestFloat (simplestFloat)
-- import Xmonad.Layout.Combo \ ComboP              -- Combine multiple layouts
import           XMonad.Prompt
import           XMonad.Prompt.ConfirmPrompt    ( confirmPrompt )
import           XMonad.Prompt.Shell            ( getShellCompl )
import           XMonad.Util.EZConfig
--import XMonad.Util.Run hiding (main)--(runProcessWithInput safeSpawn, runInTerm, spawnPipe)
import           XMonad.Util.SpawnOnce          ( spawnOnOnce )
import Data.Ratio ((%))
import XMonad.Actions.FloatKeys ( keysResizeWindow )


--------------------------------------------------------------------------------
-- Layouts
--------------------------------------------------------------------------------

myLayout =
    -- apply modifier to certain workspaces
    -- modWorkspaces myWorkspaces padding $
    -- I can use onWorkspaces to reduce much of this code
    -- However I would like to allow more freedom for now
  onWorkspace "home" myHomeLayout
    $ onWorkspace "web"   myWebLayout
    $ onWorkspace "media" myMediaLayout
    $ defaultLayout

 where
  defaultLayout = tabs ||| Full ||| emptyBSP
  myHomeLayout  = Full ||| tabs ||| emptyBSP
  myWebLayout   = defaultLayout
  myMediaLayout = defaultLayout

  tabs          = tabbed shrinkText draculaTheme
  spacing' i o = spacingRaw False (border i) True (border o) True
  border x = Border x x x x


--------------------------------------------------------------------------------
-- Workspaces
--------------------------------------------------------------------------------

myWorkspaces = ["home", "web", "media", "virtualbox"]

projects :: [Project]
projects =
    [ Project { projectName      = "home"
              , projectDirectory = "~"
              , projectStartHook = Nothing
              }
    , Project { projectName      = "web"
              , projectDirectory = "~"
              , projectStartHook = Nothing
              }
    , Project { projectName      = "media"
              , projectDirectory = "~"
              , projectStartHook = Nothing
              }
    , Project { projectName      = "virtualbox"
              , projectDirectory = "~"
              , projectStartHook = Nothing
              }
    ]


--------------------------------------------------------------------------------
-- Hooks
--------------------------------------------------------------------------------

myManageHook :: ManageHook
myManageHook = composeAll
  [ className =? "Inkscape" --> doShift "media"
  , className =? "Gimp" --> doShift "media"
  , className =? "Zathura" --> doShift "media"
  , className =? "qutebrowser" --> doShift "web"
  , className =? "Home" --> doShift "home"
  , className =? "Emacs" --> doShift "home"
  , className =? "firefoxdeveloperedition" --> doShift "web"
  , className =? "firefox" --> doShift "web"
  ]


myLogHook :: X ()
myLogHook = updatePointer (0.5, 0.5) (0, 0)  -- Pointer follows focus



--------------------------------------------------------------------------------
-- Themes
--------------------------------------------------------------------------------

cyan = "#8be9fd"
dark = "#21222C"
bg = "#44475A"
fg = "#f8f8f2"

draculaTheme :: Theme
draculaTheme = def
  { activeColor         = bg
  , inactiveColor       = dark
  , activeTextColor     = fg
  , inactiveTextColor   = fg
  , activeBorderWidth   = 0
  , inactiveBorderWidth = 0
  , fontName            =
    "xft:Source Code Pro-8:antialias=true:hinting=true:monospace:style=Powerline"
  , decoHeight          = 24
  , urgentColor         = bg
  , urgentTextColor     = fg
  }


promptTheme :: XPConfig
promptTheme = def { font              = "xft:Source Code Pro-16"
                  , bgColor           = bg
                  , fgColor           = fg
                  , fgHLight          = fg
                  , bgHLight          = dark
                  , borderColor       = dark
                  , promptBorderWidth = 4
                  , height            = 100
                  , position          = CenteredAt 0.5 0.5
                  , autoComplete      = Just 0
                  }


--------------------------------------------------------------------------------
-- Prompts
--------------------------------------------------------------------------------

newtype Prompt = Prompt String
instance XPrompt Prompt where
  showXPrompt (Prompt p) = p


mkXPrompt' :: String -> String -> [String] -> XPConfig -> (String -> X ()) -> X ()
mkXPrompt' p t cmds c = mkXPrompt (Prompt p) c' completions
 where
  c'          = c { defaultText = t }
  completions = getShellCompl cmds $ searchPredicate c


quickLaunch :: X ()
quickLaunch = mkXPrompt' "λ " "" cmds promptTheme subLaunch
 where
  cmds =
    ["tmuxinator", "volume", "brightness", "screenshot", "refresh-monitors"]


subLaunch :: String -> X ()
subLaunch input =
  let
    t = promptTheme { autoComplete = Nothing }
    newPrompt p d cmd = mkXPrompt' p d [] t $ \x -> spawn $ cmd x
  in

    case input of
      "brightness" ->
        newPrompt (input ++ "(1-10): ") ""
          $ \x -> "xrandr --output eDP-1-1 --brightness "
              ++ show ((read x :: Float) / 10)

      "volume" ->
        newPrompt (input ++ "(0-150): ") "" $ \x -> "ponymix set-volume " ++ x

      "refresh-monitors" -> spawn "xrandr --auto"

      _                  -> pure ()


--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

myKeyBindings :: XConfig l -> XConfig l
myKeyBindings conf = additionalKeysP
  conf
    -- Launching programs
  [ ("M-<Return>", spawn myTerm)
  , ("M-0"       , spawn "sleep 0.5;xset dpms force off")
  , ( "M-p" , spawn "/usr/bin/rofi -show run")  -- drun for desktop entries
  , ("M-q", spawn "xmonad --recompile && xmonad --restart")
  , ("M-S-q", io exitSuccess)
  -- , ( "M-t" , quickLaunch)
  -- , ("M-t", spawn "st -e nvim -c \"startinsert\"")
  , ("M-s", spawn "mbsync -a")

    -- Windows
  , ("M-j"          , windows W.focusDown)
  , ("M-k"          , windows W.focusUp)
  , ("M-S-j"        , windows W.swapDown)
  , ("M-S-k"        , windows W.swapUp)
  , ("M-m"          , windows W.focusMaster)
  , ("M-S-m"        , windows W.swapMaster)
  , ("M-,"          , sendMessage (IncMasterN 1))
  , ("M-."          , sendMessage (IncMasterN (-1)))
  , ("M-h"          , sendMessage (ExpandTowards L))
  , ("M-l"          , sendMessage (ExpandTowards R))
  , ("M-<Backspace>", kill)
  , ( "M-S-<Backspace>" , confirmPrompt promptTheme "Kill All" killAll)
  , ( "M1-t" , withFocused $ windows . W.sink)

  -- , ("M1-d", withFocused (keysResizeWindow (-10,-10) (1%2,1%2)))
  -- , ("M1-s", withFocused (keysResizeWindow (10,10) (1%2,1%2)))

    -- emptyBSP
  , ("M1-<Left>"   , sendMessage $ ExpandTowards L)
  , ("M1-<Right>"  , sendMessage $ ShrinkFrom L)
  , ("M1-<Up>"     , sendMessage $ ExpandTowards U)
  , ("M1-<Down>"   , sendMessage $ ShrinkFrom U)
  , ("M1-C-<Left>" , sendMessage $ ShrinkFrom R)
  , ("M1-C-<Right>", sendMessage $ ExpandTowards R)
  , ("M1-C-<Up>"   , sendMessage $ ShrinkFrom D)
  , ("M1-C-<Down>" , sendMessage $ ExpandTowards D)
  -- , ("M1-s"        , sendMessage $ Swap)
  , ( "M1-r" , sendMessage $ Rotate)

    -- Workspaces
  , ("M-w"  , switchProjectPrompt promptTheme)
  , ("M-S-w", shiftToProjectPrompt promptTheme)
  , ( "M1-<Tab>" , toggleWS)

    -- Screens
  , ( "M-<Tab>" , nextScreen)

    -- Layouts
  , ("M-<Space>", sendMessage NextLayout)
  , ( "M-S-<Space>" , sendMessage FirstLayout)

    -- FN keys
  , ("<XF86AudioRaiseVolume>", spawn "ponymix increase 3")
  , ("<XF86AudioLowerVolume>", spawn "ponymix decrease 3")
  , ("<XF86AudioMute>"       , spawn "ponymix toggle")
  ]


--------------------------------------------------------------------------------
-- Config
--------------------------------------------------------------------------------

myTerm = "/home/trey/.local/kitty.app/bin/kitty"
myConf = def { normalBorderColor  = dark
             , focusedBorderColor = bg
             , terminal           = myTerm
             , layoutHook         = myLayout
             , manageHook         = myManageHook
             , workspaces         = myWorkspaces
             , modMask            = mod4Mask
             , borderWidth        = 2
             , logHook            = myLogHook
             }


--------------------------------------------------------------------------------
-- MAIN
--------------------------------------------------------------------------------

main :: IO ()
main = do
  xmonad $ dynamicProjects projects $ myKeyBindings myConf
