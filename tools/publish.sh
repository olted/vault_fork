#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
APPID=236850
ITEMID=$(sed -n 's/^remote_file_id="\([0-9]*\)".*/\1/p' "$REPO/descriptor.mod")
STEAM_USER="${STEAM_USER:-ppil12}"
STEAMCMD="${STEAMCMD:-$HOME/.local/share/steamcmd/steamcmd.sh}"
BUILD="$REPO/build"

cd "$REPO"
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Uncommitted changes:"; git status --short
  read -rp "Publish anyway? [y/N] " a; [[ "$a" == [yY] ]] || exit 1
fi
NOTE="${1:-$(git log -1 --format=%B)}"

rm -rf "$BUILD"; mkdir -p "$BUILD/content"
rsync -a --delete \
  --exclude='.git*' --exclude='.cwtools' --exclude='build' --exclude='tools' \
  --exclude='CLAUDE.md' --exclude='readme.md' --exclude='.claude' \
  "$REPO/" "$BUILD/content/"

python3 -I - "$BUILD/item.vdf" "$APPID" "$ITEMID" "$BUILD/content" "$REPO/thumbnail.png" "$NOTE" <<'PY'
import sys
out, appid, item, content, preview, note = sys.argv[1:]
esc = lambda s: s.replace('\\', '\\\\').replace('"', '\\"')
with open(out, 'w') as f:
    f.write('"workshopitem"\n{\n')
    for k, v in [("appid", appid), ("publishedfileid", item), ("contentfolder", content),
                 ("previewfile", preview), ("changenote", note)]:
        f.write(f'\t"{k}"\t"{esc(v)}"\n')
    f.write('}\n')
PY
echo "Uploading $(du -sh "$BUILD/content" | cut -f1) to workshop item $ITEMID as $STEAM_USER"
echo "Change note: $NOTE"
"$STEAMCMD" +login "$STEAM_USER" +workshop_build_item "$BUILD/item.vdf" +quit
echo "Done: https://steamcommunity.com/sharedfiles/filedetails/?id=$ITEMID"
