# WPA2-Personal (PSK) Assessment Checklist

Purpose: a repeatable, authorized checklist for assessing the security posture of WPA2-Personal (pre-shared key) wireless networks.

This checklist is for in-scope, authorized, or lab use only. Any handshake capture, passphrase auditing, or cracking activity described here uses supplied or synthetic lab captures, never real employee sessions. Captures and any recovered credentials are stored encrypted and destroyed after reporting. Do not run sustained-disruption activity against production networks.

**Status values:**
- `PASS`: the item was validated and meets the secure or expected state.
- `FAIL`: the item was validated and does not meet the secure or expected state.
- `N/A`: the item does not apply to this environment or scope.
- `NOT TESTED`: the item was in scope but has not yet been assessed.
- `NEEDS REVIEW`: results are inconclusive and require a second look or client input.

---

## Encryption Configuration

- [ ] **Confirm WPA2 with AES/CCMP is enforced**  Status: `NOT TESTED`
  - **What to check:** The network advertises and requires CCMP (AES) as the cipher.
  - **Why it matters:** AES/CCMP is the strong cipher for WPA2. Reliance on anything weaker undermines confidentiality.
  - **How to validate:** Read the CIPHER field from a passive `airodump-ng` scan, or inspect RSN fields with `iw dev wlan0 scan`.
  - **Expected secure result:** CCMP (AES) is the only cipher offered.
  - **Evidence to collect:** Scan output showing CCMP, and a screenshot of the AP security settings if accessible.

- [ ] **Confirm TKIP is disabled**  Status: `NOT TESTED`
  - **What to check:** That TKIP is not present in a mixed or fallback configuration.
  - **Why it matters:** TKIP is deprecated and weakens the network, and mixed mode can force clients onto the weaker cipher.
  - **How to validate:** Check the CIPHER column for TKIP in airodump-ng output and the RSN/WPA information elements in `iw` scan results.
  - **Expected secure result:** TKIP is absent. No WPA (v1) or mixed WPA/WPA2 TKIP mode is advertised.
  - **Evidence to collect:** Scan output confirming absence of TKIP.

## Passphrase Policy and Length

- [ ] **Assess PSK passphrase length and complexity policy**  Status: `NOT TESTED`
  - **What to check:** The organization's documented standard for PSK length, character composition, and rotation.
  - **Why it matters:** Short or predictable passphrases are the primary weakness of WPA2-Personal and are vulnerable to offline guessing.
  - **How to validate:** Review the client passphrase policy and confirm the configured length (recommended well above the 8-character minimum) through interview and configuration review. Do not request the live passphrase unless scope permits.
  - **Expected secure result:** A long, high-entropy, non-dictionary passphrase is used and rotated per policy.
  - **Evidence to collect:** Policy document reference and configuration screenshot (passphrase value redacted).

## WPA2 Four-Way Handshake Concept

- [ ] **Document the four-way handshake security model**  Status: `NOT TESTED`
  - **What to check:** Understanding that the four-way handshake derives session keys (PTK) from the PSK (PMK) and nonces, and that captured handshake material enables offline, not online, guessing.
  - **Why it matters:** This concept explains why passphrase strength is the deciding control for WPA2-Personal.
  - **How to validate:** Review the handshake exchange conceptually and confirm with the client that the risk model is understood. Reference a synthetic or supplied lab handshake for illustration.
  - **Expected secure result:** Stakeholders understand that handshake exposure plus a weak passphrase equals offline compromise risk.
  - **Evidence to collect:** Written explanation in the report and reference to the synthetic lab capture used for illustration.

## PMF / 802.11w Status

- [ ] **Check Protected Management Frames (802.11w / PMF)**  Status: `NOT TESTED`
  - **What to check:** Whether PMF is disabled, capable (optional), or required.
  - **Why it matters:** PMF protects management frames and reduces exposure to deauthentication and disassociation abuse.
  - **How to validate:** Inspect the RSN capabilities in `iw dev wlan0 scan` output and confirm against AP configuration.
  - **Expected secure result:** PMF is set to required, or at minimum capable, consistent with client-device support.
  - **Evidence to collect:** Scan output showing PMF capability bits and configuration screenshot.

## WPS Status

- [ ] **Determine whether WPS is enabled**  Status: `NOT TESTED`
  - **What to check:** Presence of a WPS information element and whether PIN-based WPS is active.
  - **Why it matters:** WPS, particularly PIN mode, introduces a well-known weakness that can bypass passphrase strength.
  - **How to validate:** Observe the WPS indicator in kismet or a passive scan, and confirm in AP configuration. Document the state only. Do not run WPS brute-force activity against production.
  - **Expected secure result:** WPS is disabled, especially external PIN registration.
  - **Evidence to collect:** Scan output or configuration screenshot showing WPS state.

## Legacy-Client Compatibility

- [ ] **Review legacy-client and backward-compatibility settings**  Status: `NOT TESTED`
  - **What to check:** Whether legacy rates, WPA v1, or TKIP fallback are enabled to support old clients.
  - **Why it matters:** Backward-compatibility options often reintroduce weak ciphers and lower the effective security floor.
  - **How to validate:** Review AP configuration and scan output for legacy mode indicators, and interview staff about old-device requirements.
  - **Expected secure result:** No weakening fallback is enabled. Legacy devices are segmented or retired rather than accommodated with weak settings.
  - **Evidence to collect:** Configuration screenshot and notes on any legacy-device exceptions.

## Offline Password-Strength Auditing (Lab / Supplied Captures Only)

- [ ] **Audit passphrase resilience using supplied or synthetic captures**  Status: `NOT TESTED`
  - **What to check:** Whether the PSK would resist realistic offline guessing, measured only against a lab or client-supplied handshake, never a real employee session.
  - **Why it matters:** This demonstrates real-world exposure if a handshake were captured and a weak passphrase were in use.
  - **How to validate:** Convert the supplied or synthetic lab capture to the hashcat format and run a bounded, time-boxed audit, for example `hashcat -m 22000 lab-capture.hc22000 wordlist.txt`. Keep all material in the encrypted engagement store.
  - **Expected secure result:** The passphrase is not recovered within the agreed effort and wordlist scope.
  - **Evidence to collect:** hashcat session log (command, wordlist name, runtime, result status), with any recovered value redacted in the report and the raw value held encrypted.

- [ ] **Build targeted wordlists for the audit**  Status: `NOT TESTED`
  - **What to check:** That the audit reflects realistic, context-aware guessing rather than only generic lists.
  - **Why it matters:** Organization-specific terms are a common source of weak but memorable passphrases.
  - **How to validate:** Generate candidate lists with `cewl` (site-derived words), `cupp` (profile-based candidates), and `crunch` (pattern-based generation), scoped to the engagement and lab material only.
  - **Expected secure result:** The passphrase resists targeted lists, demonstrating it is not derived from guessable organizational terms.
  - **Evidence to collect:** Wordlist generation commands and the audit log referencing which lists were used.

## Remediation Recommendations

- [ ] **Produce prioritized remediation recommendations**  Status: `NOT TESTED`
  - **What to check:** That every finding maps to a clear, actionable recommendation.
  - **Why it matters:** Findings are only useful when paired with remediation the client can act on.
  - **How to validate:** Draft recommendations such as enforcing long high-entropy passphrases, disabling TKIP and WPS, enabling PMF, segmenting legacy devices, and considering WPA3 or WPA3-transition where supported.
  - **Expected secure result:** A complete, prioritized remediation set accompanies the findings.
  - **Evidence to collect:** Remediation table mapping each finding to a recommendation and priority.

---

## Sign-off

- **Tester:** ____________________
- **Date:** ____________________
- **Scope reference:** ____________________
- **Overall status:** `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
