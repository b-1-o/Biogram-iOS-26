import os
import plistlib
import subprocess
import tempfile


SOURCE = "build-system/fake-codesigning/profiles"
DEST = "build-system/fake-codesigning/profiles"

TEAM_ID = "FAKE123456"
BUNDLE_ID = "org.28d7790dd5d2e37c.Swiftgram"

PROFILE_MAPPING = {
    "Telegram.mobileprovision": "",
    "NotificationService.mobileprovision": ".NotificationService",
    "NotificationContent.mobileprovision": ".NotificationContent",
    "Share.mobileprovision": ".Share",
    "Intents.mobileprovision": ".SiriIntents",
    "Widget.mobileprovision": ".Widget",
    "BroadcastUpload.mobileprovision": ".BroadcastUpload",
    "WatchApp.mobileprovision": ".watchkitapp",
    "WatchExtension.mobileprovision": ".watchkitapp.watchkitextension",
}


def decode_profile(path):
    data = subprocess.check_output(["security", "cms", "-D", "-i", path])
    return plistlib.loads(data)


def encode_profile(profile, output):
    temp = tempfile.NamedTemporaryFile(suffix=".plist", delete=False)
    temp_path = temp.name
    try:
        with open(temp_path, "wb") as f:
            plistlib.dump(profile, f)
        subprocess.run(
            [
                "security", "cms", "-S",
                "-N", "SelfSigned",
                "-i", temp_path,
                "-o", output,
            ],
            check=True,
        )
    finally:
        if os.path.exists(temp_path):
            os.unlink(temp_path)


def process_profile(filename, suffix):
    source = os.path.join(SOURCE, filename)
    output = os.path.join(DEST, filename)

    if not os.path.exists(source):
        raise RuntimeError("Missing provisioning profile: {}".format(source))

    print("Processing:", filename)
    profile = decode_profile(source)
    entitlements = profile.setdefault("Entitlements", {})

    profile_bundle_id = BUNDLE_ID + suffix
    app_id = TEAM_ID + "." + profile_bundle_id

    entitlements["application-identifier"] = app_id
    entitlements["com.apple.developer.team-identifier"] = TEAM_ID

    # application groups, if present — rewrite to match new bundle id
    if "com.apple.security.application-groups" in entitlements:
        groups = entitlements["com.apple.security.application-groups"]
        if isinstance(groups, list):
            entitlements["com.apple.security.application-groups"] = [
                "group." + profile_bundle_id if "telegra" in g.lower() or "telegraph" in g.lower() or "telegram" in g.lower()
                else g
                for g in groups
            ]

    if filename == "Telegram.mobileprovision":
        entitlements["aps-environment"] = "production"

    profile["Entitlements"] = entitlements
    profile["ApplicationIdentifierPrefix"] = [TEAM_ID]
    profile["TeamIdentifier"] = [TEAM_ID]
    profile["TeamName"] = "Fake Team"
    profile.pop("DER-Encoded-Profile", None)

    encode_profile(profile, output)

    print("  application-identifier:", app_id)
    if "aps-environment" in entitlements:
        print("  aps-environment:", entitlements["aps-environment"])


def main():
    if not os.path.isdir(SOURCE):
        raise RuntimeError("Missing directory: {}".format(SOURCE))

    print("========================================")
    print("Generating Biogram fake provisioning profiles")
    print("TEAM_ID:", TEAM_ID)
    print("BUNDLE_ID:", BUNDLE_ID)
    print("========================================")

    for filename, suffix in PROFILE_MAPPING.items():
        process_profile(filename, suffix)

    print("========================================")
    print("Done")
    print("========================================")


if __name__ == "__main__":
    main()
