{
  lib,
  python3,
  fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "dangerzone";
  version = "0.7.0-2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "freedomofpress";
    repo = "dangerzone";
    rev = "refs/tags/v${version}";
    hash = "sha256-68KoipGJAGLTdsSu2yru4E1iLmhMHD4xLGlnIn5P8Gw=";
  };

  patches = [ ./0001-resource.patch ];

  postPatch = ''
    substituteInPlace dangerzone/util.py --replace-fail "@out@" "$out"
  '';

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    pyside6
    appdirs
    click
    colorama
    markdown
    requests
    packaging
  ];

  postInstall = ''
    cp -r share $out/share
  '';

  meta = with lib; {
    homepage = "https://dangerzone.rocks/";
    description = "Take potentially dangerous PDFs, office documents, or images and convert them to safe PDFs";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ viraptor ];
    platforms = platforms.unix;
    mainProgram = "dangerzone";
  };
}
