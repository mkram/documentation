# Source doc tarballs
TANGRAM = https://github.com/tangrams/tangram-docs/archive/gh-pages.tar.gz
EXTRACTS = https://github.com/mapzen/metro-extracts/archive/master.tar.gz
VALHALLA = https://github.com/valhalla/valhalla-docs/archive/master.tar.gz
VALHALLA2 = https://github.com/valhalla/valhalla-docs/archive/rhonda-keys.tar.gz
#VECTOR_TILES = https://github.com/rmglennon/vector-datasource/archive/master.tar.gz
#TERRAIN_TILES = https://github.com/rmglennon/joerd/archive/master.tar.gz
SEARCH = https://github.com/pelias/pelias-doc/archive/rhonda-key-placeholders.tar.gz
ANDROID = https://github.com/rmglennon/android/archive/master.tar.gz
IOS = https://github.com/rmglennon/ios/archive/master.tar.gz
MAPZENJS = https://github.com/mapzen/mapzen.js/archive/rhonda-replace-api-keys.tar.gz
LIBPOSTAL = https://github.com/whosonfirst/go-whosonfirst-libpostal/archive/master.tar.gz
CARTOGRAPHY = https://github.com/rmglennon/cartography-docs/archive/master.tar.gz
WOF = https://github.com/whosonfirst/whosonfirst-www-api/archive/master.tar.gz

SHELL := /bin/bash # required for OSX
PYTHONPATH := packages:$(PYTHONPATH)

all: dist

clean:
	rm -rf dist theme/fragments
	rm -rf src-android src-ios src-elevation src-mapzen-js src-metro-extracts \
	       src-mobility src-search src-tangram \
	       src-libpostal src-cartography
	rm -rf dist-android dist-ios dist-elevation dist-index dist-mapzen-js \
	       dist-metro-extracts dist-mobility dist-search dist-tangram \
	       dist-libpostal dist-cartography
	rm -rf dist-android-mkdocs.yml dist-ios-mkdocs.yml dist-elevation-mkdocs.yml \
	       dist-index-mkdocs.yml dist-mapzen-js-mkdocs.yml \
	       dist-metro-extracts-mkdocs.yml dist-mobility-mkdocs.yml \
	       dist-search-mkdocs.yml dist-tangram-mkdocs.yml \
	       dist-libpostal-mkdocs.yml dist-cartography-mkdocs.yml \
	       dist-wof-mkdocs.yml dist-wof-mkdocs.yml

# Get individual sources docs
src-tangram:
	mkdir src-tangram
	curl -sL $(TANGRAM) | tar -zxv -C src-tangram --strip-components=2 tangram-docs-gh-pages/pages

src-metro-extracts:
	mkdir src-metro-extracts
	curl -sL $(EXTRACTS) | tar -zxv -C src-metro-extracts --strip-components=2 metro-extracts-master/docs

# src-vector-tiles:
#  	mkdir src-vector-tiles
# 	curl -sL $(VECTOR_TILES) | tar -zxv -C src-vector-tiles --strip-components=2 vector-datasource-master/docs
#
# src-terrain-tiles:
# 	 mkdir src-terrain-tiles
# 		curl -sL $(TERRAIN_TILES) | tar -zxv -C src-terrain-tiles --strip-components=2 joerd-master/docs

src-elevation:
	mkdir src-elevation
	curl -sL $(VALHALLA) | tar -zxv -C src-elevation --strip-components=2 valhalla-docs-master/elevation

src-mobility:
	mkdir src-mobility
	curl -sL $(VALHALLA2) | tar -zxv -C src-mobility --strip-components=1 valhalla-docs-rhonda-keys

src-search:
	mkdir src-search
	curl -sL $(SEARCH) | tar -zxv -C src-search --strip-components=1 pelias-doc-rhonda-key-placeholders

src-android:
	mkdir src-android
	curl -sL $(ANDROID) | tar -zxv -C src-android --strip-components=2 android-master/docs

src-ios:
	mkdir src-ios
	curl -sL $(IOS) | tar -zxv -C src-ios --strip-components=2 ios-master/docs

src-mapzen-js:
	mkdir src-mapzen-js
	curl -sL $(MAPZENJS) | tar -zxv -C src-mapzen-js --strip-components=2 mapzen.js-rhonda-replace-api-keys/docs

src-libpostal:
	mkdir src-libpostal
	curl -sL $(LIBPOSTAL) | tar -zxv -C src-libpostal --strip-components=2 go-whosonfirst-libpostal-master/docs

src-wof:
	mkdir src-wof
	curl -sL $(WOF) | tar -zxv -C src-wof --strip-components=2 whosonfirst-www-api-master/docs

src-cartography:
	mkdir src-cartography
	curl -sL $(CARTOGRAPHY) | tar -zxv -C src-cartography --strip-components=1 cartography-docs-master

src-overview:
	cp -r docs/overview src-overview

src-guides:
	cp -r docs/guides src-guides

# Retrieve style guide
theme/fragments:
	mkdir -p theme/fragments
	curl -sL 'https://mapzen.com/site-fragments/navbar.html' -o theme/fragments/global-nav.html
	curl -sL 'https://mapzen.com/site-fragments/footer.html' -o theme/fragments/global-footer.html

# Build Tangram, Metro Extracts, Vector Tiles, Elevation, Search, Mobility,
# Android, iOS, Mapzen JS, Terrain Tiles, Who's On First and Overview docs.
# Uses GNU Make pattern rules:
# https://www.gnu.org/software/make/manual/html_node/Pattern-Examples.html
dist-%: src-% theme/fragments
	anyconfig_cli ./config/default.yml ./config/$*.yml --merge=merge_dicts --output=./dist-$*-mkdocs.yml
	./setup-renames.py ./dist-$*-mkdocs.yml
	mkdocs build --config-file ./dist-$*-mkdocs.yml --clean
	./setup-redirects.py ./dist-$*-mkdocs.yml /documentation/$*/

# Build index page
dist-index: theme/fragments
	anyconfig_cli ./config/default.yml ./config/index.yml --merge=merge_dicts --output=./dist-index-mkdocs.yml
	mkdocs build --config-file ./dist-index-mkdocs.yml --clean
	./setup-redirects.py ./dist-index-mkdocs.yml /documentation/
	cp dist-index/index.html dist-index/next.html

dist: dist-tangram dist-metro-extracts dist-search dist-elevation dist-android dist-ios dist-mapzen-js dist-overview dist-guides dist-index dist-mobility  dist-libpostal dist-wof dist-cartography
	mkdir dist
	ln -s ../dist-tangram dist/tangram
	ln -s ../dist-metro-extracts dist/metro-extracts
	ln -s ../dist-search dist/search
	ln -s ../dist-elevation dist/elevation
	ln -s ../dist-mobility dist/mobility
	ln -s ../dist-android dist/android
	ln -s ../dist-ios dist/ios
	ln -s ../dist-mapzen-js dist/mapzen-js
	ln -s ../dist-overview dist/overview
	ln -s ../dist-guides dist/guides
	ln -s ../dist-libpostal dist/libpostal
	ln -s ../dist-cartography dist/cartography
	ln -s ../dist-wof dist/wof
	rsync -urv --ignore-existing dist-index/ dist/

serve:
	@mkdocs serve

.PHONY: all clean serve
