MINIFY = lua lua-minify/minify.lua minify

LUABUNDLER = npx luabundler bundle -p libs/?.lua -p libs/ar-widgets/? -i
LUABUNDLER = npx luabundler bundle -p libs/?.lua -p dist/libs/?.lua -i

# Sadly, but "lua-minify" can't handle some Lua code
# Luamin more powerful but too slow to run
LUAMIN = npx luamin -f

ECHO_REPO = echo --- $$(git remote get-url origin) $$(git rev-parse HEAD)

all: tstl minify bundle

tstl:
	npx tstl

minify: minify-inkgz minify-crc32 minify-crc32_2 minify-witchery-cauldron.lua-autocraft minify-geotrack minify-build-crop-plant minify-ae2-level minify-inklog minify-netrunner minify-ae2-tc-infuser minify-ar-remote-display

bundle: tstl bundle-ar-calibrate bundle-ar-remote-display bundle-ar-tps bundle-ar-reboot-button bundle-ar-tps-ts

bundle-ar-reboot-button:
	mkdir -p build/bin
	mkdir -p dist/bin
	$(LUABUNDLER) -o build/bin/ar-reboot-button-bundled.lua bin/ar-reboot-button.lua
	($(ECHO_REPO); $(LUAMIN) build/bin/ar-reboot-button-bundled.lua) > dist/bin/ar-reboot-button-bundled.lua

bundle-ar-tps-ts: tstl
	mkdir -p build/bin
	mkdir -p dist/bin
	$(LUABUNDLER) -o build/bin/ar-tps-ts-bundled.lua dist/bin//ar-tps-ts.lua
	($(ECHO_REPO); $(LUAMIN) build/bin/ar-tps-ts-bundled.lua) > dist/bin/ar-tps-ts-bundled.lua

bundle-ar-tps:
	mkdir -p build/bin
	mkdir -p dist/bin
	$(LUABUNDLER) -o build/bin/ar-tps-bundled.lua bin/ar-tps.lua
	($(ECHO_REPO); $(LUAMIN) build/bin/ar-tps-bundled.lua) > dist/bin/ar-tps-bundled.lua

bundle-ar-calibrate:
	mkdir -p build/bin
	mkdir -p dist/bin
	$(LUABUNDLER) -o build/bin/ar-calibrate-bundled.lua bin/ar-calibrate.lua
	($(ECHO_REPO); $(LUAMIN) build/bin/ar-calibrate-bundled.lua) > dist/bin/ar-calibrate-bundled.lua

bundle-ar-remote-display:
	mkdir -p build/bin
	mkdir -p dist/bin
	$(LUABUNDLER) -o build/bin/ar-remote-display-bundled.lua bin/ar-remote-display.lua
	($(ECHO_REPO); $(LUAMIN) build/bin/ar-remote-display-bundled.lua) > dist/bin/ar-remote-display-bundled.lua

minify-ar-remote-display:
	mkdir -p dist/bin
	($(ECHO_REPO); $(LUAMIN) bin/ar-remote-display.lua) > dist/bin/ar-remote-display.lua

minify-netrunner:
	mkdir -p dist/bin
	($(ECHO_REPO); $(MINIFY) bin/netrunner.lua) > dist/bin/netrunner.lua

minify-ae2-tc-infuser:
	mkdir -p dist/bin
	($(ECHO_REPO); $(MINIFY) bin/ae2-tc-infuser.lua) > dist/bin/ae2-tc-infuser.lua

minify-ae2-level:
	mkdir -p dist/bin
	($(ECHO_REPO); $(LUAMIN) bin/ae2-level.lua) > dist/bin/ae2-level.lua

minify-build-crop-plant:
	mkdir -p dist/bin
	($(ECHO_REPO); $(MINIFY) bin/build-crop-plant.lua) > dist/bin/build-crop-plant.lua

minify-witchery-cauldron.lua-autocraft:
	mkdir -p dist/ae2-autocraft-providers
	($(ECHO_REPO); $(MINIFY) ae2-autocraft-providers/witchery-cauldron.lua) > dist/ae2-autocraft-providers/witchery-cauldron.lua

minify-inkgz:
	mkdir -p dist/libs
	($(ECHO_REPO); $(MINIFY) libs/inkgz.lua) > dist/libs/inkgz.lua

minify-crc32:
	mkdir -p dist/libs
	($(ECHO_REPO); $(MINIFY) libs/crc32.lua) > dist/libs/crc32.lua

minify-inklog:
	mkdir -p dist/libs
	($(ECHO_REPO); $(LUAMIN) libs/inklog.lua) > dist/libs/inklog.lua

minify-crc32_2:
	mkdir -p dist/libs
	($(ECHO_REPO); $(MINIFY) libs/crc32_2.lua) > dist/libs/crc32_2.lua

minify-geotrack:
	mkdir -p dist/libs
	mkdir -p dist/bin
	($(ECHO_REPO); $(MINIFY) libs/geotrack.lua) > dist/libs/geotrack.lua
	($(ECHO_REPO); $(MINIFY) bin/geotrack.lua) > dist/bin/geotrack.lua

clean:
	rm -rf dist
	