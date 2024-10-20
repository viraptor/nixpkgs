{ lib
, aiohttp
, bleak
, buildPythonPackage
, fetchFromGitHub
, async-timeout
, pythonOlder
}:

buildPythonPackage rec {
  pname = "adax-local";
  version = "0.1.3";
  format = "setuptools";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "Danielhiversen";
    repo = "pyAdaxLocal";
    rev = version;
    hash = "sha256-SGVXzSjtYNRVJN5fUjjskko55/e0L3P8aB90G4HuBOE=";
  };

  propagatedBuildInputs = [
    aiohttp
    bleak
    async-timeout
  ];

  # Module has no tests
  doCheck = false;

  pythonImportsCheck = [
    "adax_local"
  ];

  meta = with lib; {
    description = "Module for local access to Adax";
    homepage = "https://github.com/Danielhiversen/pyAdaxLocal";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ fab ];
  };
}
