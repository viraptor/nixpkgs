{ lib, stdenv, fetchFromGitLab, pkg-config
, withLibui ? true, gtk3
, withUdisks ? stdenv.isLinux, udisks, glib
, libX11
, darwin }:

let frameworks = darwin.apple_sdk.frameworks;
in stdenv.mkDerivation rec {
  pname = "usbimager";
  version = "1.0.8";

  src = fetchFromGitLab {
    owner = "bztsrc";
    repo = pname;
    rev = version;
    sha256 = "1j0g1anmdwc3pap3m4kfzqjfkn7q0vpmqniii2kcz7svs5h3ybga";
  };

  sourceRoot = "source/src/";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = lib.optionals withUdisks [ udisks glib ]
    # libui is bundled with the source of usbimager as a compiled static libary
    ++ lib.optional (!withLibui) libX11
    ++ lib.optional withLibui gtk3
    ++ lib.optionals stdenv.isDarwin (with frameworks; [ CoreFoundation IOKit DiskArbitration Foundation Cocoa ]);

  postPatch = ''
    sed -i \
      -e 's|install -m 2755 -g disk|install |g' \
      -e 's|-I/usr/include/gio-unix-2.0|-I${glib.dev}/include/gio-unix-2.0|g' \
      -e 's|install -m 2755 -g $(GRP)|install |g' Makefile
    sed -i -e 's|CC\s*=|CC?=|' bzip2/Makefile
    sed -i -e 's|CC\s*=|CC?=|' xz/Makefile
    sed -i \
      -e 's|CC\s*=|CC?=|' \
      -e 's|-framework CoreFoundation|-framework CoreFoundation -F${frameworks.CoreFoundation}/Library/Frameworks|' \
      -e 's|-framework DiskArbitration|-framework DiskArbitration -F${frameworks.DiskArbitration}/Library/Frameworks|' \
      -e 's|-framework Foundation|-framework Foundation -F${frameworks.Foundation}/Library/Frameworks|' \
      -e 's|-framework Cocoa|-framework Cocoa -F${frameworks.Cocoa}/Library/Frameworks|' \
      -e 's|-framework IOKit|-framework IOKit -F${frameworks.IOKit}/Library/Frameworks|'  Makefile
  '';

  dontConfigure = true;

  makeFlags =  [ "PREFIX=$(out)" ]
    ++ lib.optional withLibui "USE_LIBUI=yes"
    ++ lib.optional withUdisks "USE_UDISKS2=yes";

  meta = with lib; {
    description = "A very minimal GUI app that can write compressed disk images to USB drives";
    homepage = "https://gitlab.com/bztsrc/usbimager";
    license = licenses.mit;
    maintainers = with maintainers; [ vdot0x23 ];
    # windows and darwin could work, but untested
    # feel free add them if you have a machine to test
    platforms = with platforms; unix;
  };
}
