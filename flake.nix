{
  description = "LLM toolbox";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    poetry2nix = {
      url = "github:nix-community/poetry2nix/v1.28.0";
      inputs.nixpkgs.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        python = pkgs.python3;
        pythonPackages = python.pkgs;
        inherit (poetry2nix.legacyPackages.${system}) mkPoetryApplication;
        description = "LLM toolbox";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/rydnr/llm-toolbox";
        maintainers = with pkgs.lib.maintainers; [ ];
      in rec {
        packages = {
          llm-toolbox = pythonPackages.buildPythonPackage rec {
            pname = "llm-toolbox";
            version = "0.0.1a1";
            projectDir = ./.;
            src = ./.;
            format = "pyproject";

            nativeBuildInputs = [ pkgs.poetry pythonPackages.poetry-core ];
            propagatedBuildInputs = with pythonPackages; [
              google-search-results
              jupyter
              langchain
              magic
              nltk
              openai
            ];

            checkInputs = with pythonPackages; [ pytest ];

            pythonImportsCheck = [ ];

            meta = with pkgs.lib; {
              inherit description license homepage maintainers;
            };
          };
          default = packages.llm-toolbox;
          meta = with lib; {
            inherit description license homepage maintainers;
          };
        };
        defaultPackage = packages.default;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs.python3Packages; [ packages.default ];
        };
        shell = flake-utils.lib.mkShell {
          packages = system: [ self.packages.${system}.default ];
        };
      });
}
