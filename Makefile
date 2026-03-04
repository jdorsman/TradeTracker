include .env.local

ACE3_REVISION=r1390
ACE3_DOWNLOAD_LINK=https://www.wowace.com/projects/ace3/files/7571919/download

ADDON_PATH=$(WOW_PATH)/$(if $(WOW_FLAVOR),_$(WOW_FLAVOR)_/,)Interface/AddOns/TradeTracker

libs: # Install dependencies
	@rm -rf Libs/
	@mkdir -p build/

	@echo "Downloading Ace3..."
	@wget -q -O build/Ace3-Release-$(ACE3_REVISION).zip $(ACE3_DOWNLOAD_LINK)

	@echo "Extracting Ace3..."
	@unzip -q -o build/Ace3-Release-$(ACE3_REVISION).zip -d build/
	@mkdir -p Libs/

	@echo "Installing Ace3 libraries..."
	@for name in $(shell xmllint --xpath "//Ui/*/@file" embeds.xml | tr '\\' ' ' | awk '{print $$2}'); do \
		echo "  Installing $$name..."; \
		mv build/Ace3/$$name Libs/; \
	done

	@echo "Cleaning up..."
	@rm -rf build/
	@echo "Dependencies installed."

install: # Install the addon to the WoW AddOns directory
	@echo "Installing addon..."
	@mkdir -p $(ADDON_PATH)
	@cp -r * $(ADDON_PATH)
	@echo "Installation complete."

uninstall: # Remove the addon from the WoW AddOns directory
	@echo "Uninstalling addon..."
	@rm -rf $(ADDON_PATH)
	@echo "Uninstallation complete."

clean-install: uninstall install
