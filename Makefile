MINIFY = lua lua-minify/minify.lua minify
ECHO_REPO = echo --- $$(git remote get-url origin)

all: minify-inkgz minify-crc32 minify-crc32_2

minify-inkgz:
	mkdir -p dist/utils
	($(ECHO_REPO); $(MINIFY) utils/inkgz.lua) > dist/utils/inkgz.lua

minify-crc32:
	mkdir -p dist/utils
	($(ECHO_REPO); $(MINIFY) utils/crc32.lua) > dist/utils/crc32.lua

minify-crc32_2:
	mkdir -p dist/utils
	($(ECHO_REPO); $(MINIFY) utils/crc32_2.lua) > dist/utils/crc32_2.lua

clean:
	rm -rf dist
	