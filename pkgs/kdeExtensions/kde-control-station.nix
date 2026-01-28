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
  version = "0-unstable-2026-01-22";

  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "kde-control-station";
    rev = "fdb2d030478eb17a4464fff139da9f639499c6cd";
    sha256 = "sha256-mMeZ6czgLMiCt1nkZrzm1GUuSfAxnkW1mmXCuW9RPfU=";
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
