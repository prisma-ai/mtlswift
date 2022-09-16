prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

install: build
	sudo install ".build/release/mtlswift" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/mtlswift"

clean:
	rm -rf .build

.PHONY: build install uninstall clean