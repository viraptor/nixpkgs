{
  lib,
  fetchFromGitHub,
  stdenv,
  cmake,
  llvm_libtool,
  ninja,
  swift-minimal,
  swift_release,
}:

# Note: This is just a build of Swift Syntax that reuses the libraries from the compiler.
# This is needed for library plugins that are part of the toolchain. Otherwise, they won’t find their macro types.

stdenv.mkDerivation (finalAttrs: {
  pname = "swift-syntax";
  version = swift_release;

  src = fetchFromGitHub {
    owner = "swiftlang";
    repo = "swift-syntax";
    tag = "swift-${finalAttrs.version}-RELEASE";
    hash = "sha256-DMMVJQj590RGGBkTgA89u01ZP2B8kbJTmfu+oxzYPds=";
  };

  patches = [ ./patches/0001-gnu-install-dirs.patch ];

  strictDeps = true;

  buildCommand = ''
    # Install CMake config file for the Swift Collections library.
    mkdir -p mkdir -p "''${!outputDev}/lib/cmake/SwiftSyntax"
    substitute ${./files/SwiftSyntaxConfig.cmake} "''${!outputDev}/lib/cmake/SwiftSyntax/SwiftSyntaxConfig.cmake" \
      --replace-fail '@buildType@' ${if stdenv.hostPlatform.isStatic then "STATIC" else "SHARED"} \
      --replace-fail '@dev@' ${lib.escapeShellArg swift-minimal.swiftc.out} \
      --replace-fail '@lib@' ${lib.escapeShellArg swift-minimal.swiftc.out}
  '';

  __structuredAttrs = true;

  meta = {
    homepage = "https://github.com/swiftlang/swift-syntax";
    description = "Swift libraries for parsing Swift source code";
    license = lib.licenses.asl20;
    teams = [ lib.teams.swift ];
  };
})
