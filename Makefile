MINIFY = lua lua-minify/minify.lua minify

# Sadly, but "lua-minify" can't handle some Lua code
# Luamin more powerful but too slow to run
LUAMIN = npx luamin -f

ECHO_REPO = echo --- $$(git remote get-url origin)

all: minify-inkgz minify-crc32 minify-crc32_2 minify-witchery-cauldron.lua-autocraft minify-geotrack minify-build-crop-plant minify-ae2-level minify-inklog minify-netrunner

minify-netrunner:
	mkdir -p dist/bin
	($(ECHO_REPO); $(MINIFY) bin/netrunner.lua) > dist/bin/netrunner.lua

minify-ae2-level:
	mkdir -p dist/bin
	($(ECHO_REPO); $(MINIFY) bin/ae2-level.lua) > dist/bin/ae2-level.lua

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
	