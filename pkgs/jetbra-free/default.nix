{
  lib,
  buildGoModule,
  go-bindata,
}:

buildGoModule {
  pname = "jetbra";
  version = "release";

  src = ./src;
  subPackages = [ "cmd" ];

  nativeBuildInputs = [ go-bindata ];

  vendorHash = "sha256-ZL9Rxnj6Z4oEBeFxX13mnd6F7vSuOFq1R/Ja7OuRp6E=";

  preBuild = ''
    go-bindata -o internal/util/access.go -pkg util static/... templates/... cache/...
  '';

  postInstall = ''
    if [ -f $out/bin/cmd ]; then
      mv $out/bin/cmd $out/bin/jetbra-free
    fi
  '';

  doCheck = false;

  meta = with lib; {
    description = "jetbra-free";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "jetbra-free";
  };
}
