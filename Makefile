repo_root := $$(git rev-parse --show-toplevel)
current_version := $$(head -1 ${repo_root}/debian/changelog | cut -d '(' -f2 | cut -d ')' -f1)
build := ${repo_root}/build

clean:
	git clean -dfX

npm_install:
	cd ${repo_root}/src/js; npm install; cd ${repo_root}

npm_run:
	cd ${repo_root}/src/js; set -a; . ../dev.conf; set +a; npm run start;

prepare-build: clean npm_install
	mkdir -p ${build}
	cp -r ${repo_root}/debian ${build}/
	cp -r ${repo_root}/src ${build}/
	find ${build}/src/ \( -name ".npmignore" -o  -name ".eslintrc" -o -name ".eslintrc.yml" \
		-o -name ".gitmodules" -o -name ".gitattributes" \) -delete
	cp ${repo_root}/DebianMakefile ${build}/Makefile

build-deb: prepare-build
	cd ${build}; debuild -b; cd ${repo_root}

build-src: prepare-build
	cd ${build}; debuild -S; cd ${repo_root}

new_version:
	gbp dch --debian-branch=main --git-author --distribution=focal --dch-opt=--upstream
	git add debian/
	git commit -m "version ${current_version}"
	git tag ${current_version}

publish:
	dput ppa:fertkir/tg-torrent-bot ${repo_root}/tg-torrent-bot_${current_version}_source.changes;
