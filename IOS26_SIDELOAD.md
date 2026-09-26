# Biogram iOS 26

This fork mirrors the Biogram source and hardens startup for iOS 26 sideload/re-signing flows.

Changes:
- The main window is made visible before optional startup branches can return.
- Background URL sessions only use an App Group shared container when it is actually available.
- The main app falls back to its private Application Support directory when the App Group entitlement is unavailable.
- The DB reset helper uses the same private fallback.

Normal builds keep using the App Group whenever the signed app has access to it.
