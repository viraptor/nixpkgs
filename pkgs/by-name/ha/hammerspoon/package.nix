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
  apple-sdk_26,
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
  re-appintentsmetadataprocessor,
  re-plistbuddy,
  actool,
  rsync,
  libxml2,
}:

let clang-lib = lib.getLib llvmPackages.clang-unwrapped;
new-sdk = symlinkJoin {
  name = "new_sdk";
  paths = [
    actool
    apple-sdk_26
    xcbuild2
  ];
};
new-sigtool = darwin.sigtool.overrideAttrs {
  src = fetchFromGitHub {
    owner = "viraptor";
    repo = "sigtool";
    rev = "f692c08eaed1a52b2ee42ff83d3c95fdd1d3aa21";
    hash = "sha256-0M8kxXTWzlMQHx5LNju3/sYn1Cl1R/vP6s7prK8iLz8=";
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

  nativeBuildInputs = [
    swiftPackages.swift-build
    swiftPackages.swift
    new-sdk
    ibtool
    re-derq
    libtapi.bin
    new-sigtool
    libressl
    re-intentbuilderc
    re-appintentsmetadataprocessor
    re-plistbuddy
    rsync
  ];# llvmPackages.clang-unwrapped ];

  buildInputs = [ sqlite libedit.dev zlib libxml2 darwin.ICU ];

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
        "CODESIGN": "${new-sigtool}/bin/codesign",
        "CODE_SIGN_IDENTITY": "-",
        "LD": "clang",
        "CLANG_ENABLE_EXPLICIT_MODULES": "NO",
        "GCC_TREAT_WARNINGS_AS_ERRORS": "NO",
        "SWIFT_STDLIB_TOOL_STRIP_BITCODE": "NO"
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
    substituteInPlace Pods/Pods.xcodeproj/project.pbxproj \
      --replace-fail 'ditto' "cp -L"

    substituteInPlace "Pods/Target Support Files/CocoaHTTPServer/CocoaHTTPServer.release.xcconfig" \
      --replace-fail '$(SDKROOT)/usr/include/libxml2' "${lib.getDev libxml2}/include/libxml2"
    substituteInPlace "Pods/Target Support Files/Pods-Hammerspoon/Pods-Hammerspoon.release.xcconfig" \
      --replace-fail 'LIBRARY_SEARCH_PATHS = $(inherited)' 'LIBRARY_SEARCH_PATHS = $(inherited) ${lib.getLib darwin.ICU}/lib'
    substituteInPlace "Pods/Target Support Files/Pods-Hammerspoon/Pods-Hammerspoon-frameworks.sh" \
      --replace-fail '/usr/bin/codesign' '${new-sigtool}/bin/codesign'
    substituteInPlace "Pods/Target Support Files/Pods-Hammerspoon/Pods-Hammerspoon-frameworks.sh" \
      --replace-fail "rev | cut -d ':' -f1 | awk '{\$1=\$1;print}' | rev" "awk -F': *' '{print \$NF}'"
    substituteInPlace "scripts/update_version_build_numbers.sh" \
      --replace-fail 'git=' 'git="" #'
    substituteInPlace "scripts/update_version_build_numbers.sh" \
      --replace-fail 'versionNumber=' 'versionNumber="${finalAttrs.version}" #'
    substituteInPlace "scripts/update_version_build_numbers.sh" \
      --replace-fail 'buildNumber=' 'buildNumber="0" #'
    substituteInPlace "scripts/update_version_build_numbers.sh" \
      --replace-fail '/usr/libexec/PlistBuddy' '${lib.getExe' re-plistbuddy "PlistBuddy"}'
  '';

  buildPhase = ''
    runHook preBuild
    set -x
    ls -la
    export DEVELOPER_DIR=${new-sdk}
    # module dependency discovery doesn't work, so we have to list them
    for component in Pods-Hammerspoon CocoaHTTPServer ASCIImage CocoaAsyncSocket PocketSocket MIKMIDI Sparkle SocketRocket ORSSerialPort lua LuaSkin Sentry Hammerspoon ; do
      if ! swbuild build Hammerspoon.xcworkspace --target $component --configuration Release --derivedDataPath $PWD/build --buildParametersFile $PWD/settings.json ; then
        echo "=== dev out ==="
        #find build/Products/Release/Hammerspoon.app
        exit 1
      fi
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r build/Products/Release/Hammerspoon.app $out/Applications

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
