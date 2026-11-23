{ pkgs }:
_: {
  onSchedule.update-slack-cli = {
    when = {
      dayOfWeek = [ "Mon" ];
      hour = 6;
      minute = 17;
    };
    outputs.effects.update-slack-cli =
      pkgs.runCommand "effect-update-slack-cli"
        {
          __nixbot_effect_checkout = true;
          nativeBuildInputs = [
            pkgs.cacert
            pkgs.gh
            pkgs.git
            pkgs.jq
            pkgs.nix
            pkgs.nix-update
          ];
          secretsMap = builtins.toJSON { git.type = "GitToken"; };
        }
        ''
          set -euo pipefail
          export HOME=/build/home
          mkdir -p "$HOME"
          export NIX_CONFIG="experimental-features = nix-command flakes"
          GH_TOKEN=$(jq -r '.git.data.token' "$HERCULES_CI_SECRETS_JSON")
          export GH_TOKEN
          git config --global user.name "mulatta-nixbot[bot]"
          git config --global user.email "353212200+mulatta-nixbot[bot]@users.noreply.github.com"
          git config --global safe.directory '*'
          cd "$NIXBOT_EFFECT_CHECKOUT"

          nix-update --flake --version=stable slackcli
          if git diff --quiet; then
            echo "slackcli is up to date"
            exit 0
          fi

          version=$(nix eval --raw .#slackcli.version)
          title="slackcli: update Slack CLI to $version"
          branch=update/slack-cli
          git checkout -B "$branch"
          git commit -am "$title"
          git push -f origin "$branch"

          pr=$(gh pr list --head "$branch" --state open --json number --jq '.[0].number // empty')
          if [ -n "$pr" ]; then
            gh pr edit "$pr" --title "$title"
          else
            gh pr create --head "$branch" \
              --title "$title" \
              --body "Update the packaged Slack CLI to its latest release." \
              --label dependencies
          fi
        '';
  };
}
