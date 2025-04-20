override CFLAGS+=-Wall -g
OBJS=reredirect.o ptrace.o attach.o

# Note that because of how Make works, this can be overriden from the
# command-line.
#
# e.g. install to /usr with `make PREFIX=/usr`
PREFIX=/usr/local

all: reredirect

.PHONY: .last_version
# Get version from git
GIT_VERSION := $(shell git describe --abbrev=4 --dirty --always --tags 2>/dev/null || echo "0.1-unknown")
# version.h:
# 	@echo "#define REREDIRECT_VERSION \"$(GIT_VERSION)\"" > $@

version.h: .last_version
	@if [ "$(GIT_VERSION)" != "`cat $^ 2>/dev/null`" ]; then \
		echo "#define REREDIRECT_VERSION \"$(GIT_VERSION)\"" > $@; \
		echo "$(GIT_VERSION)" > $^; \
		echo "Version updated to $(GIT_VERSION)"; \
	fi

reredirect: $(OBJS)

attach.o: reredirect.h ptrace.h
reredirect.o: reredirect.h version.h
ptrace.o: ptrace.h $(wildcard arch/*.h)

clean:
	rm -f reredirect $(OBJS)

install: reredirect relink
	install -d -m 755 $(DESTDIR)$(PREFIX)/bin/
	install -m 755 reredirect $(DESTDIR)$(PREFIX)/bin/reredirect
	install -m 755 relink $(DESTDIR)$(PREFIX)/bin/relink
	install -d -m 755 $(DESTDIR)$(PREFIX)/share/man/man1
	install -m 644 reredirect.1 $(DESTDIR)$(PREFIX)/share/man/man1/reredirect.1
