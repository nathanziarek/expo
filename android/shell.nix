with (import ../nix {});

let

   pkgs = androidenv.androidPkgs_9_0;
   ndk = pkgs.ndk-bundle;
   ndk_root = "${ndk}/libexec/android-sdk/ndk-bundle";
   sdk = pkgs.androidsdk;
   sdk_path = if stdenv.isDarwin
     then "/Library/Android/sdk"
     else "/Android/Sdk"; # intentional Capital S

in

mkShell rec {

  LANG="en_US.UTF-8";
  JAVA_HOME=openjdk8;

  ANDROID_SDK_ROOT=builtins.getEnv("HOME") + sdk_path;
  ANDROID_NDK_ROOT="${ANDROID_SDK_ROOT}/ndk-bundle";
  ANDROID_HOME=ANDROID_SDK_ROOT;
  ANDROID_NDK=ANDROID_NDK_ROOT;

  nativeBuildInputs = [
    awscli
    curl
    fastlane
    git
    nodejs
    openjdk8
  ];

  passthru = { inherit ndk; };

  shellHook = ''
    ${./install-ndk-17c.sh} ${ndk_root} $ANDROID_NDK_ROOT
    yes | ${sdk}/bin/sdkmanager --sdk_root="$ANDROID_SDK_ROOT" "build-tools;28.0.3"
    ${lib.optionalString stdenv.isLinux ''
      for dep in lib lib64; do
        if [ -L /$dep ] || [ ! -e /$dep ]; then
          echo "Creating /$dep"
          ln -s ${stdenv.cc.libc}/$dep /$dep
        else
          echo "Using existing /$dep"
        fi
      done
    ''}
  '';
}
