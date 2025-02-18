{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.vscode-remote-workaround;
in {
  options.vscode-remote-workaround = {
    enable = lib.mkEnableOption "automatic VSCode remote server patch";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nodejs_20;
      defaultText = lib.literalExpression "pkgs.nodejs_20";
      description = lib.mdDoc "The Node.js package to use. You generally shouldn't need to override this.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user = {
      paths.vscode-remote-workaround = {
        wantedBy = ["default.target"];
        pathConfig.PathChanged = "%h/.vscode-server/bin";
      };

      services.vscode-remote-workaround.script = ''
        echo "Replacing node with link to ${cfg.package}"
        for i in ~/.vscode-server/bin/*; do
          if [ -d "$i" ]; then
            echo "Fixing vscode-server in $i..."
            ln -sf ${cfg.package}/bin/node $i/node
          fi
        done
      '';
    };
  };
}
