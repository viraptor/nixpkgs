{
  lib,
  fetchFromGitHub,
  fetchSwiftPMDeps,
  ncurses,
  pkg-config,
  sqlite,
  stdenv,
  swift,
  swiftpm,
  swift_release,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sourcekit-lsp";
  version = swift_release;

  src = fetchFromGitHub {
    owner = "swiftlang";
    repo = "sourcekit-lsp";
    tag = "swift-${finalAttrs.version}-RELEASE";
    hash = "sha256-vDMZJSIeM+oIheeJCEfP0+FAJn+RyNYDDdWrHJDRcyE=";
  };

  patches = [
    # We can’t use the XCTest framework on Darwin and have to use swift-corelibs-xctest. Patch the `PerfTestCase`
    # base class to build with it on Darwin.
    ./patches/0001-Fix-for-using-swift-corelibs-xctest-on-Darwin.patch
  ];

  swiftpmDeps = fetchSwiftPMDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-h9+4nj6QfNOXhKsJaQYtrcbO3v3pRd4sAE3tsfDtZrs=";
    # Upstream doesn’t provide `Package.resolved`.
    postPatch = ''
      ln -s ${./Package.resolved} Package.resolved
    '';
  };

  nativeBuildInputs = [
    pkg-config
    swift
    swiftpm
  ];

  buildInputs = [
    ncurses
    sqlite
  ];

  meta = {
    description = "Language Server Protocol implementation for Swift and C-based languages";
    mainProgram = "sourcekit-lsp";
    homepage = "https://github.com/apple/sourcekit-lsp";
    platforms = with lib.platforms; linux ++ darwin;
    license = lib.licenses.asl20;
    teams = [ lib.teams.swift ];
  };
})
