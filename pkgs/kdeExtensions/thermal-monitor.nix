{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "thermal-monitor";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "olib14";
    repo = "thermalmonitor";
    rev = "v${version}";
    hash = "sha256-1TaeE9nsivkaiaCA8lTqwS3DGxh4MlsX1D5Y3VaU584=";
  };

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids/org.kde.olib.thermalmonitor
    cp -r package/* $out/share/plasma/plasmoids/org.kde.olib.thermalmonitor

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A KDE Plasmoid for showing system temperatures ";
    mainProgram = "thermal-monitor";
    homepage = "https://github.com/olib14/thermalmonitor";
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
  };

}
