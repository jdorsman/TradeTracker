# Contributing guidelines

## .env.local file

The [.env.local.example](.env.local.example) file can copied to `.env.local`.
It holds two variables:

- `WOW_PATH` - The path to your local WoW installation (root directory where the Launcher .exe sits)
- `WOW_FLAVOR` - The "flavor" of WoW you want to target. This is the name that the underscored sub-directories in your `WOW_PATH` have (e.g. `classic_era` or `anniversary`)

## Makefile

Development related tasks can be done through the [Makefile](Makefile).
It currently has the following targets:

- `make libs` - Install the AddOn dependencies (`LibStub` and `Ace3` libraries)
- `make install` - Install the addon to the WoW AddOns directory
- `make uninstall` - Remove the addon from the WoW AddOns directory
- `make clean-install` - Uninstall and re-install the addon (to start fresh). This is equivalent to doing `make uninstall`, followed by a `make install`.

## Development dependencies

The [Makefile](Makefile) depends on certain tools being present in your development environment (should be present on most Linux distros and Mac OS):

- [wget](https://www.gnu.org/software/wget/)
- [unzip](https://infozip.sourceforge.net/UnZip.html)
- [libxml2](https://gnome.pages.gitlab.gnome.org/libxml2/html/index.html)
- [xmllint](https://gnome.pages.gitlab.gnome.org/libxml2/xmllint.html) (if not included with your `libxml2` package, it's probably in the `libxml2-utils` package)
