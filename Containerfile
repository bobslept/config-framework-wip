FROM registry.fedoraproject.org/fedora:latest AS builder

RUN dnf install --disablerepo='*' --enablerepo='fedora,updates' --setopt install_weak_deps=0 --nodocs --assumeyes rpm-build systemd-rpm-macros

# Copy base config files
COPY files/usr/etc/systemd /tmp/ublue-os/base-configs/usr/etc/systemd
COPY files/usr/etc/tlp.d /tmp/ublue-os/base-configs/usr/etc/tlp.d

RUN mkdir -p /tmp/ublue-os/rpmbuild/SOURCES/

# Create archive of base configs
RUN tar cf /tmp/ublue-os/rpmbuild/SOURCES/ublue-os-base-configs.tar.gz -C /tmp ublue-os/base-configs

# Copy spec files
COPY rpmspec/*.spec /tmp/ublue-os

# Build rpm from spec
RUN rpmbuild -ba \
    --define '_topdir /tmp/ublue-os/rpmbuild' \
    --define '%_tmppath %{_topdir}/tmp' \
    /tmp/ublue-os/*.spec

# Create dir to store files and rpms
RUN mkdir /tmp/ublue-os/{files,rpms}

# Dump a file list for each RPM for easier consumption
RUN \
    for RPM in /tmp/ublue-os/rpmbuild/RPMS/*/*.rpm; do \
        NAME="$(rpm -q $RPM --queryformat='%{NAME}')"; \
        mkdir "/tmp/ublue-os/files/${NAME}"; \
        rpm2cpio "${RPM}" | cpio -idmv --directory "/tmp/ublue-os/files/${NAME}"; \
        cp "${RPM}" "/tmp/ublue-os/rpms/$(rpm -q "${RPM}" --queryformat='%{NAME}.%{ARCH}.rpm')"; \
    done

FROM scratch

# Copy build RPMs
COPY --from=builder /tmp/ublue-os/rpms /rpms
# Copy dumped RPM content
COPY --from=builder /tmp/ublue-os/files /files
