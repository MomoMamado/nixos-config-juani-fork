{
  flake.modules.homeManager.base = {
    # local folder synced with the server (see docs/server-setup.md)
    systemd.user.tmpfiles.rules = ["d %h/Nextcloud 0700 - - -"];

    # tray client, started with the graphical session (UWSM)
    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };
}
