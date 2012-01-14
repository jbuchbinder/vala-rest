### VALA-REST
# vim: tabstop=4:softtabstop=4:shiftwidth=4:noexpandtab

PKGS= \
	--pkg gee-1.0 \
	--pkg libsoup-2.4 \
	--pkg glib-2.0 \
	--pkg posix

CFLAGS= \
	`pkg-config gee-1.0 --cflags` \
	`pkg-config libsoup-2.4 --cflags` \
	`pkg-config glib-2.0 --cflags`

SOURCES= \
	ValaRest.vala

all: clean libvalarest.so

clean:
	rm -f libvalarest.so ValaRest.c ValaRest.h

libvalarest.so:
	@echo "Building $@ ... "
	@valac -H ValaRest.h -C $(PKGS) $(SOURCES)
	gcc -o $@ -c ValaRest.c $(CFLAGS)

