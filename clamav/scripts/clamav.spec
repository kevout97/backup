# Variables creadas
%define realname clamav
%define realver  0.101.2
%define srcext   tar.gz
%define clam_user  clamav
%define clam_group clamav

# Informacion Global del repositorio
Name:          clamav
Version:       0.101.2
Release:       %{?dist}
License:       GPL-2.0
Group:         Productivity/Security
URL:           http://www.clamav.net/
Summary:       Clam AntiVirus is an open source anti-virus toolkit
BuildArch:     noarch

# Paquetes requeridos por ClamAV para poder ser compilado
BuildRequires:      openssl
BuildRequires:      openssl-devel
BuildRequires:      libcurl-devel
BuildRequires:      zlib
BuildRequires:      zlib-devel
BuildRequires:      libpng-devel
BuildRequires:      libxml2-devel
BuildRequires:      json-c-devel
BuildRequires:      bzip2-devel
BuildRequires:      pcre2-devel
BuildRequires:      ncurses-devel
BuildRequires:      valgrind
BuildRequires:      check
Requires(pre):      %_bindir/awk
Requires(pre):      %_sbindir/groupadd
Requires(pre):      %_sbindir/useradd
Requires(pre):      %_sbindir/usermod
Requires(pre):      /bin/sed
Requires(pre):      /bin/tar
Provides:           clamd = 0.101.2
Obsoletes:          clamd < 0.101.2

# Archivos requeridos para la creacion del RPM
Source0:       http://www.clamav.net/downloads/production/%name-%version.tar.gz


# Descripcion del paquete
%description
Clam AntiVirus is an open source (GPL) anti-virus toolkit for UNIX,
designed especially for e-mail scanning on mail gateways. It provides
a number of utilities including a flexible and scalable multi-threaded
daemon, a command line scanner and advanced tool for automatic database
updates. The core of the package is an anti-virus engine available in a
form of shared library.

# Subpaquetes que seran creados, acompañados de una breve descripcion de lo que consiste cada uno
%package -n libclamav9
Summary:        ClamAV antivirus engine runtime
Group:          System/Libraries

%description -n libclamav9
ClamAV is an antivirus engine designed for detecting trojans,
viruses, malware and other malicious threats.

%if ! 0%{?system_mspack}
%package -n libclammspack0
Group:         System/Libraries
License:       LGPL-2.1
Summary:       Library for handling Microsoft compression formats

%description -n libclammspack0
The purpose of libmspack is to provide compressors and decompressors,
archivers and dearchivers for Microsoft compression formats: CAB, CHM, WIM,
LIT, HLP, KWAJ and SZDD. It is also designed to be easily embeddable,
stable, robust and resource-efficient.

%files -n libclammspack0
%defattr(-,root,root)
%{_libdir}/libclammspack.so.0*

%post   -n libclammspack0 -p /sbin/ldconfig
%postun -n libclammspack0 -p /sbin/ldconfig
%endif

%package devel
Summary:        Development files for libclamav, an antivirus engine
Group:          Development/Libraries/C and C++
Requires:       libclamav9 = %version

%description devel
ClamAV is an antivirus engine designed for detecting trojans,
viruses, malware and other malicious threats.

This subpackage contains header files for developing applications
that want to make use of libclamav.

# %prep: Sección en la que se colocan los comandos para preparar la construccion del software
%prep
# La siguiente instruccion indica que de va a descomprimir el tar.gz que colocamos en el directorio SOURCE,
# enseguida ingresara al directorio creado despues descomprimir el tar.gz, en nuestro caso clamav-0.101.2
%setup -q

# %build: Sección en la que se colocan los comandos para compilar el software
%build
# La siguiente instrucción es el equivalente a ejecutar ./configure <flag 1> <flag 2> etc. que permite una configuracion
# previa al compilado del sistema
%configure \
 --sysconfdir=/etc \
 --with-systemdsystemunitdir=no \
 --disable-static \
 --disable-rpath \
 --enable-id-check \
 --enable-yp-check \
 --disable-llvm \
 --with-system-llvm \
 --with-llvm-linking=dynamic \
%if 0%{?system_mspack}
 --with-system-libmspack \
%endif
 CFLAGS="%{optflags} %{?gcc_lto}" \
 CXXFLAGS="%{optflags} %{?gcc_lto} -fno-rtti -D_GLIBCXX_USE_CXX11_ABI=0" \
 LDFLAGS="%{!?suse_version:-ltinfo }-Wl,--as-needed -Wl,--strip-all %{?gcc_lto}"

# Etapa de compilación
%{__make} %{?_smp_mflags} V=1

# Sección en la que se colocan los comandos parainstalar  el software
%install
# Con el siguiente comando indicamos que los archivos compilados se guarden en %{buildroot} (~/rpmbuild/BUILDROOT)
# lugar donde se ubican los archivos a ser empaquetados
#%{__make} install DESTDIR=%{buildroot}
%make_install

# Modificamos los archivos de configuracion de CalmAV
sed -r 's/^(Example)/#\1/' %{buildroot}%{_sysconfdir}/freshclam.conf.sample > %{buildroot}%{_sysconfdir}/freshclam.conf
mv %{buildroot}%{_sysconfdir}/clamd.conf.sample %{buildroot}%{_sysconfdir}/clamd.conf


# Creacion de directorios
mkdir -p %{buildroot}/usr/share/clamav

# Limpieza de directorio donde se realizo el compilado
%clean
[ "%{buildroot}" != "/" ] && %{__rm} -rf %{buildroot}


# Archivos a ser instalados en el host donde se alojara el Sistema
%files
# Con la siguiente directiva establecemos que los permisos y atributos con los que se crean los
# archivos esta bien, de igual forma asignamos el usuario y grupo por defecto de dichos archivos o directorios
%defattr(-,root,root)
%dir %attr(0755, clamav, clamav) /usr/share/clamav
%doc COPYING* docs/html
%{_bindir}/*
%{_sbindir}/clamd
%config(noreplace) %attr(0644, root, root) %{_sysconfdir}/*.conf
%doc %{_mandir}/man1/*
%doc %{_mandir}/man5/*
%doc %{_mandir}/man8/*
%exclude %{_bindir}/clamav-config

# Shared library(-es)
%files -n libclamav9
%defattr(-,root,root)
%{_libdir}/libclamav.so.9*
%{_libdir}/libclamunrar.so.9*
%{_libdir}/libclamunrar_iface.so.9*

# Development stuff
%files devel
%defattr(-,root,root)
%{_bindir}/clamav-config
%{_libdir}/pkgconfig/*.pc
%{_includedir}/clamav.h
%{_includedir}/clamav-types.h
%{_libdir}/*.so
%exclude %{_libdir}/*.la

# Creación de grupos
%pre
/usr/sbin/groupadd -r %{clam_group} 2> /dev/null || :

/usr/sbin/useradd -r -g %{clam_group} -s /bin/false -c "ClamAV user" \
  -d /var/lib/clamav %{clam_user} 2> /dev/null || :