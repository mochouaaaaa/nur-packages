{
  stdenv,
  fetchzip,
}:
let
  MonacoNerdFont = fetchzip {
    url = "https://github.com/thep0y/monaco-nerd-font/releases/download/v0.2.1/MonacoNerdFont.zip";
    sha256 = "sha256-Sal3Oa1H5Ng56VxTLToSjfSwsFFm0EtU3UksPa4P4+c=";
    stripRoot = false;
  };

  MonacoNerdFontMono = fetchzip {
    url = "https://github.com/thep0y/monaco-nerd-font/releases/download/v0.2.1/MonacoNerdFontMono.zip";
    sha256 = "sha256-gu1n+GRgiCWBka01B+jrvU2a4T3u9y1/RlspOcWMErE=";
    stripRoot = false;
  };
in
stdenv.mkDerivation {
  name = "monaco-nerd-font";
  srcs = [
    MonacoNerdFont
    MonacoNerdFontMono
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    cp -r ${MonacoNerdFont}/* $out/share/fonts/opentype
    cp -r ${MonacoNerdFontMono}/* $out/share/fonts/opentype
  '';

}
