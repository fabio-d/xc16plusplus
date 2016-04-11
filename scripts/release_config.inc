# xc16++ revision to be released
RELEASEVER=v1

# enabled base xc16 versions
XC16VERSIONS="v1.23 v1.24 v1.25"

# enable/disable generation of precompiled binaries for each target OS
ENABLE_LINUX=true
ENABLE_WIN32=true
ENABLE_OSX=true

# where are the source tarballs stored?
TARBALLDIR=$THISDIR/../../upstream-tarballs

# mock config
MOCKCONFIG=fedora-22-i386

# where are the RPMs of the OS X cross compiler (osxcross)?
OSXCROSS_BASE=$THISDIR/../../../osx-testbed/osxcross/result/osxcross-apple-darwin9-20160329git65edc52-1.fc22.i386.rpm
OSXCROSS_GCC=$THISDIR/../../../osx-testbed/osxcross/result/osxcross-apple-darwin9-gcc-20160329git65edc52-1.fc22.i386.rpm

# what is the path of the bin/ directory *inside the osxcross RPM*?
OSXCROSS_BINPATH=/opt/osxcross/apple-darwin9/bin
