{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, openssl
, zlib
, zstd
, pkg-config
, python3
, xorg
, Libsystem
, AppKit
, Security
, nghttp2
, libgit2
, doCheck ? true
, withDefaultFeatures ? true
, additionalFeatures ? (p: p)
, testers
, nushell
, nix-update-script
, makeBinaryWrapper
, nushellPlugins
, runCommand
}:

let
  version = "0.84.0";
in

rustPlatform.buildRustPackage {
  pname = "nushell";
  inherit version;

  src = fetchFromGitHub {
    owner = "nushell";
    repo = "nushell";
    rev = version;
    hash = "sha256-vXtQUWKRPS53IBUgO9Dw8dVzfD5W2kHSPOZHs293O5Q=";
  };

  cargoHash = "sha256-NtTCuTWbGTrGKF7ulm3Bfal/WuBtPEX7QvHoOyKY1V8=";

  nativeBuildInputs = [ pkg-config ]
    ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [ python3 ]
    ++ lib.optionals stdenv.isDarwin [ rustPlatform.bindgenHook ];

  buildInputs = [ openssl zstd ]
    ++ lib.optionals stdenv.isDarwin [ zlib Libsystem Security ]
    ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [ xorg.libX11 ]
    ++ lib.optionals (withDefaultFeatures && stdenv.isDarwin) [ AppKit nghttp2 libgit2 ];

  buildNoDefaultFeatures = !withDefaultFeatures;
  buildFeatures = additionalFeatures [ ];

  inherit doCheck;

  checkPhase = ''
    runHook preCheck
    echo "Running cargo test"
    HOME=$(mktemp -d) cargo test
    runHook postCheck
  '';

  passthru = {
    shellPath = "/bin/nu";
    tests.version = testers.testVersion {
      package = nushell;
    };
    updateScript = nix-update-script { };
    withPlugins =
      let
        plugins = with nushellPlugins; [ formats gstat query ];
        pluginRegistryPath = "$out/share/nushell/plugins.nu";
        pluginRegistrations = (map (p: ''${nushell}/bin/nu --plugin-config ${pluginRegistryPath} -c "register ${p}/bin/${p.meta.mainProgram}"'') plugins);
      in
      runCommand "nushell-with-plugins"
        {
          nativeBuildInputs = [ makeBinaryWrapper ];
        } ''
        mkdir -p "$(dirname ${pluginRegistryPath})"
        touch ${pluginRegistryPath}
        ${builtins.concatStringsSep "\n" pluginRegistrations}
        makeBinaryWrapper ${nushell}/bin/nu $out/bin/nu \
          --add-flags --plugin-config \
          --add-flags "${pluginRegistryPath}"
      '';
  };

  meta = with lib; {
    description = "A modern shell written in Rust";
    homepage = "https://www.nushell.sh/";
    license = licenses.mit;
    maintainers = with maintainers; [ Br1ght0ne johntitor marsam ];
    mainProgram = "nu";
  };
}
