{
  lib,
  fetchFromCodeberg,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "re-appintentsmetadataprocessor";
  version = "0.1.0";

  src = fetchFromCodeberg{
    owner = "viraptor";
    repo = "re-appintentsmetadataprocessor";
    rev = "21f38e0f9705ab346db0de2615dbe405c179f985";
    hash = "sha256-UPdFoOwqCG/63OqkEJ0Hs40p4RNOi5OfApF2WBpk028=";
  };

  cargoHash = "sha256-Wh6pWTdo6Ibm1LgZpw+NOy+AoU/s3I3mdlo25paj3uM=";

  meta = {
    mainProgram = "appintentsmetadataprocessor";
    description = "Open reimplementation of Apple's appintentsmetadataprocessor";
    homepage = "https://codeberg.org/viraptor/re-appintentsmetadataprocessor";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ viraptor ];
    platforms = lib.platforms.unix;
  };
}
