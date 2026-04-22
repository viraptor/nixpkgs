{
  lib,
  fetchFromCodeberg,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "re-intentbuilderc";
  version = "1.0.1";
  __structuredAttrs = true;

  src = fetchFromCodeberg {
    owner = "viraptor";
    repo = "re-intentbuilderc";
    #tag = version;
    rev = "f60cc6a271ab29723508871c70be67c74878d2d6";
    hash = "sha256-gFtzxn1V/zZKw1kc0S1CMrLDjytn9eDd64kQAPpx4s4=";
  };

  cargoHash = "sha256-c2dQoLfaJul00vbj6cWj+sQi/GLZef8JkpZuPFlqKzI=";

  meta = {
    mainProgram = "intentbuilderc";
    description = "Open reimplementation of Apple's intentbuilderc";
    homepage = "https://codeberg.com/viraptor/re-intentbuilderc";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ viraptor ];
    platforms = lib.platforms.unix;
  };
}
