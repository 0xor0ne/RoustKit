KDIR ?= $(PWD)/../kernel/build

.PHONY: default

default: rust_oot.ko

rust_oot.ko:
	$(MAKE) -C $(KDIR) M=$$PWD LLVM=1 ARCH=x86_64

.PHONY: clean
clean:
	rm -f Module.symvers
	rm -f modules.order
	rm -f *.ko
	rm -f *.o
	rm -f *.mod
	rm -f *.mod.c
	rm -f *.mod.o
	rm -f .*.cmd
