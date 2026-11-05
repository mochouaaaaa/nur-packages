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
  version = "0.21";

  src = fetchFromGitHub {
    owner = "dhruv8sh";
    repo = "plasma6-window-title-applet";
    rev = "v${version}";
    hash = "sha256-2GLVYix777hP4BkcrTHo6QOUQhcSnhkDBc3el8AuNe8=";
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
