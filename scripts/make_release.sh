#!/bin/sh
THISDIR="$(realpath $(dirname "$_"))"
set -e # Abort on any error
cd "$THISDIR"

. "$THISDIR/release_config.inc"

declare -A MCHPTARBALLS
declare -A TOPLEVELDIRS
MCHPTARBALLS["v1.23"]='xc16-v1.23-src.zip'
TOPLEVELDIRS["v1.23"]='v1.23_src_archive'
MCHPTARBALLS["v1.24"]='xc16-v1.24-src.zip'
TOPLEVELDIRS["v1.24"]='v1.24.src'
MCHPTARBALLS["v1.25"]='v1.25.src.zip'
TOPLEVELDIRS["v1.25"]='v1.25.src'

mkdir -p rpmbuild/{SOURCES,SPECS}
SPECFILE=rpmbuild/SPECS/xc16plusplus-release.spec

( cd .. && git archive HEAD -9 --prefix "xc16plusplus-$RELEASEVER-source/" -o "$THISDIR/rpmbuild/SOURCES/xc16plusplus-$RELEASEVER-source.zip" )

function auxfiles_cp()
{
	echo "cp -vt $2 -r $1/LICENSE-GPL3 $1/LICENSE-UNLICENSE $1/README.md" \
		"$1/example-project" "$1/support-files"
	echo "mv $2/LICENSE-GPL3 $2/LICENSE-GPL3.txt"
	echo "mv $2/LICENSE-UNLICENSE $2/LICENSE-UNLICENSE.txt"
	echo "mv $2/README.md $2/README.txt"
	echo "mv $2/example-project/README.md $2/example-project/README.txt"
}

function patch_makefile()
{
	XC16VER=$1

	if [ "$2" == "linux" ];
	then
		OSFOLDERPATTERN=opt
	elif [ "$2" == "osx" ];
	then
		OSFOLDERPATTERN=Applications
	elif [ "$2" == "win32" ];
	then
		OSFOLDERPATTERN=Program
	fi

	MAKEFILE=$3

	# Set XC16 version in the XC16DIR path, uncomment the line corresponding
	# to the target OS
	echo sed -e "'"'s,^#\?\(XC16DIR :=.*[/\\]\)v[0-9]\.[0-9]*,#\1'$XC16VER','"'" -e "'"'s,#\(XC16DIR :=.*'$OSFOLDERPATTERN'\),\1,'"'" -i "\"$MAKEFILE\""
}

function auxfiles_unix2dos()
{
	echo "unix2dos $1/* $1/example-project/* $1/support-files/*"
}

function auxfiles_list()
{
	echo "/$1/LICENSE-GPL3.txt"
	echo "/$1/LICENSE-UNLICENSE.txt"
	echo "/$1/README.txt"
	echo "/$1/example-project/*"
	echo "/$1/support-files/*"
}

function symlinks_ln()
{
	echo "ln -s xc16-cc1 $1/bin/xc16-cc1plus"
	echo "ln -s xc16-gcc $1/bin/xc16-g++"
	echo "ln -s coff-pa $1/bin/bin/coff-paplus"
	echo "ln -s elf-pa $1/bin/bin/elf-paplus"
}

function symlinks_list()
{
	echo "/$1/bin/xc16-cc1plus"
	echo "/$1/bin/xc16-g++"
	echo "/$1/bin/bin/coff-paplus"
	echo "/$1/bin/bin/elf-paplus"
}

function gen_win32_cmdscript()
{
	XC16VER=$1
	INPUTFILE=$2
	OUTPUTFILE=$3

	# Set XC16 version in the suggested path
	echo sed "'"'s,\(C:\\Program.*\)\\v[0-9]\.[0-9]*\\\(bin\),\1\\'$XC16VER'\\\2,'"'" "\"$2\" > \"$3\""
}

echo '
Name: xc16plusplus-release
Version: '$RELEASEVER'
Release: 1
License: TempPackage
Summary: TempPackage

Source: xc16plusplus-%{version}-source.zip
BuildArch: i686
BuildRequires: bison flex m4' > $SPECFILE
if $ENABLE_WIN32; then
	echo 'BuildRequires: dos2unix mingw32-gcc' >> $SPECFILE
fi
if $ENABLE_OSX; then
	echo 'BuildRequires: osxcross-apple-darwin9-gcc' >> $SPECFILE
fi

I=0; for XC16VER in $XC16VERSIONS; do I=$(($I+1));
	TARBALLNAME="${MCHPTARBALLS[$XC16VER]}"
	cp -l "$TARBALLDIR/$TARBALLNAME" rpmbuild/SOURCES/
	cp -l "$THISDIR/../$XC16VER"/xc16plusplus_*.patch rpmbuild/SOURCES/patch-$XC16VER
	echo "Source$I: $TARBALLNAME" >> $SPECFILE
	echo "Patch$I: patch-$XC16VER" >> $SPECFILE
done

echo '%define _use_internal_dependency_generator 0
%define __os_install_post %{nil}
%define __find_provides %{nil}
%define __find_requires %{nil}
%define debug_package %{nil}
AutoReqProv: 0

%description
TempPackage

%prep
%setup -n xc16plusplus-%{version}-source' >> $SPECFILE
I=0; for XC16VER in $XC16VERSIONS; do I=$(($I+1));
	TOPLEVELDIR="${TOPLEVELDIRS[$XC16VER]}"
	echo "%setup -T -b $I -n $TOPLEVELDIR" >> $SPECFILE
	echo "%patch -p1 -P $I" >> $SPECFILE
done
echo '
%build' >> $SPECFILE
I=0; for XC16VER in $XC16VERSIONS; do I=$(($I+1));
	TOPLEVELDIR="${TOPLEVELDIRS[$XC16VER]}"
	echo "cd ../$TOPLEVELDIR" >> $SPECFILE
	echo 'chmod +x xc16plusplus_only.sh' >> $SPECFILE
	if $ENABLE_LINUX; then
		echo './xc16plusplus_only.sh linux' >> $SPECFILE
	fi
	if $ENABLE_WIN32; then
		echo './xc16plusplus_only.sh win32' >> $SPECFILE
	fi
	if $ENABLE_OSX; then
		echo "PATH=\"$OSXCROSS_BINPATH:\$PATH\" ./xc16plusplus_only.sh osx" >> $SPECFILE
	fi
done
echo '

%install' >> $SPECFILE
echo "cp -rv ../xc16plusplus-$RELEASEVER-source %{buildroot}/" >> $SPECFILE
I=0; for XC16VER in $XC16VERSIONS; do I=$(($I+1));
	TOPLEVELDIR="${TOPLEVELDIRS[$XC16VER]}"
	echo "cd ../$TOPLEVELDIR" >> $SPECFILE
	if $ENABLE_LINUX; then
		echo 'cp -rv install-linux "%{buildroot}"/'xc16plusplus-$RELEASEVER-linux-$XC16VER >> $SPECFILE
		auxfiles_cp "../xc16plusplus-%{version}-source" "%{buildroot}/xc16plusplus-$RELEASEVER-linux-$XC16VER" >> $SPECFILE
		patch_makefile $XC16VER linux "%{buildroot}/xc16plusplus-$RELEASEVER-linux-$XC16VER/example-project/Makefile" >> $SPECFILE
		symlinks_ln "%{buildroot}/xc16plusplus-$RELEASEVER-linux-$XC16VER" >> $SPECFILE
	fi
	if $ENABLE_WIN32; then
		echo 'cp -rv install-win32 "%{buildroot}"/'xc16plusplus-$RELEASEVER-win32-$XC16VER >> $SPECFILE
		auxfiles_cp "../xc16plusplus-%{version}-source" "%{buildroot}/xc16plusplus-$RELEASEVER-win32-$XC16VER" >> $SPECFILE
		patch_makefile $XC16VER win32 "%{buildroot}/xc16plusplus-$RELEASEVER-win32-$XC16VER/example-project/Makefile" >> $SPECFILE
		auxfiles_unix2dos "%{buildroot}/xc16plusplus-$RELEASEVER-win32-$XC16VER" >> $SPECFILE
		gen_win32_cmdscript $XC16VER "../xc16plusplus-%{version}-source/scripts/create_xc16plusplus_symlinks.cmd" \
			"%{buildroot}/xc16plusplus-$RELEASEVER-win32-$XC16VER/bin/create_xc16plusplus_symlinks.cmd" >> $SPECFILE
	fi
	if $ENABLE_OSX; then
		echo 'cp -rv install-osx "%{buildroot}"/'xc16plusplus-$RELEASEVER-osx-$XC16VER >> $SPECFILE
		auxfiles_cp "../xc16plusplus-%{version}-source" "%{buildroot}/xc16plusplus-$RELEASEVER-osx-$XC16VER" >> $SPECFILE
		patch_makefile $XC16VER osx "%{buildroot}/xc16plusplus-$RELEASEVER-osx-$XC16VER/example-project/Makefile" >> $SPECFILE
		symlinks_ln "%{buildroot}/xc16plusplus-$RELEASEVER-osx-$XC16VER" >> $SPECFILE
	fi
done
echo '
%files
%defattr(-,root,root)' >> $SPECFILE
echo "/xc16plusplus-$RELEASEVER-source" >> $SPECFILE
I=0; for XC16VER in $XC16VERSIONS; do I=$(($I+1));
	TOPLEVELDIR="${TOPLEVELDIRS[$XC16VER]}"
	if $ENABLE_LINUX; then
		auxfiles_list "xc16plusplus-$RELEASEVER-linux-$XC16VER" >> $SPECFILE
		symlinks_list "xc16plusplus-$RELEASEVER-linux-$XC16VER" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-linux-$XC16VER/bin/bin/coff-cc1plus" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-linux-$XC16VER/bin/bin/coff-g++" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-linux-$XC16VER/bin/bin/elf-cc1plus" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-linux-$XC16VER/bin/bin/elf-g++" >> $SPECFILE
	fi
	if $ENABLE_WIN32; then
		auxfiles_list "xc16plusplus-$RELEASEVER-win32-$XC16VER" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-win32-$XC16VER/bin/create_xc16plusplus_symlinks.cmd" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-win32-$XC16VER/bin/bin/coff-cc1plus.exe" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-win32-$XC16VER/bin/bin/coff-g++.exe" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-win32-$XC16VER/bin/bin/elf-cc1plus.exe" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-win32-$XC16VER/bin/bin/elf-g++.exe" >> $SPECFILE
	fi
	if $ENABLE_OSX; then
		auxfiles_list "xc16plusplus-$RELEASEVER-osx-$XC16VER" >> $SPECFILE
		symlinks_list "xc16plusplus-$RELEASEVER-osx-$XC16VER" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-osx-$XC16VER/bin/bin/coff-cc1plus" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-osx-$XC16VER/bin/bin/coff-g++" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-osx-$XC16VER/bin/bin/elf-cc1plus" >> $SPECFILE
		echo "/xc16plusplus-$RELEASEVER-osx-$XC16VER/bin/bin/elf-g++" >> $SPECFILE
	fi
done
echo '
%define date %(echo \`LC_ALL="C" date +"%a %b %d %Y"\`)
%changelog
* %{date} TempName <tempname@example.org>
- Packaged
' >> $SPECFILE

i386 rpmbuild --define "_topdir $PWD/rpmbuild" "$SPECFILE" -bs

mock -r $MOCKCONFIG --init
mock -r $MOCKCONFIG --install "$OSXCROSS_BASE" "$OSXCROSS_GCC"
mock -r $MOCKCONFIG --no-clean --resultdir result/ $PWD/rpmbuild/SRPMS/xc16plusplus-release-v1-1.src.rpm

cd result/
rm -rf xc16plusplus-release-v1-1.i686
rpmdev-extract xc16plusplus-release-v1-1.i686.rpm
cd xc16plusplus-release-v1-1.i686
for DIR in *;
do
	case "$DIR" in
		*source* | *win32*)
			( cd "$DIR" && zip -r9X "$THISDIR/$DIR.zip" * )
			;;
		*)
			GZIP=-9m tar zcvf "$THISDIR/$DIR.tar.gz" \
				--format=pax --mode='g-w,o-w' \
				--owner=0 --group=0 "$DIR"
			;;
	esac
done
