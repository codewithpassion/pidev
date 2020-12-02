
processor := $(shell uname -p)


all:
	@if test "$(processor)" = "x86_64" ; then \
	  ./build.sh --platform=amd64; \
	else \
	  echo "Don't know how to build for $(processor)" 1>&2; \
	fi
