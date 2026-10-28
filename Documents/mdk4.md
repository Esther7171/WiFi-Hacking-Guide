# mdk4: 802.11 stress testing and the attacks a defender must recognise

> **Lab and authorised testing only.** Everything here is for a network you own or have **written permission** to test, run inside a lab or an in-scope engagement. mdk4 is a disruption tool: several of its modes are denial-of-service, and running them against a network you do not own is a crime (see the [legal section in the main guide](../README.md#legal-and-ethics)). mdk4 itself says it on launch: "It is your responsibility to make sure you have permission from the network owner before running MDK4 against it." The reason this doc exists is so defenders can **recognise and detect** each attack, which is the half that earns the report.

mdk4 (the successor to mdk3, by E7mer with the aircrack-ng community, GPLv3) is a proof-of-concept tool for exploiting common IEEE 802.11 protocol weaknesses. It needs a card already in **monitor mode** (see the [monitor mode section](../README.md#monitor-mode) in the main guide).

```bash
sudo apt install mdk4 -y
mdk4 --fullhelp          # every mode and option
mdk4 --help <mode>       # help for one mode, e.g. mdk4 --help d
```

Usage is always `mdk4 <interface> <attack_mode> [options]`.

---

## The ten attack modes, and how each one looks to a defender

| Mode | Name | What it does | What a defender sees |
| --- | --- | --- | --- |
| `b` | Beacon flooding | Advertises fake APs to clients | Dozens/hundreds of new SSIDs appear at once |
| `a` | Authentication DoS | Floods APs with auth frames | Flood of auth frames; AP may freeze or reset |
| `p` | SSID probing / bruteforce | Probes APs, bruteforces hidden SSIDs | Burst of probe requests for one BSSID |
| `d` | Deauth / disassociation | Disconnects clients from an AP | Deauth (subtype 12) / disassoc (10) storm |
| `m` | Michael countermeasures | Provokes TKIP shutdown | TKIP AP shuts down ~60s (legacy networks only) |
| `e` | EAPOL start/logoff flood | Ties up AP with fake sessions | Flood of EAPOL-Start frames |
| `s` | 802.11s mesh attacks | Floods mesh routes/neighbours | Abnormal mesh link-management traffic |
| `w` | WIDS confusion | Cross-connects clients / fake WDS | Contradictory association state across APs |
| `f` | Packet fuzzer | Sends malformed frames | Malformed / non-compliant frames |
| `x` | Protocol-implementation PoC | Tests for driver/stack vulns | Odd frames; target may crash or disconnect |

### Mode b: Beacon flooding (and why it clutters Wireshark)

A beacon frame is how an AP announces itself. Mode `b` forges a stream of them, each with a different SSID and BSSID, so every scanner in range fills with APs that do not exist.

```bash
sudo mdk4 wlan0mon b -n FakeNet          # flood beacons for SSID "FakeNet"
sudo mdk4 wlan0mon b -f ssids.txt        # one fake SSID per line from a file
sudo mdk4 wlan0mon b -c 6                 # pin to channel 6
```

This is the "confuse Wireshark" effect: a capture that was readable is suddenly thousands of beacon frames a second. It can also crash weak scanners and some drivers, which is the point of testing it. **To cut through the noise in Wireshark**, filter beacons out rather than in:

```
wlan.fc.type_subtype == 0x08            # show only beacons (to study the flood)
!(wlan.fc.type_subtype == 0x08)         # hide beacons (to keep reading real traffic)
```

A real flood gives itself away: hundreds of brand-new BSSIDs, often sequential or random MACs, all appearing in the same second. A wireless IDS (Kismet, nzyme) flags that pattern immediately.

### Mode a: Authentication denial-of-service

Sends a storm of authentication frames to every AP in range (or one target). Enough fake clients can exhaust an AP's association table and freeze or reset it.

```bash
sudo mdk4 wlan0mon a -a 3C:84:6A:11:22:33    # target one AP
```

This is a true DoS. Keep it to a lab AP you own. **Detection:** a sudden burst of authentication frames (subtype `0x0b`) from many source MACs to one BSSID.

### Mode d: Deauthentication / disassociation

The flooding version of the targeted deauth used in the main guide for handshake capture. Where `aireplay-ng --deauth 10` is a nudge, mode `d` sends continuously to knock everyone off and keep them off.

```bash
sudo mdk4 wlan0mon d -b blacklist.txt -c 6   # kick BSSIDs in blacklist.txt, channel 6
sudo mdk4 wlan0mon d -w whitelist.txt        # kick everyone EXCEPT these
```

Run continuously this is a denial-of-service, not a test. It belongs in a lab only. **Detection** is the same signature the main guide covers: a storm of deauth (subtype `0x0c` / 12) and disassociation (subtype `0x0a` / 10) frames, usually to the broadcast address, and clients flapping on and off. See [how the blue team detects it](../README.md#how-the-blue-team-detects-it).

### Modes m, e, s, w, f, x (know them, test them in a lab)

- **m (Michael countermeasures):** only affects legacy **TKIP** networks; triggers a protective ~60-second shutdown. Modern WPA2-CCMP/WPA3 are immune, which is itself a finding ("you are still on TKIP").
- **e (EAPOL start/logoff):** floods the AP with fake session starts, or logs clients off with forged EAPOL-Logoff frames.
- **s (mesh):** attacks 802.11s mesh routing (black holes, route/neighbour floods). Only relevant if the client runs a mesh.
- **w (WIDS confusion):** deliberately feeds a wireless IDS contradictory association data to test whether it can be blinded. Useful specifically for exercising the blue team.
- **f (packet fuzzer):** sends malformed frames to find driver/firmware bugs. "Be careful!" as the tool warns; it can hang hardware.
- **x (protocol PoC):** tests whether a device has an exploitable 802.11 implementation flaw; it may crash the target. Report any device that crashes, that is a vendor bug.

---

## IDS evasion flags (and why the defence still works)

mdk4 can append `--ghost` (switch rate/power periodically) and `--frag` (fragment outgoing frames) to dodge some intrusion-detection systems. They are driver-dependent and unreliable ("YMMV"). The point for a defender: evasion of a signature-only IDS is possible, which is the argument for **behavioural** detection (clients flapping, association-table churn, EAPOL rate) and for **802.11w / PMF**, which stops the forged-management-frame attacks (`a`, `d`, `e`) regardless of how they are dressed up.

## The one fix that kills most of this

Enable **802.11w (Protected Management Frames)**. It authenticates management frames, so forged deauth, disassociation, and auth-flood frames are simply ignored. It is mandatory under WPA3 and optional under WPA2. Pair it with a wireless IDS that alerts a human, and the loud modes above become detectable noise rather than an outage. Full hardening list is in the [main guide](../README.md#hardening-and-defence).
