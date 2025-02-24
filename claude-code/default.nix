{ lib, buildNpmPackage, fetchurl }:
buildNpmPackage rec {
  pname = "claude-code";
  version = "0.2.9";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-/WBysiuds6ZwwSSUFDr+sGHgRYCyFhH6bEai+XxHsYw=";
  };
  dontNpmBuild = true;
  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';
  npmDepsHash = "sha256-2v9wCcaOgA3RezX/pnqigsn6XhKcqP2adM2IGRhiHgc=";
  AUTHORIZED = "1";
  meta = with lib; {
    description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster by executing routine tasks, explaining complex code, and handling git workflows - all through natural language commands.";
    homepage = "https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview";
  };
}
