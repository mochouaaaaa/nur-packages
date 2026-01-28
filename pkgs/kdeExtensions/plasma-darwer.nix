{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  kdePackages,
  unzip,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "plasma-darwer";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "p-connor";
    repo = "plasma-drawer";
    tag = "${version}";
    hash = "sha256-TLLvjZdGdT/8zVpPGwnRofr1NZVDvBUIUpp/kwk3kR4=";
  };

  nativeBuildInputs = [ unzip ];
  unpackPhase = ''
    echo "Skippiong unpackPhase"
  '';

  propagatedUserEnvPkgs = with kdePackages; [ kconfig ];
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir tmpdir
    unzip $src -d tmpdir

    mkdir -p $out/share/plasma/plasmoids/p-connor.plasma-drawer
    cp -r tmpdir/* $out/share/plasma/plasmoids/p-connor.plasma-drawer

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
