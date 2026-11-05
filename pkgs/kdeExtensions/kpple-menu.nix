{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  kdePackages,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "kppleMenu";
  version = "6.1.0";

  src = fetchFromGitHub {
    owner = "ChrTall";
    repo = "kppleMenu";
    rev = "v${version}";
    hash = "sha256-rCIMGLeVzmOk2VWqZ8F0dWJyPL1Zol8KPGgZCWTzoZE=";
  };

  propagatedUserEnvPkgs = with kdePackages; [ kconfig ];

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/plasmoids/com.github.chrtall.kppleMenu
    cp -r package/* $out/share/plasma/plasmoids/com.github.chrtall.kppleMenu
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The Kpple menu is the drop-down menu of Kpple OS. ";
    mainProgram = "kppleMenu";
    homepage = "https://github.com/ChrTall/kppleMenu";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2;
  };

}
