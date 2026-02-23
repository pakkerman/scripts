# exiftools

Refactored for clearer ownership and easier maintenance.

## Directory layout
- `bin/`
  - Main entrypoints.
  - `bin/run.sh`: interactive toolkit launcher.
- `lib/`
  - Shared shell utilities and reusable operation modules.
  - `lib/tui.sh`, `lib/utils.sh`, `lib/ops/*.sh`.
- `tools/`
  - Standalone media/image utilities used by the toolkit menu.
  - Example: `tools/add_watermark.sh`, `tools/crop9to16.sh`.
- `metadata/`
  - Metadata parsing and rewriting scripts.
  - Example: `metadata/get-models.sh`, `metadata/convert.sh`.
- `archive/`
  - Historical backups and old scripts not part of active flow.
- `deprecated/`
  - Legacy Civitai translator scripts retained for reference.

## Compatibility
Root-level scripts (for example `exiftools/run.sh`, `exiftools/convert.sh`) are compatibility wrappers that forward to the new canonical paths. New work should target scripts in `bin/`, `lib/ops/`, `tools/`, and `metadata/`.

## Typical usage
- `bash exiftools/bin/run.sh /path/to/images`
- `bash exiftools/metadata/convert.sh /path/to/images`

Legacy paths still work:
- `bash exiftools/run.sh /path/to/images`
