src-y += init.o
src-y += main.o
src-y += vectors.o
src-y += setup.o
src-y += uart.o
src-y += printf.o
src-y += sha256.o

include $(REPO_ROOT)/src/launch/build.mk
