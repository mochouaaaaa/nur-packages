{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "v2dat";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "urlesistiana";
    repo = "v2dat";
    rev = "47b8ee51fb528e11e1a83453b7e767a18d20d1f7";
    hash = "sha256-dJld4hYdfnpphIEJvYsj5VvEF4snLvXZ059HJ2BXwok=";
  };

  vendorHash = "sha256-ndWasQUHt35D528PyGan6JGXh5TthpOhyJI2xBDn0zI=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = with lib; {
    description = "A cli tool that can unpack v2ray data packages. (Note: This project is for fun ONLY. You should build your own data dirctly from upstreams instead of unpacking a v2ray data pack.)";
    homepage = "https://github.com/urlesistiana/v2dat";
    license = licenses.gpl3;
    maintainers = [ ];
  };
})
