{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  fetchFromGitHub,
  unzip,
  nix-update-script,
  swiftPackages,
  clang,
  llvmPackages,
  apple-sdk,
  xcodebuild,
  xcbuild2,
  symlinkJoin,
  ibtool,
  re-derq,
  libtapi,
  darwin,
  libressl,
  sqlite,
  libedit,
  zlib,
  python3,
  re-intentbuilderc,
  actool,
}:

let clang-lib = lib.getLib llvmPackages.clang-unwrapped;
new-sdk = symlinkJoin {
  name = "new_sdk";
  paths = [
    actool
    apple-sdk
    xcbuild2
  ];
};
new-sigtool = darwin.sigtool.overrideAttrs {
  src = fetchFromGitHub {
    owner = "viraptor";
    repo = "sigtool";
    rev = "c097ad9f529ac76b0aa32cb1e914c756c7de5d92";
    hash = "sha256-wcIjawBPw439ZrZHRZLanrcch1zSYAt4X8r4Oi+VcoE=";
  };
};
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hammerspoon";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Hammerspoon";
    repo = "hammerspoon";
    rev = finalAttrs.version;
    hash = "sha256-HEEkn1f0BNZZz8m2ZKfmfuklBoH8c2Mi+zhbC5rbCFw=";
  };

  nativeBuildInputs = [ swiftPackages.swift-build swiftPackages.swiftc new-sdk ibtool re-derq libtapi.bin new-sigtool libressl re-intentbuilderc ];# llvmPackages.clang-unwrapped ];

  buildInputs = [ sqlite libedit.dev zlib ];

  # 1. We can't use something like
  #   "CLANG_EXPLICIT_MODULES_LIBCLANG_PATH": "${llvmPackages.libclang.lib}/lib/libclang.dylib"
  # because the Apple's clang has some extra functionality that can be detected/confirmed at build time.
  # 2. We disable warning as errors, because there's bound to be warnings.
  # 3. swbuild uses `$(LD) -Xlinker ...` which doesn't work with `ld`. We need to use the compiler as the linker.
  postPatch = ''
    cat > settings.json <<EOF
{
  "overrides": {
    "environmentConfig": {
      "table": {
        "CODE_SIGN_IDENTITY": "-",
        "LD": "clang",
        "CLANG_ENABLE_EXPLICIT_MODULES": "NO",
        "GCC_TREAT_WARNINGS_AS_ERRORS": "NO"
      }
    }
  }
}
EOF
    # upstream openssl can't create C source from der files, using placeholder here
    cp ${./HammerspoonCertTemplate.h} extensions/httpserver/HammerspoonCertTemplate.h
    substituteInPlace extensions/hash/algorithms.m \
      --replace-fail "@import zlib ;" "#include <zlib.h>"
    substituteInPlace extensions/hash/libhash.m \
      --replace-fail "@import zlib ;" "#include <zlib.h>"
    substituteInPlace Hammerspoon.xcodeproj/project.pbxproj \
      --replace-fail "/bin/mkdir" "mkdir"
    substituteInPlace scripts/docs/bin/build_docs.py \
      --replace-fail '/usr/bin/env -S -P/usr/bin:''${PATH} python3' "${lib.getExe python3}"
  '';

  buildPhase = ''
    runHook preBuild
    set -x
    ls -la
    export DEVELOPER_DIR=${new-sdk}
    # module dependency discovery doesn't work, so we have to list them
    for component in lua LuaSkin Sentry Hammerspoon ; do
      if ! swbuild build Hammerspoon.xcworkspace --target $component --configuration Release --derivedDataPath $PWD/build --buildParametersFile $PWD/settings.json ; then
        echo "=== dev out ==="
        find build
        exit 1
      fi
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Hammerspoon.app $out/Applications

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Staggeringly powerful macOS desktop automation with Lua";
    homepage = "https://www.hammerspoon.org";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [
      bearoffwork
    ];
    platforms = lib.platforms.darwin;
  };
})
