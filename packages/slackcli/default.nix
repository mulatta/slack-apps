{
  lib,
  stdenv,
  buildGo127Module,
  fetchFromGitHub,
}:

# go.mod requires go >= 1.27.1, newer than nixpkgs' default toolchain.
buildGo127Module (finalAttrs: {
  pname = "slack-cli";
  version = "4.11.0";

  src = fetchFromGitHub {
    owner = "slackapi";
    repo = "slack-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xUrJpSr2Z6vIPltXBpwxIEZRLgs5z3/jCM3d4HIChCo=";
  };

  vendorHash = "sha256-WnlE2kkWIJ254LyX3/MA+6+60DbO8xFHPcik2n9l34c=";

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
