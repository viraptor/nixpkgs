{
  lib,
  fetchFromCodeberg,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "re-derq";
  version = "0.1.0";

  src = fetchFromCodeberg{
    owner = "viraptor";
    repo = "re-derq";
    tag = version;
    hash = "sha256-60ksvO4vtNf+gd/zJrExPXpMYL3P/LR5+5gS7JIKlXc=";
  };

  cargoHash = "sha256-dk2QgAQBoJW/1SHwgSe/RR5T4Fldd2JHtYe1o27BNMY=";

  meta = {
    mainProgram = "derq";
    description = "Open reimplementation of Apple's derq";
    homepage = "https://codeberg.org/viraptor/re-derq";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ viraptor ];
    platforms = lib.platforms.darwin;
  };
}
