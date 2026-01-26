{
  v2dat,
  stdenv,
  fetchurl,
  ...
}:
let

  version = "202601252215";

  geoip = fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${version}/geoip.dat";
    hash = "sha256-P0HllTo8F/c5Yvy21TEcIJjAcWikLow6qjPDd8t3Xqc="; # GEOIP_HASH
  };

  geosite = fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${version}/geosite.dat";
    hash = "sha256-au92YwJsekB3n19jJgJ1zxb5d7qc3oOUqYs0RifCpjA="; # GEOSITE_HASH
  };
in
stdenv.mkDerivation {
  name = "dns-rules";
  inherit version;

  nativeBuildInputs = [ v2dat ];

  srcs = [
    geoip
    geosite
  ];

  dontUnpack = true;
  installPhase = ''
    ln -s ${geoip} geoip.dat
    ln -s ${geosite} geosite.dat

    mkdir -p $out/share/mosdns


    v2dat unpack geoip -o $out/share/mosdns -f "private" geoip.dat
    v2dat unpack geoip -o $out/share/mosdns -f "cn" geoip.dat
    v2dat unpack geosite -o $out/share/mosdns -f "cn" geosite.dat
    v2dat unpack geosite -o $out/share/mosdns -f "gfw" geosite.dat
    v2dat unpack geosite -o $out/share/mosdns -f "category-ads-all" geosite.dat
    v2dat unpack geosite -o $out/share/mosdns -f "geolocation-!cn" geosite.dat
  '';

}
