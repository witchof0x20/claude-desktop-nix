{ lib
, stdenv
, fetchurl
, p7zip
, libarchive
, makeWrapper
, electron_33
, makeDesktopItem
, claude-native-binding
}:

let
  pname = "claude-desktop";
  version = "0.7.9";

  # Source exe file
  src = fetchurl {
    url = "https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe";
    sha256 = "sha256-raoKgJu55g7mmZ4K+eX7YWkXGHYVcFBm5qQWk+p9LE0="; # Add the hash after downloading once
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    comment = "Claude Desktop";
    desktopName = "Claude Desktop";
    categories = [ "Development" ];
  };
in
stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [ p7zip libarchive makeWrapper ];

  unpackPhase = ''
    # Create working directory
    mkdir -p $out/lib/${pname}
    
    # Extract the exe
    7z x -y $src

    # Find and extract the nupkg (adjust the path as needed)
    7z x -y AnthropicClaude-${version}-full.nupkg
    
    # Assuming your app files are in a specific folder after nupkg extraction
    # Adjust the path according to your nupkg structure
    app_folder="lib/net45/resources" # Example path
    cp ${claude-native-binding}/lib/libclaude_native_binding.so $app_folder/app.asar.unpacked/node_modules/claude-native/claude-native-binding.node
  '';

  installPhase = ''
    # Copy the application files
    cp -r "$app_folder"/* $out/lib/${pname}

    # Create wrapper script
    makeWrapper ${lib.getExe electron_33} $out/bin/${pname} \
      --add-flags "$out/lib/${pname}/app.asar"

    # Install desktop item
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications/
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
}
