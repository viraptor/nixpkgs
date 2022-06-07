{ lib, stdenv, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation rec {
  pname = "conserver";
  version = "8.2.7";

  src = fetchFromGitHub {
    owner = "bstansell";
    repo = "conserver";
    rev = "v${version}";
    sha256 = "sha256-LiCknqitBoa8E8rNMVgp1004CwkW8G4O5XGKe4NfZI8=";
  };

  patches = [ ./true_var.patch ];

  nativeBuildInputs = [ autoreconfHook ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://www.conserver.com/";
    description = "An application that allows multiple users to watch a serial console at the same time";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sarcasticadmin ];
  };
}
