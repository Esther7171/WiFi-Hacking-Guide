# Rogue AP and Evil Twin Assessment Checklist

Purpose: a repeatable checklist for detecting unauthorized access points, SSID impersonation, and related client-trust weaknesses during an authorized engagement.

> Status values used throughout this checklist:
> - `PASS`: the item was validated and meets the expected secure result.
> - `FAIL`: the item was validated and does not meet the expected result.
> - `N/A`: the item does not apply to this environment.
> - `NOT TESTED`: the item is in scope but has not yet been checked.
> - `NEEDS REVIEW`: a result was obtained but needs a second opinion or client confirmation before a verdict is set.

All testing assumes written authorization and a defined scope. Any impersonation activity in this checklist is lab-only. Use a clearly labelled test SSID such as `LAB-ROGUE-TEST` and synthetic identities such as `testuser@lab.example`. Never clone a real corporate SSID, never use real credentials, and never run sustained-disruption actions against production clients or networks.

## Rogue AP Detection

- [ ] **Unauthorized or personal access points**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether any AP is broadcasting inside the environment that is not on the approved inventory, including personal routers brought in by staff.
  - **Why it matters:** An unmanaged AP can bypass security controls and expose the internal network.
  - **How to validate:** Capture beacons with kismet or `iw dev <iface> scan`, then compare the discovered BSSID and SSID list against the approved AP inventory.
  - **Expected secure result:** Every broadcasting AP maps to an approved, documented device.
  - **Evidence to collect:** The discovered AP list, the approved inventory, and a table of any unmatched BSSIDs.

- [ ] **Personal hotspots and tethering**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether phone or laptop hotspots are operating within the assessed area.
  - **Why it matters:** Hotspots create uncontrolled paths around the corporate perimeter and can lure clients onto untrusted links.
  - **How to validate:** Review the scan for SSIDs and vendor OUIs typical of mobile hotspots, and note short-lived or roaming BSSIDs in a kismet capture.
  - **Expected secure result:** No unauthorized hotspots are present, or they are identified and addressed by policy.
  - **Evidence to collect:** List of candidate hotspot BSSIDs with vendor OUI and observation times.

- [ ] **Rogue bridges into a corporate VLAN**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether any unauthorized AP appears to bridge wireless clients directly onto an internal VLAN.
  - **Why it matters:** A wireless bridge into a trusted VLAN removes the segmentation that protects internal systems.
  - **How to validate:** Correlate a suspect AP with internal addressing by observing, on an authorized test client, which subnet and gateway are offered after association, and compare against the approved guest or corporate ranges.
  - **Expected secure result:** No unauthorized device offers access to an internal VLAN.
  - **Evidence to collect:** Observed addressing details from the test client and the mapping to the expected VLAN plan.

## Evil Twin and SSID Impersonation (Lab-Only)

- [ ] **Duplicate ESSID with different BSSID**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether two or more APs advertise the same ESSID but with BSSIDs or security settings that do not match the approved inventory.
  - **Why it matters:** An evil twin presents a familiar network name to trick clients into associating with an attacker-controlled AP.
  - **How to validate:** In a controlled lab, stand up a labelled test AP broadcasting `LAB-ROGUE-TEST` and confirm detection logic flags the duplicate-ESSID or unknown-BSSID condition. For the production assessment, review the live scan for any ESSID presented by a BSSID not on the inventory.
  - **Expected secure result:** Each approved ESSID is served only by approved BSSIDs with the expected security configuration.
  - **Evidence to collect:** ESSID-to-BSSID mapping, security settings per BSSID, and a note of the lab test setup.

- [ ] **Signal and configuration anomalies for a known SSID**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether a known SSID suddenly appears from an unexpected location, at an unusual signal level, or with changed capabilities (for example, open where it should be WPA2 or WPA3).
  - **Why it matters:** These anomalies are common signs of an impersonating AP.
  - **How to validate:** Compare current beacon attributes (security, channel, capabilities, approximate signal) against a known-good baseline captured earlier with kismet or wireshark.
  - **Expected secure result:** Known SSIDs match their baseline attributes.
  - **Evidence to collect:** Baseline versus current comparison table and decoded beacon samples.

## Client Trust and Certificate Validation

- [ ] **Server-certificate validation on enterprise clients**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether managed clients are configured to validate the RADIUS server certificate, including the expected CA and server name, before sending credentials.
  - **Why it matters:** Without strict validation, a client may hand credentials to an impersonating AP that presents any certificate.
  - **How to validate:** Review the client Wi-Fi profile settings for certificate validation and trusted CA pinning. In the lab, confirm a correctly configured client refuses to complete authentication against a test AP presenting an untrusted certificate.
  - **Expected secure result:** Clients validate the server certificate and expected name, and refuse unknown or mismatched certificates.
  - **Evidence to collect:** Screenshots or exports of client profile settings and the lab test outcome notes.

- [ ] **Credential exposure resistance (lab-only)**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether a correctly configured client protects credentials when faced with an impersonating AP in a controlled lab.
  - **Why it matters:** This confirms the practical effect of certificate validation rather than only its configuration.
  - **How to validate:** In an isolated lab only, use synthetic identities such as `testuser@lab.example` and a labelled test SSID to confirm the client does not transmit usable credentials to an untrusted server. Do not perform this against production clients or real accounts.
  - **Expected secure result:** No usable credential material is released to the untrusted test AP.
  - **Evidence to collect:** Lab configuration notes and the observed client refusal behaviour.

## Captive Portal Security

- [ ] **Captive portal transport and trust**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether a guest captive portal is served over HTTPS with a valid certificate and whether it ever requests sensitive credentials.
  - **Why it matters:** A portal served insecurely, or one that asks for corporate credentials, trains users to trust pages that an attacker can imitate.
  - **How to validate:** Observe the portal on an authorized test client, review the certificate and transport, and note what information it requests.
  - **Expected secure result:** The portal uses valid HTTPS, requests only appropriate guest information, and never asks for corporate credentials.
  - **Evidence to collect:** Certificate details, transport notes, and a redacted screenshot of the portal.

## MAC Spoofing Detection

- [ ] **MAC-spoofing indicators**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether the same MAC address appears from conflicting locations, or whether an AP MAC is seen with unexpected vendor OUI or sequence-number patterns.
  - **Why it matters:** Spoofing a trusted MAC helps an attacker impersonate an approved AP or bypass MAC-based controls.
  - **How to validate:** Review captures in wireshark for duplicate addresses, sudden sequence-number jumps, or OUI mismatches, and correlate against the approved inventory.
  - **Expected secure result:** Observed MAC addresses are consistent and match approved devices.
  - **Evidence to collect:** Capture extracts showing the anomalies and the inventory cross-reference.

## Expected Security Indicators

- [ ] **Positive detection and alerting indicators**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether the environment produces the expected signals of healthy rogue-AP defence: a maintained AP inventory, wireless monitoring in place, and alerts on unknown BSSIDs or duplicate ESSIDs.
  - **Why it matters:** Detection controls are only useful if they fire and are reviewed.
  - **How to validate:** Review monitoring configuration and confirm, during the lab test, that introducing `LAB-ROGUE-TEST` generates the expected alert.
  - **Expected secure result:** Rogue and impersonation conditions raise timely, reviewed alerts.
  - **Evidence to collect:** Monitoring configuration summary and a sample alert from the lab test.

## Defensive Recommendations

- [ ] **Recommended hardening against rogue and evil-twin threats**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether the common defensive measures are in place: enforced server-certificate validation on clients, Protected Management Frames (802.11w), continuous rogue-AP monitoring, an accurate AP inventory, guest and corporate separation, and user guidance to avoid connecting to open lookalike networks.
  - **Why it matters:** These controls reduce both the chance of a successful impersonation and the time to detect one.
  - **How to validate:** Review each control against configuration and policy, and record gaps as findings.
  - **Expected secure result:** The listed controls are implemented and maintained.
  - **Evidence to collect:** Control-by-control status notes and references to supporting configuration.

## Sign-off

| Field | Detail |
| --- | --- |
| Assessor | |
| Date | |
| Scope reference | |
| Authorization reference | |
| Lab test SSID and identities used | |
| Overall result | |
| Reviewer | |

All impersonation testing was lab-only using labelled test SSIDs and synthetic identities. No real corporate SSID or real credential was used, and no sustained disruption was performed.
