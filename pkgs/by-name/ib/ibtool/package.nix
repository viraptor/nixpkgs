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
    rev = "e41fb12fa962a6e332d794700ffd8c02da03bd37";
    #tag = finalAttrs.version;
    hash = "sha256-5Ayh2Yqppwl5i6YXRUYgSrvkTom0C+zXhb+lQNQWfAI=";
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
