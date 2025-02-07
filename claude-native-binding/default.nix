{ lib
, rustPlatform
, pkg-config
}:

rustPlatform.buildRustPackage {
  pname = "claude-native-binding";
  version = "0.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  # Ensure we build cdylib
  CARGO_BUILD_TARGET_DIR = "target";
  CARGO_TARGET_DIR = "target";

  # Optional: if you need to override the build command
  buildPhase = ''
    cargo build --release --lib
  '';

  # Adjust installation to put the .so in the right place
  installPhase = ''
    mkdir -p $out/lib
    cp target/release/lib*.so $out/lib/
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
}
