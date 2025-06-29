# TODO: Document and review firefox config.
# TODO: We keep saving backup files via home manager and have to remove them
#       every nixos-rebuild switch. We should investigate impermanence and make
#       firefox configs deterministic.

{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.firefox
  ];

  programs = {
    firefox = {
      enable = true;
      profiles.catalin = {
        search = {
          default = "kagi";
          privateDefault = "kagi";
          order = ["kagi" "ddg" "google"];
          engines = {
            kagi = {
              name = "Kagi";
              urls = [{template = "https://kagi.com/search?q={searchTerms}";}];
              icon = "https://kagi.com/favicon.ico";
            };
            bing.metaData.hidden = true;
          };
        };
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
          bitwarden
          ublock-origin
        ];
        settings = {
          # Disable some telemetry
          "app.shield.optoutstudies.enabled" = false;
          "browser.discovery.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.sessions.current.clean" = true;
          "devtools.onboarding.telemetry.logged" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.prompted" = 2;
          "toolkit.telemetry.rejected" = true;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.server" = "";
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.unifiedIsOptIn" = false;
          "toolkit.telemetry.updatePing.enabled" = false;

          # Disable fx accounts
          "identity.fxaccounts.enabled" = false;
          # Disable "save password" prompt
          "signon.rememberSignons" = false;
        };
      };
    };
  };
}
