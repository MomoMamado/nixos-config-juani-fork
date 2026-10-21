{
  flake.modules.homeManager.dev = {pkgs, ...}: {
    home.packages = with pkgs; [
      awscli2
      gh
      terraform
      python3
      dotnet-sdk
      k6

      lazygit
      lazysql
      posting
      claude-code

      vscodium
      jetbrains.rider
      dbeaver-bin

      devenv
    ];

    home.sessionVariables.DOTNET_CLI_TELEMETRY_OPTOUT = "1";

    programs.zsh.initContent = ''eval "$(devenv hook zsh)"'';
  };
}
