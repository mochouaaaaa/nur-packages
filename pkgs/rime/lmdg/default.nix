{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lmdg";
  version = "LTS";

  src = fetchurl {
    url = "https://github.com/amzxyz/RIME-LMDG/releases/download/${finalAttrs.version}/wanxiang-lts-zh-hans.gram";
    hash = "sha256-9LgUCgZoI/T1nYxBs3mubyYCMzMqjvQZ40pr7MitXMk=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp $src $out/share/rime-data/wanxiang-lts-zh-hans.gram

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "fcitx5扩展词库/Rime全局带声调词库，最全声调标注工具链，Rime语法模型：LMDG - Language, Model, Dictionary, Grammar";
    homepage = "https://github.com/amzxyz/RIME-LMDG";
    changelog = "https://github.com/amzxyz/RIME-LMDG/releases/tag/${finalAttrs.version}";
    license = lib.licenses.cc-by-40;
    # maintainers = with lib.maintainers; [ rc-zb ];
    platforms = lib.platforms.all;
  };

})
