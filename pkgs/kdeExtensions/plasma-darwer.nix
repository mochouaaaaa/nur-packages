{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  kdePackages,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "plasma-darwer";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "p-connor";
    repo = "plasma-drawer";
    rev = "v${version}";
    hash = "sha256-1RShJo74wS2Y98RyAlTozR0mcrF+3oKJ9yv7L/u1Uzo=";
  };

  propagatedUserEnvPkgs = with kdePackages; [ kconfig ];
  dontBuild = true;
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids/p-connor.plasma-drawer
    cp -r $src/* $out/share/plasma/plasmoids/p-connor.plasma-drawer

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A customizable fullscreen launcher widget for KDE Plasma ";
    mainProgram = "plasma-darwer";
    homepage = "https://github.com/p-connor/plasma-drawer";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2;
  };

}
