# Wireless Reconnaissance Checklist

Purpose: a repeatable, authorized reconnaissance checklist for mapping the wireless environment in scope before any active Wi-Fi assessment.

This checklist is for in-scope, authorized, or lab use only. Reconnaissance here means passive observation and inventory building. Do not capture, store, or analyze real user traffic beyond what the engagement scope permits. Any captures are stored encrypted and destroyed after reporting.

**Status values:**
- `PASS`: the item was validated and meets the secure or expected state.
- `FAIL`: the item was validated and does not meet the secure or expected state.
- `N/A`: the item does not apply to this environment or scope.
- `NOT TESTED`: the item was in scope but has not yet been assessed.
- `NEEDS REVIEW`: results are inconclusive and require a second look or client input.

---

## Access Point (AP) Discovery

- [ ] **Enumerate all broadcasting access points in range**  Status: `NOT TESTED`
  - **What to check:** Every AP whose beacons are observable from authorized testing locations, including APs that may be out of the documented asset list.
  - **Why it matters:** An accurate AP list is the foundation of the assessment. Unexpected or rogue APs often surface here.
  - **How to validate:** Put the adapter in monitor mode and run a passive sweep, for example `airodump-ng --band abg wlan0mon`, or use `kismet` for longer passive collection.
  - **Expected secure result:** Every discovered AP maps to a known, authorized device in the client inventory.
  - **Evidence to collect:** airodump-ng CSV output, kismet log, and a screenshot of the live AP list with timestamps and testing location.

- [ ] **Identify APs outside the documented scope**  Status: `NOT TESTED`
  - **What to check:** Any AP broadcasting a client-related SSID or sitting on client premises that is not in the approved target list.
  - **Why it matters:** Unknown APs may indicate rogue devices, shadow IT, or neighboring networks that must be excluded from active testing.
  - **How to validate:** Compare discovered BSSIDs against the client-supplied inventory and flag unmatched entries for review.
  - **Expected secure result:** No unexplained APs are present, or each is accounted for and classified (client, neighbor, out of scope).
  - **Evidence to collect:** Annotated AP list showing in-scope versus flagged entries.

## Client and Station Discovery

- [ ] **Enumerate associated client stations**  Status: `NOT TESTED`
  - **What to check:** Devices currently associated to in-scope APs, listed by station MAC and the BSSID they are joined to.
  - **Why it matters:** Client counts and types help size the environment and identify device roles (laptops, phones, IoT, printers).
  - **How to validate:** Review the station section of `airodump-ng` output, or use kismet device views, during passive observation.
  - **Expected secure result:** Associated stations correspond to expected and authorized devices.
  - **Evidence to collect:** Station list (station MAC, associated BSSID, observed band) and supporting capture file.

- [ ] **Identify unassociated (probing) stations**  Status: `NOT TESTED`
  - **What to check:** Devices sending probe requests but not currently associated, including probed SSID names.
  - **Why it matters:** Probe requests can reveal network names devices expect, which informs later analysis and asset attribution.
  - **How to validate:** Observe the probes column in airodump-ng or kismet passively. Do not transmit toward these devices.
  - **Expected secure result:** Probing behavior is consistent with expected devices and does not leak sensitive internal SSIDs.
  - **Evidence to collect:** Probe request log with source MAC and probed SSIDs.

## BSSID Identification

- [ ] **Record the BSSID for each AP and radio**  Status: `NOT TESTED`
  - **What to check:** The 48-bit BSSID (MAC) of each radio, noting that one physical AP may present multiple BSSIDs for multiple SSIDs or bands.
  - **Why it matters:** BSSIDs uniquely anchor every later observation and prevent confusion between similarly named networks.
  - **How to validate:** Read the BSSID column in `airodump-ng` or `kismet`. Correlate multiple BSSIDs from the same vendor OUI to likely single physical devices.
  - **Expected secure result:** Each BSSID is mapped to a known AP and SSID.
  - **Evidence to collect:** BSSID-to-SSID mapping table and capture file reference.

## Channel Identification

- [ ] **Determine the operating channel of each AP**  Status: `NOT TESTED`
  - **What to check:** The primary channel in use per BSSID across 2.4 GHz and 5 GHz.
  - **Why it matters:** Channel data is needed for targeted, scoped captures and to understand co-channel congestion.
  - **How to validate:** Read the channel column in `airodump-ng`, or use `iw dev wlan0 scan` on a managed interface for a supplementary view.
  - **Expected secure result:** Channels are documented and consistent with regional regulatory allocations.
  - **Evidence to collect:** Per-BSSID channel list and scan output.

- [ ] **Assess channel width for each AP**  Status: `NOT TESTED`
  - **What to check:** Whether an AP uses 20, 40, 80, or wider channel bonding.
  - **Why it matters:** Channel width affects which capture channel and settings are required, and can indicate configuration and interference trade-offs.
  - **How to validate:** Review width fields from `iw dev wlan0 scan` or kismet device details.
  - **Expected secure result:** Channel width is documented and appropriate for the band and environment.
  - **Evidence to collect:** Scan output showing width per BSSID.

## Encryption, Cipher, and Authentication Identification

- [ ] **Identify the encryption suite per AP**  Status: `NOT TESTED`
  - **What to check:** Advertised security (Open, WPA2, WPA3, or mixed) per BSSID.
  - **Why it matters:** The security mode drives the entire assessment path and flags weak or open networks early.
  - **How to validate:** Read the ENC column in `airodump-ng`, confirm with `iw` scan output or kismet.
  - **Expected secure result:** No open or deprecated security on networks that should be protected.
  - **Evidence to collect:** Per-BSSID encryption column capture and scan output.

- [ ] **Identify the cipher and authentication type**  Status: `NOT TESTED`
  - **What to check:** Cipher (CCMP/AES versus TKIP) and auth key management (PSK versus 802.1X / MGT).
  - **Why it matters:** TKIP and legacy settings weaken the network. PSK versus enterprise determines which follow-on checklist applies.
  - **How to validate:** Read the CIPHER and AUTH columns in `airodump-ng` and confirm with `iw` scan RSN fields.
  - **Expected secure result:** CCMP/AES only, with TKIP absent, and an authentication type that matches the documented design.
  - **Evidence to collect:** Capture showing CIPHER and AUTH per BSSID.

## Hidden SSID Analysis

- [ ] **Detect and note hidden (non-broadcast) SSIDs**  Status: `NOT TESTED`
  - **What to check:** BSSIDs advertising a blank or length-only SSID in beacons.
  - **Why it matters:** Hidden SSIDs are a weak obscurity measure and should be documented, not relied upon for security.
  - **How to validate:** Observe hidden-SSID markers in `airodump-ng` or kismet, and allow passive observation of normal client reconnection to reveal the name in probe or association frames. Do not force client disconnects.
  - **Expected secure result:** Hidden SSIDs are recognized as a non-security feature, and real protection is provided by encryption and authentication.
  - **Evidence to collect:** Capture showing the hidden BSSID and any passively observed SSID name.

## Signal Strength (PWR / RSSI) Assessment

- [ ] **Record signal strength for each AP and relevant station**  Status: `NOT TESTED`
  - **What to check:** PWR or RSSI values per BSSID from defined measurement positions.
  - **Why it matters:** Signal strength indicates coverage spill beyond the premises and helps locate devices during inventory.
  - **How to validate:** Read the PWR column in `airodump-ng`, or use `wavemon` on a managed interface for a live per-AP signal view. Record the physical location of each reading.
  - **Expected secure result:** Coverage is understood, and excessive spill beyond controlled areas is documented for review.
  - **Evidence to collect:** Signal readings with location notes and a wavemon or airodump-ng screenshot.

## 2.4 GHz Discovery

- [ ] **Perform dedicated 2.4 GHz band discovery**  Status: `NOT TESTED`
  - **What to check:** All APs and stations operating on 2.4 GHz channels in the regulatory domain.
  - **Why it matters:** The 2.4 GHz band is congested and often hosts legacy or IoT devices with weaker configurations.
  - **How to validate:** Run `airodump-ng --band bg wlan0mon` for a focused 2.4 GHz sweep.
  - **Expected secure result:** All 2.4 GHz devices are inventoried and mapped to known assets.
  - **Evidence to collect:** 2.4 GHz capture CSV and device list.

## 5 GHz Discovery

- [ ] **Perform dedicated 5 GHz band discovery**  Status: `NOT TESTED`
  - **What to check:** All APs and stations operating on 5 GHz channels, including non-DFS and DFS ranges permitted in the regulatory domain.
  - **Why it matters:** 5 GHz often carries primary corporate traffic and higher channel widths that affect capture planning.
  - **How to validate:** Run `airodump-ng --band a wlan0mon`. Note that DFS channels require the adapter to listen for radar and may show APs only after dwell time. Respect regulatory limits and do not transmit on restricted channels.
  - **Expected secure result:** All 5 GHz devices are inventoried, with DFS and regulatory constraints documented.
  - **Evidence to collect:** 5 GHz capture CSV, DFS-channel observation notes, and scan output.

## Wireless Asset Inventory

- [ ] **Build a consolidated wireless asset inventory**  Status: `NOT TESTED`
  - **What to check:** A single table combining each device MAC, vendor OUI, hostname (where passively observable), role, and band.
  - **Why it matters:** A clean inventory ties all later findings to specific assets and supports remediation tracking.
  - **How to validate:** Merge airodump-ng and kismet outputs, resolve the vendor from the OUI portion of each MAC, assign roles from client input, and record each device band (2.4 GHz, 5 GHz, or both).
  - **Expected secure result:** Every in-scope device is accounted for with MAC, OUI vendor, role, and band populated and no unexplained entries remaining.
  - **Evidence to collect:** Final inventory table (CSV or spreadsheet), source capture references, and OUI lookup notes.

---

## Sign-off

- **Tester:** ____________________
- **Date:** ____________________
- **Scope reference:** ____________________
- **Overall status:** `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
