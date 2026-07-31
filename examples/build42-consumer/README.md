# Build 42 consumer fixture

This is a small dependent mod used by `tools/validate-b42.ps1` and by the
manual smoke test in `docs/B42-MIGRATION.md`. Copy its `42/` directory into a
separate mod; do not nest it inside the framework's installed mod directory.

It demonstrates the required order:

1. register trait/profession ids;
2. declare static character definitions and translations;
3. attach server-authoritative behavior through Profession Framework.
