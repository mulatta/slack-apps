{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "slack-cli";
  version = "4.7.0";

  src = fetchFromGitHub {
    owner = "slackapi";
    repo = "slack-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-dSHl3u60WQHj8icfe9ZShh431/IfV25D8l5pZISMOhU=";
  };

  vendorHash = "sha256-RI0j2+9S6kxHALEztV7hnY8NNR5xwUWgG4YHGGXZZiA=";

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/slackapi/slack-cli/internal/version.Version=v${finalAttrs.version}"
  ];

  doCheck = false;

  postInstall = ''
    mv "$out/bin/slack-cli" "$out/bin/slack"
  '';

  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  installCheckPhase = ''
    runHook preInstallCheck

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    SLACK_DISABLE_TELEMETRY=true "$out/bin/slack" version --skip-update

    runHook postInstallCheck
  '';

  meta = {
    description = "Slack command-line interface";
    homepage = "https://github.com/slackapi/slack-cli";
    changelog = "https://github.com/slackapi/slack-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "slack";
    maintainers = [ ];
  };
})
