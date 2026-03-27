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
  version = "0-unstable-2026-03-26";

  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "kde-control-station";
    rev = "9f7f13f7fc5c72263bc5dbbaf66eb1f5b03b377d";
    hash = "sha256-i/o1t/noeDA07rgtNI+yC+AufbcU8w8LLj2hmhK2lhc=";
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
