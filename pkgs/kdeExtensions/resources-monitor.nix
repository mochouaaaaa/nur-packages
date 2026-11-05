{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  kdePackages,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "resources-monitor";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "orblazer";
    repo = "plasma-applet-resources-monitor";
    rev = "v${version}";
    hash = "sha256-86XT+qKGnaVxucDd4anBRaJXvD1li7Hv66bfaqJV7Z0=";
  };

  dontBuild = true;
  dontWrapQtApps = true;

  propagatedUserEnvPkgs = with kdePackages; [
    libksysguard
    kdeplasma-addons
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids/org.kde.plasma.resources-monitor
    cp -r package/* $out/share/plasma/plasmoids/org.kde.plasma.resources-monitor

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Plasmoid for monitoring CPU, memory, network traffic, GPUs and disks IO. ";
    mainProgram = "resources-monitor";
    homepage = "https://github.com/orblazer/plasma-applet-resources-monitor";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3;
  };

}
