{
  lib,
  fetchFromGitHub,
  python3Packages,
  icu,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "actool";
  version = "1.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "viraptor";
    repo = "actool";
    #tag = finalAttrs.version;
    rev = "67bfde618594f94cf6560365ef11950a392abb2d";
    hash = "sha256-FMU9FdanS1KlCLfAc0StL3ZblvxzPCcJa41+JpAUJiU=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pillow
    liblzfse
    icu
  ];

  meta = {
    description = "Apple's actool reimplementation";
    homepage = "https://github.com/viraptor/actool";
    license = [ lib.licenses.mit ];
    mainProgram = "actool";
    maintainers = [ lib.maintainers.viraptor ];
  };
})
