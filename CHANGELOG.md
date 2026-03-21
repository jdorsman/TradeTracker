# TradeTracker Changelog

## v1.3.0

- Add profile support, allowing you to configure different settings (e.g. different highlights/ignores for different characters).
- Fixed description for trigger words. Matches are actually partial, not word-based.

## v1.2.0

- Fixed a bug where highlight and ignore keywords were not properly applied.
- Added "Trigger Words" to the "Chat Settings" section, allowing players to define their own categorization triggers (e.g. "WTB" for Buy or "WTS" for Sell).

## v1.1.0

- Fixed bug where duplicate messages would not get properly updated.
- Reworked the options panel to be split into different windows.
- Added new highlight feature that highlights configured keywords in the GUI and optionally outputs them to the main chat window.
- Added new ignore feature that ignores trade messages with configured keywords.
For example, if you are not interested in people buying/selling boosting services, you can ignore any message containing the word "boost".
- Added "LF " as a matching term for the Buy tab as this is often used by people looking to buy certain items or services (e.g. "LF enchanter").
This can lead to some false positives when people are looking for more players for their dungeon/raid (e.g. "LF tank"),
but you can use the ignore feature to filter those out (by adding "LF tank" or "LF heal" to your ignore list).

## v1.0.3

- Add support for WoW Classic (Vanilla / Classic Era)
- Add support for Mists of Pandaria Classic
- When a duplicate message is found, its timestamp is updated, rather than the newer message being ignored.
This allows for items/services that are still being actively offered to not disappear to the bottom and appear outdated.

## v1.0.2

- Add Options button to the main GUI for easier access to the options panel

## v1.0.1

_This version was mistagged and not officially published._

## v1.0.0

- Initial release
