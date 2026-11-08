{
  lib,
  stdenvNoCC,
  symlinkJoin,
  pkgs,
  fetchFromGitLab,
}:

  symlinkJoin {
    pname = "alsa-ucm-conf-sm8250";
    version = "0-unstable-2026-05-07";

    paths = [
      pkgs.alsa-ucm-conf
    ];

    postBuild = ''
      mkdir -p $out/share/alsa/ucm2/OnePlus
      mkdir -p $out/share/alsa/ucm2/conf.d/sm8250

    cp ${./OnePlus8T.conf} \
      $out/share/alsa/ucm2/OnePlus/O8T.conf

    cp ${./HiFi.conf} \
      $out/share/alsa/ucm2/OnePlus/HiFi.conf

    ln -sf ../../OnePlus/O8T.conf \
      $out/share/alsa/ucm2/conf.d/sm8250/O8T.conf
    '';
  }
