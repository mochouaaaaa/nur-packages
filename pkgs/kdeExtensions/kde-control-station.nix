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
  version = "0-unstable-2026-02-05";

  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "kde-control-station";
    rev = "a12380e34ed5f72a3c934e7141fe0dbb279084d7";
    hash = "sha256-kIkMG1ysaKIan4cGYmliONjlcY9cZDwl0LV446N1B4E=";
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
