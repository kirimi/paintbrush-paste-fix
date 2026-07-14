.PHONY: test build app release clean

test:
	swift test --disable-sandbox

build:
	swift build -c release --disable-sandbox

app:
	sh scripts/package-app.sh

release:
	sh scripts/package-release.sh

clean:
	swift package clean
	rm -rf dist
