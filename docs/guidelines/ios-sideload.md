# iOS Sideload (Personal iPhone, No Mac, No Paid Account)

How to run the app on your own iPhone from a Windows machine, using a free
Apple ID. Good for learning/showcase; not a distribution channel.

## 1. Build The Unsigned IPA (GitHub Actions)

- GitHub → Actions → "iOS IPA (unsigned)" → Run workflow.
- Keep the default `https://myfschool.kl3in.tech` for the production demo, or
  set `api_base_url` to another endpoint the iPhone can reach:
  - same Wi-Fi as the laptop: `http://<laptop-LAN-IP>:8080`
    (find it with `ipconfig`, IPv4 of the Wi-Fi adapter);
  - or a public backend URL once deployed.
- Wait ~20 minutes, download the `MyFSchool-unsigned-ipa` artifact and unzip
  it to get `MyFSchool-unsigned.ipa`.

Cost note: the repo is private, so one macOS build burns ~200 of the 2000
free monthly Actions minutes (10x multiplier). Rebuild only when app code
changes — re-sideloading reuses the same IPA.

## 2. Sideload From Windows (Sideloadly)

1. Install Sideloadly (sideloadly.io) and iTunes/Apple Devices (for the USB
   driver).
2. Connect the iPhone via USB, unlock it, tap "Trust This Computer".
3. Drag the IPA into Sideloadly, sign in with a free Apple ID (an app-specific
   password from appleid.apple.com is recommended), Start.
4. On the iPhone: Settings → General → VPN & Device Management → trust the
   developer profile. If iOS asks, enable Developer Mode
   (Settings → Privacy & Security → Developer Mode) and reboot.

## 3. Free-Apple-ID Limits

- The app signature expires after 7 days — re-run Sideloadly with the SAME
  IPA to refresh (no rebuild needed). AltStore can auto-refresh over Wi-Fi.
- At most 3 sideloaded apps and 10 app-id registrations per week.
- The backend must be running and reachable from the phone, or the app shows
  connection errors after login.
