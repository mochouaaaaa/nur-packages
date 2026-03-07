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
  version = "0-unstable-2026-03-07";

  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "kde-control-station";
    rev = "04bebda930c7190b0e9c62ddbc7a3a230f02ac98";
    hash = "sha256-0cqnNHlZkYtvJHpHsA7A7gpqY7E2cQ36uY316L3kIg0=";
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
