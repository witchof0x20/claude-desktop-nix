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
  version = "0.9.1";

  # Source exe file
  src = fetchurl {
    url = "https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe";
    sha256 = "sha256-6o7IUPKLO4vKYCnb82B7rgfdfpQiQy6JLTiKj0appIw=";
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
    ls
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

    # CHANGES FROM https://github.com/aaddrick/claude-desktop-debian/commit/dedbac7f306988fedf180362d1a6d4c8c1658b09#diff-4d2a8eefdf2a9783512a35da4dc7676a66404b6f3826a8af9aad038722da6823L341-R338
    echo "##############################################################"
    echo "Removing "'!'" from 'if ("'!'"isWindows && isMainWindow) return null;'"
    echo "detection flag to to enable title bar"
    echo "Current working directory: '$PWD'"
    SEARCH_BASE="app/.vite/renderer/main_window/assets"
    TARGET_PATTERN="MainWindowPage-*.js"
    echo "Searching for '$TARGET_PATTERN' within '$SEARCH_BASE'..."
    # Find the target file recursively (ensure only one matches)
    TARGET_FILES=$(find "$SEARCH_BASE" -type f -name "$TARGET_PATTERN")
    # Count non-empty lines to get the number of files found
    NUM_FILES=$(echo "$TARGET_FILES" | grep -c .)
    if [ "$NUM_FILES" -eq 0 ]; then
      echo "Error: No file matching '$TARGET_PATTERN' found within '$SEARCH_BASE'." >&2
      exit 1
    elif [ "$NUM_FILES" -gt 1 ]; then
      echo "Error: Expected exactly one file matching '$TARGET_PATTERN' within '$SEARCH_BASE', but found $NUM_FILES." >&2
      echo "Found files:" >&2
      echo "$TARGET_FILES" >&2
      exit 1
    else
      # Exactly one file found
      TARGET_FILE="$TARGET_FILES" # Assign the found file path
      echo "Found target file: $TARGET_FILE"
      echo "Attempting to replace '"'!'"d&&e' with 'd&&e' in $TARGET_FILE..."
      sed -i 's/\!d\&\&e/d\&\&e/g' "$TARGET_FILE"
      # Verification
      if grep -q 'd\&\&e' "$TARGET_FILE" && ! grep -q '\!d\&\&e' "$TARGET_FILE"; then
        echo "Successfully replaced '"'!'"d&&e' with 'd&&e' in $TARGET_FILE"
      else
        echo "Error: Failed to replace '"'!'"d&&e' with 'd&&e' in $TARGET_FILE. Check file contents." >&2
        exit 1
      fi
    fi
    echo "##############################################################"
    
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
