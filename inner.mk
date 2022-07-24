SHELL := /bin/bash
PWD := $(shell pwd)
TOPDIR := $(PWD)

LINUX_DIR=$(TOPDIR)/repos/linux
ZFS_DIR=$(TOPDIR)/repos/zfs
OUT_DIR=$(TOPDIR)/output
ROOTFS_DIR=$(OUT_DIR)/rootfs

.PHONY: all
all: rootfs

.PHONY: shell
shell:
	$(SHELL)

.PHONY: rootfs
rootfs: linux zfs
	rm -rf "$(ROOTFS_DIR)"
	mkdir -p "$(ROOTFS_DIR)"/boot
	mkdir -p "$(ROOTFS_DIR)"/lib/modules

	$(eval release := $(shell cat "$(LINUX_DIR)/include/config/kernel.release"))

	# zfs' depmod invocation doesn't pass `--basedir`, so run it first so
	# it doesn't attempt to run it
	$(MAKE) -C "$(ZFS_DIR)" "DESTDIR=$(ROOTFS_DIR)" install

	$(MAKE) -C "$(LINUX_DIR)" modules_install zinstall dtbs_install \
		INSTALL_MOD_PATH="$(ROOTFS_DIR)" \
		INSTALL_PATH="$(ROOTFS_DIR)/boot" \
		INSTALL_DTBS_PATH="$(ROOTFS_DIR)/boot/dtbs-r4s"

	depmod --basedir "$(ROOTFS_DIR)" -ae -F "$(ROOTFS_DIR)/boot/System.map-$(release)" "$(release)"
	
	rm -f "$(ROOTFS_DIR)/lib/modules/$(release)/build" \
		"$(ROOTFS_DIR)/lib/modules/$(release)/source"
	rm -r "$(ROOTFS_DIR)/usr"

	mv "$(ROOTFS_DIR)/boot/System.map-$(release)" "$(ROOTFS_DIR)/boot/System.map-r4s"
	mv "$(ROOTFS_DIR)/boot/config-$(release)" "$(ROOTFS_DIR)/boot/config-r4s"
	mv "$(ROOTFS_DIR)/boot/vmlinuz-$(release)" "$(ROOTFS_DIR)/boot/vmlinuz-r4s"

	install -D -m644 "$(LINUX_DIR)/include/config/kernel.release" \
		"$(ROOTFS_DIR)/usr/share/kernel/$(release)/kernel.release"

	tar -czf $(OUT_DIR)/rootfs.tar.gz -C "$(ROOTFS_DIR)" .

$(LINUX_DIR)/.config: $(TOPDIR)/r4s_defconfig
	echo "-1-r4s" > "$(LINUX_DIR)/localversion-alpine"
	cp "$<" "$@"
	$(MAKE) -C "$(LINUX_DIR)" olddefconfig

.PHONY: linux
linux: $(LINUX_DIR)/.config
	$(MAKE) -C "$(LINUX_DIR)" savedefconfig
	$(MAKE) -C "$(LINUX_DIR)"
	
$(ZFS_DIR)/configure: linux
	cd $(ZFS_DIR) && ./autogen.sh

$(ZFS_DIR)/Makefile: $(ZFS_DIR)/configure
	cd $(ZFS_DIR) && ./configure --host=aarch64-linux-gnu --with-config=kernel "--with-linux=$(LINUX_DIR)"

.PHONY: zfs
zfs: $(ZFS_DIR)/Makefile
	$(MAKE) -C "$(ZFS_DIR)"
