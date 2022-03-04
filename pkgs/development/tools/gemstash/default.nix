{ lib, bundlerApp, bundlerUpdateScript }:

bundlerApp {
  pname = "gemstash";
  gemdir = ./.;
  exes = [ "gemstash" ];

  passthru.updateScript = bundlerUpdateScript "gemstash";

  meta = with lib; {
    description = "Gemstash is both a cache for remote servers such as https://rubygems.org, and a private gem source.";
    homepage    = "https://github.com/rubygems/gemstash";
    license     = licenses.mit;
    maintainers = [ maintainers.viraptor ];
  };
}
