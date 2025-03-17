MINIFY = lua lua-minify/minify.lua minify
ECHO_REPO = echo --- $$(git remote get-url origin)

all: minify-inkgz minify-crc32 minify-crc32_2 minify-witchery-cauldron.lua-autocraft

minify-witchery-cauldron.lua-autocraft:
	mkdir -p dist/ae2-autocraft-providers
	($(ECHO_REPO); $(MINIFY) ae2-autocraft-providers/witchery-cauldron.lua) > dist/ae2-autocraft-providers/witchery-cauldron.lua

minify-inkgz:
	mkdir -p dist/libs
	($(ECHO_REPO); $(MINIFY) libs/inkgz.lua) > dist/libs/inkgz.lua

minify-crc32:
	mkdir -p dist/libs
	($(ECHO_REPO); $(MINIFY) libs/crc32.lua) > dist/libs/crc32.lua

minify-crc32_2:
	mkdir -p dist/libs
	($(ECHO_REPO); $(MINIFY) libs/crc32_2.lua) > dist/libs/crc32_2.lua

clean:
	rm -rf dist
	