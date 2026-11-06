# Wireless Hardening and Remediation Checklist

Purpose: a remediation checklist for hardening a Wi-Fi deployment, with a retest status recorded against each control after fixes are applied.

> Status values used throughout this checklist:
> - `PASS`: the control was validated and meets the expected secure result.
> - `FAIL`: the control was validated and does not meet the expected result.
> - `N/A`: the control does not apply to this environment.
> - `NOT TESTED`: the control is in scope but has not yet been checked.
> - `NEEDS REVIEW`: a result was obtained but needs a second opinion or client confirmation before a verdict is set.

Each item also carries a Retest status so you can track whether a fix has been confirmed after remediation. All verification assumes written authorization and a defined scope.

## Authentication and Encryption

- [ ] **WPA3 where supported**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether WPA3 (SAE for personal, or WPA3-Enterprise) is enabled on networks and clients that support it.
  - **Why it matters:** WPA3 improves resistance to offline password guessing and strengthens protection over WPA2.
  - **How to validate:** Decode the RSN information element from beacon or association frames in wireshark to confirm the advertised AKM, and review AP configuration.
  - **Expected secure result:** WPA3 is in use where the estate supports it, with a clear plan for clients that do not.
  - **Evidence to collect:** Decoded RSN element, AP config export, and client support notes.
  - **Retest status:** `NOT TESTED`

- [ ] **WPA2-AES baseline where WPA3 is unavailable**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether networks that cannot use WPA3 use WPA2 with AES (CCMP) and not TKIP, and that older open or WEP modes are absent.
  - **Why it matters:** WPA2-AES is the minimum acceptable baseline, while TKIP, WEP, and open networks are weak or broken.
  - **How to validate:** Confirm the cipher in the RSN element with wireshark and review AP settings for any legacy fallback.
  - **Expected secure result:** CCMP (AES) is enforced with no TKIP, WEP, or unexpected open networks.
  - **Evidence to collect:** Cipher details per SSID and AP configuration extract.
  - **Retest status:** `NOT TESTED`

- [ ] **Disable WPS where not required**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether Wi-Fi Protected Setup is disabled on APs that do not need it.
  - **Why it matters:** WPS, especially PIN-based WPS, has known weaknesses that can let an attacker recover the passphrase.
  - **How to validate:** Review the AP configuration for WPS state and check beacon information elements for WPS advertisement.
  - **Expected secure result:** WPS is disabled unless there is a documented business need.
  - **Evidence to collect:** AP WPS setting and the relevant beacon element.
  - **Retest status:** `NOT TESTED`

- [ ] **Protected Management Frames (PMF / 802.11w)**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether PMF is enabled (required where clients allow it) to protect management frames.
  - **Why it matters:** PMF reduces the impact of deauthentication and disassociation abuse and is mandatory under WPA3.
  - **How to validate:** Check the RSN capabilities in beacons with wireshark for the MFP-capable and MFP-required bits, and review AP settings.
  - **Expected secure result:** PMF is required where supported, and at least capable elsewhere.
  - **Evidence to collect:** Decoded RSN capabilities and AP PMF configuration.
  - **Retest status:** `NOT TESTED`

## Enterprise Authentication (802.1X / EAP)

- [ ] **Strong EAP method configuration**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether the EAP method in use is a strong, tunneled method (for example, EAP-TLS, or PEAP or EAP-TTLS with a secure inner method) and that weak legacy methods are disabled.
  - **Why it matters:** Weak EAP methods can expose credentials or allow downgrade.
  - **How to validate:** Review the RADIUS and client EAP configuration and confirm the negotiated method in a controlled authentication capture.
  - **Expected secure result:** Only approved strong EAP methods are permitted.
  - **Evidence to collect:** EAP configuration export and the observed negotiated method.
  - **Retest status:** `NOT TESTED`

- [ ] **Strict server-certificate validation on clients**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether managed clients validate the RADIUS server certificate, the expected CA, and the server name, with no prompt-to-trust fallback.
  - **Why it matters:** Without strict validation, clients can be lured into sending credentials to an impersonating server.
  - **How to validate:** Review the deployed client Wi-Fi profile for certificate validation, trusted CA, and server-name settings.
  - **Expected secure result:** Clients enforce certificate and server-name validation with no user override.
  - **Evidence to collect:** Client profile export or screenshots and the CA reference.
  - **Retest status:** `NOT TESTED`

- [ ] **Secure RADIUS configuration**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether the RADIUS service uses strong shared secrets, restricts clients to known NAS devices, uses a valid server certificate, and is reachable only over protected paths.
  - **Why it matters:** A weak RADIUS setup undermines the whole enterprise authentication chain.
  - **How to validate:** Review RADIUS server configuration, client (NAS) definitions, and certificate validity, and confirm management access is restricted.
  - **Expected secure result:** RADIUS uses strong secrets, a valid certificate, and tightly scoped client definitions.
  - **Evidence to collect:** Sanitised RADIUS configuration summary and certificate details.
  - **Retest status:** `NOT TESTED`

## Network Design and Segmentation

- [ ] **Network segmentation**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether wireless networks map to appropriate VLANs and are separated from sensitive internal systems by firewall rules.
  - **Why it matters:** Flat networks let a single compromised client reach high-value systems.
  - **How to validate:** Review the VLAN-to-SSID mapping and firewall rules, and confirm from an authorized test client that reachability matches the intended policy.
  - **Expected secure result:** Each SSID lands in its intended segment with enforced boundaries.
  - **Evidence to collect:** VLAN and firewall rule extracts and test-client reachability notes.
  - **Retest status:** `NOT TESTED`

- [ ] **Guest network isolation**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether guest traffic is isolated from internal resources and whether client-to-client isolation is enabled on the guest SSID.
  - **Why it matters:** Guest networks should give internet access without exposing internal systems or other guests.
  - **How to validate:** From an authorized guest-side test client, confirm internal resources are unreachable and that peer clients cannot be reached.
  - **Expected secure result:** Guests reach only permitted destinations and cannot reach internal systems or each other.
  - **Evidence to collect:** Reachability test results and the guest SSID isolation setting.
  - **Retest status:** `NOT TESTED`

## Operations and Monitoring

- [ ] **Firmware and software updates**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether APs, controllers, and RADIUS servers run current, vendor-supported firmware with known fixes applied.
  - **Why it matters:** Outdated firmware leaves known weaknesses exploitable.
  - **How to validate:** Review installed versions against vendor release notes and the organisation's patch policy.
  - **Expected secure result:** All wireless infrastructure runs supported, patched versions.
  - **Evidence to collect:** Version inventory and the patch-policy reference.
  - **Retest status:** `NOT TESTED`

- [ ] **Rogue AP monitoring**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether continuous monitoring detects unauthorized APs and duplicate ESSIDs.
  - **Why it matters:** Detection limits how long a rogue or evil-twin AP can operate undetected.
  - **How to validate:** Review the monitoring configuration and confirm the approved AP inventory is maintained and compared against observed APs.
  - **Expected secure result:** Rogue detection is active and reviewed, with an up-to-date inventory.
  - **Evidence to collect:** Monitoring configuration summary and a sample detection record.
  - **Retest status:** `NOT TESTED`

- [ ] **Logging and alerting**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether authentication events, association anomalies, and rogue detections are logged centrally and raise alerts that are reviewed.
  - **Why it matters:** Logs without alerting and review rarely lead to timely response.
  - **How to validate:** Review the log sources, retention, and alert rules, and confirm a test event appears and is actioned.
  - **Expected secure result:** Relevant wireless events are logged, retained, alerted on, and reviewed.
  - **Evidence to collect:** Log and alert configuration summary and a sample alert record.
  - **Retest status:** `NOT TESTED`

## Sign-off

| Field | Detail |
| --- | --- |
| Assessor | |
| Date | |
| Scope reference | |
| Authorization reference | |
| Remediation owner | |
| Overall result | |
| Retest completed by | |
| Reviewer | |

Hardening verification performed under written authorization only. Record any control that could not be retested and the reason.
