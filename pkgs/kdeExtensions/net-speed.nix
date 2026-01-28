{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "net-speed";
  version = "3.1";

  src = fetchFromGitHub {
    owner = "dfaust";
    repo = "plasma-applet-netspeed-widget";
    tag = "${version}";
    sha256 = "sha256-lP2wenbrghMwrRl13trTidZDz+PllyQXQT3n9n3hzrg=";
  };

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids/org.kde.netspeedWidget
    cp -r package/* $out/share/plasma/plasmoids/org.kde.netspeedWidget

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Plasma 5 widget that displays the currently used network bandwidth ";
    mainProgram = "net-speed";
    homepage = "https://github.com/dfaust/plasma-applet-netspeed-widget";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2;
  };

}
