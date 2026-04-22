{
  lib,
  fetchFromGitHub,
  rustPlatform,
  icu,
}:
rustPlatform.buildRustPackage rec {
  pname = "actool";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "viraptor";
    repo = "actool";
    #tag = finalAttrs.version;
    rev = "c692176923715ca663d527914ab987cfba3493e8";
    hash = "sha256-ykDvoJY3nMQcYYxl+AkfXUj2FhI8FqRxPRVxNH5v/nY=";
  };

  cargoHash = "sha256-BhR5gwIrFE0OuSAxVTY5kMfmMlPfIABfOgmX/rOvpug=";

  meta = {
    description = "Apple's actool reimplementation";
    homepage = "https://github.com/viraptor/actool";
    license = [ lib.licenses.mit ];
    mainProgram = "actool";
    maintainers = [ lib.maintainers.viraptor ];
  };
}
