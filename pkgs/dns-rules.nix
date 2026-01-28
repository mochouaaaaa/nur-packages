{
  lib,
  v2dat,
  stdenv,
  fetchurl,
  ...
}:
let

in
stdenv.mkDerivation (finalAttrs: {
  pname = "dns-rules";
  version = "202601272218";

  src = fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${finalAttrs.version}/geosite.dat";
    hash = "sha256-p5aIGDe5Ti4Z3EVKCRG9ZbqD6uHi0l/gFVaxxJwjzgU="; # GEOSITE_HASH
  };

  geoip = fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${finalAttrs.version}/geoip.dat";
    hash = "sha256-P0HllTo8F/c5Yvy21TEcIJjAcWikLow6qjPDd8t3Xqc="; # GEOIP_HASH
  };

  nativeBuildInputs = [ v2dat ];

  dontUnpack = true;
  installPhase = ''
    ln -s $geoip geoip.dat
    ln -s $src geosite.dat

    mkdir -p $out/share/mosdns


    v2dat unpack geoip -o $out/share/mosdns -f "private" geoip.dat
    v2dat unpack geoip -o $out/share/mosdns -f "cn" geoip.dat
    v2dat unpack geosite -o $out/share/mosdns -f "cn" geosite.dat
    v2dat unpack geosite -o $out/share/mosdns -f "gfw" geosite.dat
    v2dat unpack geosite -o $out/share/mosdns -f "category-ads-all" geosite.dat
    v2dat unpack geosite -o $out/share/mosdns -f "geolocation-!cn" geosite.dat
  '';

  passthru.autoUpdate = true;

  meta = {
    description = "dns-rules";
    homepage = "https://github.com/Loyalsoldier/v2ray-rules-dat/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.all;
    mainProgram = "dns-rules";
  };

})
