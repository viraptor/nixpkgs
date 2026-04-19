{
  lib,
  fetchFromGitHub,
  python3Packages,
  icu,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ibtool";
  version = "1.1.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "viraptor";
    repo = "ibtool";
    rev = "fb10d98ac65ac22da09043c7d47032fcd7a1155d";
    #tag = finalAttrs.version;
    hash = "sha256-qkqexOLk/DG63PryPE/O/T1lkTsNBAVckzyy8vSc0VI=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    lxml
  ];

  runtimeDependencies = [
    icu
  ];

  meta = {
    description = "Apple's ibtool reimplementation";
    homepage = "https://github.com/viraptor/ibtool";
    license = [ lib.licenses.mit ];
    mainProgram = "ibtool";
    maintainers = [ lib.maintainers.viraptor ];
  };
})
