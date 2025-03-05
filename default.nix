{ lib
, stdenv
, fetchurl
, p7zip
, libarchive
, electron_33
, asar
, claude-native-binding
, makeWrapper
, makeDesktopItem
}:

let
  pname = "claude-desktop";
  version = "0.8.0";

  # Source exe file
  src = fetchurl {
    url = "https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe";
    sha256 = "sha256-nDUIeLPWp1ScyfoLjvMhG79TolnkI8hedF1FVIaPhPw=";
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

  nativeBuildInputs = [ p7zip libarchive asar makeWrapper ];

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
    cd $app_folder
    cp ${claude-native-binding}/lib/libclaude_native_binding.so ./app.asar.unpacked/node_modules/claude-native/claude-native-binding.node
    asar e ./app.asar app
    mkdir -p app/resources
    mv ./*.png app/resources/
    mv ./*.ico app/resources/
    mkdir app/resources/i18n
    mv *.json app/resources/i18n/
    sourceRoot=.
  '';

  installPhase = ''
    # Copy the application files
    asar pack ./app $out/app.asar
    cp -r ./app.asar.unpacked $out/app.asar.unpacked
    
    # Create wrapper script
    makeWrapper ${lib.getExe electron_33} $out/bin/${pname} \
      --add-flags $out/app.asar
    # Make directory for icons
    mkdir -p $out/share/icons/hicolor/48x48/apps
    cp app/resources/TrayIconTemplate@2x.png $out/share/icons/hicolor/48x48/apps/claude-desktop.png 
    # Install desktop item
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications/
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
}
