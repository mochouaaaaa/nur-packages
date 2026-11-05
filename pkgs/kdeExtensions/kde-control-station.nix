{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  kdePackages,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "kde-control-station";
  version = "0-unstable-2026-04-28";

  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "kde-control-station";
    rev = "bb473188a19d6cbe89a9c1bb5b08c7ddc609375d";
    hash = "sha256-Hjjz3RefycImPgAuTUchr8Jikh4HlLf+fOPuh0aMP2M=";
  };

  propagatedUserEnvPkgs = with kdePackages; [
    plasma-nm
    kdeplasma-addons
    plasma-pa
    powerdevil
    kdeconnect-kde
  ];

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids/KdeControlStation
    cp -r package/* $out/share/plasma/plasmoids/KdeControlStation

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "A beautiful and modern configuration center for KDE inspired by MacOS! ";
    mainProgram = "kde-control-station";
    homepage = "https://github.com/EliverLara/kde-control-station";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3;
    # maintainers = [ "EliverLara" ];
  };

}
