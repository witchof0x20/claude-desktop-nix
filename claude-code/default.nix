{ lib, buildNpmPackage, fetchurl }:
buildNpmPackage rec {
  pname = "claude-code";
  version = "0.2.8";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-ZhIW3W2lTqNTb+upS3VUr4ojnWdgLFSkdHmH8m6p2us="; # Replace with actual hash
  };
  dontNpmBuild = true;
  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';
  npmDepsHash = "sha256-sNbATV3SQFOWYRISWK71dE7+P2YD7EW9Xmmq8gUDQFs=";
  AUTHORIZED = "1";
  meta = with lib; {
    description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster by executing routine tasks, explaining complex code, and handling git workflows - all through natural language commands.";
    homepage = "https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview";
  };
}
