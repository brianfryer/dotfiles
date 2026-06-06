#!/usr/bin/env bash
set -euo pipefail

# Apply user-level macOS defaults that are reasonable to keep in a dotfiles repo.
#
# This script deliberately avoids sudo, firmware settings, power-management
# changes, Spotlight index rebuilds, TCC/Accessibility database writes, and
# preferences for applications that are not part of the default Brewfile.
# Those settings can have machine-wide side effects, may vary by macOS release,
# or require a manual decision that should not be hidden inside bootstrap.
#
# Usage:
#   ./macos-defaults.sh
#   ./macos-defaults.sh --dry-run
#   ./macos-defaults.sh --restart-apps

dry_run=false
restart_apps=false

usage() {
  cat <<'USAGE'
Usage: ./macos-defaults.sh [--dry-run] [--restart-apps]

Options:
  --dry-run       Print the defaults commands without applying them.
  --restart-apps Restart affected user apps and services after applying defaults.
  --help         Show this help text.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      dry_run=true
      ;;
    --restart-apps)
      restart_apps=true
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

log() {
  printf '\n==> %s\n' "$*"
}

warn() {
  printf '  [warn] %s\n' "$*" >&2
}

run() {
  local output

  if [ "$dry_run" = true ]; then
    printf '  '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi

  if ! output="$("$@" 2>&1)"; then
    warn "Skipped setting: $*"
    if [ -n "$output" ]; then
      warn "$output"
    fi
  fi
}

apply_document_and_text_defaults() {
  log "Document, text, and keyboard defaults"

  # Keep save and print dialogs expanded so destination, format, and advanced
  # options are visible without an extra disclosure click in native macOS apps.
  run defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  run defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
  run defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  run defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Prefer local documents over iCloud defaults. Project files and generated
  # assets should land on disk unless an app-specific workflow chooses iCloud.
  run defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  # Smart quotes and smart dashes are useful in prose but surprising in code,
  # command snippets, config files, and issue comments.
  run defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  run defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Full keyboard access lets Tab reach all controls in dialogs instead of only
  # text boxes and lists. That keeps keyboard navigation consistent.
  run defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  # Press-and-hold opens the accent picker. For development, repeated keypresses
  # are usually more valuable than accent insertion.
  run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  run defaults write NSGlobalDomain KeyRepeat -int 1

  # Keep plain-text editing predictable when TextEdit is used as a scratchpad.
  run defaults write com.apple.TextEdit RichText -int 0
  run defaults write com.apple.TextEdit PlainTextEncoding -int 4
  run defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
}

apply_trackpad_mouse_and_sound_defaults() {
  log "Trackpad, mouse, and sound defaults"

  # Enable tap-to-click and right-click behavior for the current user. The
  # current-host writes cover hardware-specific trackpad preferences.
  run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  run defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  run defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
  run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  run defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
  run defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

  # Use non-natural scrolling. This is intentionally personal preference, but it
  # is user-scoped and easy to reverse in System Settings.
  run defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

  # Disable audible interface feedback without changing output devices or volume
  # configuration.
  run defaults write com.apple.sound.beep.feedback -int 0
  run defaults write com.apple.systemsound com.apple.sound.beep.volume -float 0
  run defaults write com.apple.systemsound com.apple.sound.uiaudio.enabled -int 0

  # Accessibility zoom preferences are controlled by protected macOS state on
  # current releases. Configure them in System Settings instead of writing the
  # com.apple.universalaccess domain from this script.
}

apply_screenshot_and_finder_defaults() {
  log "Screenshots and Finder defaults"

  # Keep screenshots easy to find and diff. PNG is lossless; disabling shadows
  # avoids noisy transparent borders in design reviews and bug reports.
  run defaults write com.apple.screencapture location -string "$HOME/Desktop"
  run defaults write com.apple.screencapture type -string png
  run defaults write com.apple.screencapture disable-shadow -bool true

  # Finder defaults favor development workflows: show hidden files, extensions,
  # current paths, and status information without extra menu toggles.
  run defaults write com.apple.finder AppleShowAllFiles -bool true
  run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  run defaults write com.apple.finder ShowStatusBar -bool true
  run defaults write com.apple.finder ShowPathbar -bool true

  # Searches start in the current folder so Finder behaves more like project
  # search tools and does not unexpectedly search the entire Mac.
  run defaults write com.apple.finder FXDefaultSearchScope -string SCcf

  # Rename operations should not stop on extension-change warnings when the user
  # is intentionally editing file names.
  run defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  # Avoid .DS_Store metadata on network shares; those files create churn in
  # shared folders and mounted project volumes.
  run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

  # Use list view by default for better scanning in source and asset folders.
  run defaults write com.apple.finder FXPreferredViewStyle -string Nlsv

  # Show ~/Library for direct access to app support files, logs, launch agents,
  # and other per-user macOS state.
  run chflags nohidden "$HOME/Library"
}

apply_dock_and_mission_control_defaults() {
  log "Dock, Mission Control, and hot corner defaults"

  # Keep the Dock compact and out of the way. The delay and animation settings
  # make auto-hide feel immediate without changing the actual app launcher.
  run defaults write com.apple.dock tilesize -int 36
  run defaults write com.apple.dock mineffect -string scale
  run defaults write com.apple.dock launchanim -bool false
  run defaults write com.apple.dock autohide -bool true
  run defaults write com.apple.dock autohide-delay -float 0
  run defaults write com.apple.dock autohide-time-modifier -float 0

  # Preserve spatial memory in Mission Control by avoiding automatic Space
  # reordering and app-based window grouping.
  run defaults write com.apple.dock mru-spaces -bool false
  run defaults write com.apple.dock expose-group-by-app -bool false

  # Hot corners: top-left Mission Control, top-right Desktop, bottom-left screen
  # saver. These are user-scoped and visible in System Settings.
  run defaults write com.apple.dock wvous-tl-corner -int 2
  run defaults write com.apple.dock wvous-tl-modifier -int 0
  run defaults write com.apple.dock wvous-tr-corner -int 4
  run defaults write com.apple.dock wvous-tr-modifier -int 0
  run defaults write com.apple.dock wvous-bl-corner -int 5
  run defaults write com.apple.dock wvous-bl-modifier -int 0
}

apply_browser_defaults() {
  log "Browser defaults"

  # Safari stores preferences in a containerized domain on current macOS
  # releases, and direct writes can be rejected. Keep Safari-specific privacy
  # and developer settings as manual browser preferences.
  run defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

  # Chrome is part of the Brewfile. Disable accidental trackpad/mouse backswipe
  # navigation, which is easy to trigger while using web apps.
  run defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
  run defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
  run defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
}

apply_utility_app_defaults() {
  log "Utility app defaults"

  # Activity Monitor opens directly to useful process information and shows live
  # CPU usage in the Dock when launched.
  run defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
  run defaults write com.apple.ActivityMonitor IconType -int 5
  run defaults write com.apple.ActivityMonitor ShowCategory -int 0
  run defaults write com.apple.ActivityMonitor SortDirection -int 0
  run defaults write com.apple.ActivityMonitor DiskGraphType -int 1
  run defaults write com.apple.ActivityMonitor NetworkGraphType -int 1
}

restart_affected_apps() {
  if [ "$restart_apps" != true ]; then
    log "Restart skipped"
    printf 'Log out and back in, or rerun with --restart-apps, for all changes to take effect.\n'
    return 0
  fi

  log "Restarting affected apps and services"
  for app in cfprefsd Dock Finder Safari SystemUIServer; do
    if [ "$dry_run" = true ]; then
      run killall "$app"
    elif pgrep -x "$app" >/dev/null 2>&1; then
      killall "$app" >/dev/null 2>&1 || true
    fi
  done
}

main() {
  apply_document_and_text_defaults
  apply_trackpad_mouse_and_sound_defaults
  apply_screenshot_and_finder_defaults
  apply_dock_and_mission_control_defaults
  apply_browser_defaults
  apply_utility_app_defaults
  restart_affected_apps
}

main "$@"
