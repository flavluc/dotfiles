{ pkgs, ...}:

let
  ethtool = "${pkgs.ethtool}/bin/ethtool";
  rg      = "${pkgs.ripgrep}/bin/rg";
  wc      = "/run/current-system/sw/bin/wc";

  eth  = "enp2s";
  wifi = "wlp3s0";
in
  pkgs.writeShellScriptBin "check-network" ''
    if [[ $1 = "eth" ]]; then
      eth=$(${ethtool} ${eth} 2>/dev/null | ${rg} "Link detected: yes" | ${wc} -l)

      if [[ $eth -eq 1 ]]; then
        echo ${eth}
      else
        echo ""
      fi
    elif [[ $1 = "wifi" ]]; then
      wifi1=$(${ethtool} ${wifi} 2>/dev/null | ${rg} "Link detected: yes" | ${wc} -l)

      if [[ $wifi -eq 1 ]]; then
        echo ${wifi}
      else
        echo ""
      fi
    else
      echo ""
    fi
  ''
