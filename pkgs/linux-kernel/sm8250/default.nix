# How to update:
# - Have a local copy of <https://gitlab.com/sdm845-mainline/linux.git>.
# - Vendor the patches using `./update-kernel-patches.sh`. Using Git forge
#   compare APIs aren't reliable for this.
# - Update the base NixOS kernel version that is being overridden.
# - Check for changes to `sdm845.config` and `misc.config`. Ex: `git diff sdm845-6.11 sdm845-6.14-rc5 -- arch/arm64/configs/sdm845.config`
# - Apply changes to `structuredExtraConfig` and `config_fixes.patch` as needed.
# - Check the config by disabling `ignoreConfigErrors = true` and building.
#   - If you the log shows a bunch of "Error in reading or end of file.", search it for
#     "repeated question". The repeated question error is usually due to NixOS setting
#     every module to `module`/`m` by default.
#     - If you set the option to `no`/`n`, look for a part of the error saying what it
#       was selected by. If any of those have `=y` or `=m`, you may need to set them
#       to `no` as well.
#     - If you set the option to `yes`/`y`, check the dependencies part of the error. If
#       any of the dependencies have `=m`, you may need to set them to `yes` as well.
#   - If you see a bunch of "unused option" errors, you can ignore those. Check
#     in-between them for more important errors. You can search "not set correctly"
#     to find most of those. Don't continue until confirming that there are no
#     unacceptable errors.
# - Re-enable `ignoreConfigErrors = true`.
# - Time to build! Good luck!!
{
  lib,
  fetchurl,
  buildLinux,
  kernelPatches,
  stdenv,
  ...
}:
let
  # SDM845 isn't updated past Linux 7.1 yet.
  kernel =
    let
      version = "7.3";
    in
    buildLinux {

     # src = fetchurl {
     #   url = "https://gitlab.postmarketos.org/soc/qualcomm-sm8250/linux/-/archive/sm8250-7.2.0_git20261010/linux-sm8250-7.2.0_git20261010.tar.gz";
     #   hash = "sha256-mTID04ZPrgZSFxpQdZZe+njiGGe8nE7wUWnoWABCNKQ=";
     # };


     src = fetchurl {
       url = "https://gitlab.nura.eco/Frieder.Hannenheim/sm-8250-mainline/-/archive/240c4e0ec544304eb8be8a2d75ac67200de8e4f8/sm-8250-mainline-240c4e0ec544304eb8be8a2d75ac67200de8e4f8.tar.gz";
       hash = "sha256-mTID04ZPrgZSFxpQdZZe+njiGGe8nE7wUWnoWABCNKQ=";
     };
      inherit version;
      isLTS = false;
      modDirVersion = lib.versions.pad 3 version;
      extraMeta.branch = "7.3";


      # kernelPatches = [
      #   kernelPatches.bridge_stp_helper
      #   kernelPatches.request_key_helper
      # ];
    };
  version = "${kernel.version}-sm8250";
in
kernel.override {
  argsOverride = {
    inherit version;
    modDirVersion = kernel.modDirVersion;
    extraMeta = {
      maintainers = with lib.maintainers; [ junestepp ];
      platforms = [ "aarch64-linux" ];
    };
  };

  kernelPatches = [
    {
      name = "aw8695-bitfield-fix";
      patch = ./patches/aw8695-bitfield.patch;
    }
  ];

  # Remove some mostly raspberry pi specific stuff.
  # See <https://github.com/NixOS/nixpkgs/blob/master/lib/systems/platforms.nix>
  stdenv = lib.recursiveUpdate stdenv {
    hostPlatform.linux-kernel.extraConfig = "";
  };

  #new
  configfile = ./config-postmarketos-qcom-sm8250.aarch64;
  extraMakeFlags = [ "KBUILD_BUILD_VERSION=1-postmarketos-qcom-sm8250" ];
  # To deal with all the unused option errors.
  ignoreConfigErrors = false;
 }
