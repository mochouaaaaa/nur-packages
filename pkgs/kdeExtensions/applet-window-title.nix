{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  kdePackages,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "applet-window-title";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "dhruv8sh";
    repo = "plasma6-window-title-applet";
    tag = "${version}";
    sha256 = "sha256-pFXVySorHq5EpgsBz01vZQ0sLAy2UrF4VADMjyz2YLs=";
  };

  propagatedUserEnvPkgs = with kdePackages; [ kconfig ];

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids/org.kde.windowtitle
    cp -r $src/* $out/share/plasma/plasmoids/org.kde.windowtitle

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Plasma 6 Window Title applet ";
    mainProgram = "applet-window-title";
    homepage = "https://github.com/dhruv8sh/plasma6-window-title-applet";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2;
  };

}
