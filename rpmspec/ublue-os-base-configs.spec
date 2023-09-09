Name:           ublue-os-base-configs
Packager:       ublue-os
Vendor:         ublue-os
Version:        0.1
Release:        1%{?dist}
Summary:        Base configuration files for Framework images
License:        MIT
URL:            https://github.com/bobslept/config-framework-wip

BuildArch:      noarch

Source0:        ublue-os-base-configs.tar.gz

%global sub_name %{lua:t=string.gsub(rpm.expand("%{NAME}"), "^ublue%-os%-", ""); print(t)}

%description
Adds configuration files for Universal Blue Framework images

%prep
%setup -q -c -T

%build

mkdir -p -m0755 %{buildroot}%{_datadir}/%{VENDOR}
mkdir -p -m0755 %{buildroot}%{_exec_prefix}/etc/tlp.d

tar xf %{SOURCE0} -C %{buildroot}%{_datadir}/%{VENDOR} --strip-components=1
tar xf %{SOURCE0} -C %{buildroot} --strip-components=2

%files
%dir %attr(0755,root,root) %{_datadir}/%{VENDOR}/%{sub_name}
%attr(0644,root,root) %{_datadir}/%{VENDOR}/%{sub_name}/%{_exec_prefix}/lib/systemd/system/fprintd.service
%attr(0644,root,root) %{_datadir}/%{VENDOR}/%{sub_name}/%{_exec_prefix}/etc/tlp.d/50-framework.conf
%attr(0644,root,root) %{_exec_prefix}/lib/systemd/system/fprintd.service
%attr(0644,root,root) %{_exec_prefix}/etc/tlp.d/50-framework.conf

%changelog
