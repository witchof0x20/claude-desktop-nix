{ lib, buildNpmPackage, fetchurl }:
buildNpmPackage rec {
  pname = "claude-code";
  version = "0.2.30";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-ZaYfvnWxMkVnq5WOxXj5dwygmV/wEDajALPJj5QHKUQ=";
  };
  dontNpmBuild = true;
  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';
  npmDepsHash = "sha256-p8ghlzCQ++gsVNmm3BliG3Q8VBu/PqJalBUJwP7GiyU=";
  AUTHORIZED = "1";
  meta = with lib; {
    description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster by executing routine tasks, explaining complex code, and handling git workflows - all through natural language commands.";
    homepage = "https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview";
  };
}
