{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "thermal-monitor";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "olib14";
    repo = "thermalmonitor";
    tag = "v${version}";
    sha256 = "sha256-4+SNHlqWB/nLkWc2pOY5CAIkcT7NE/fscV1RfhqJ5CM=";
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
