# Corporate Wireless Assessment Checklist

Purpose: a master checklist for conducting an authorized corporate wireless (Wi-Fi) security assessment from pre-engagement through reporting.

## How to use this checklist

This checklist assumes you have written authorization and an agreed scope before any testing begins. Work through each category in order. Mark every item with one of the five status values below, and always attach the evidence named in the item so findings are reproducible.

- `PASS`: The control was tested and behaves securely as expected.
- `FAIL`: The control was tested and a weakness or misconfiguration was confirmed.
- `N/A` (Not Applicable): The item does not apply to this environment or is outside the agreed scope.
- `NOT TESTED`: The item was in scope but not yet tested (time, access, or window constraints).
- `NEEDS REVIEW`: The result is ambiguous or requires a second opinion, vendor input, or client confirmation before a final rating.

Important: Disruptive techniques (deauthentication, beacon or authentication floods, mdk4, RADIUS impersonation, evil twin) are included only as lab-only or maintenance-window validation steps. They are used briefly to generate a detection signature in monitoring tooling, never sustained against production and never to harvest real employee credentials or impersonate a production SSID. Run them only when the rules of engagement explicitly permit, inside an approved window, with the named network owner informed.

---

## A. Pre-engagement

- [ ] **Written authorization on file**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** A signed authorization letter or statement of work exists and names the authorizing party.
  - **Why it matters:** Wireless testing without written permission can be unlawful and can disrupt production networks.
  - **How to validate:** Review the signed document and confirm the signatory has authority over the in-scope networks.
  - **Expected secure result:** A current, signed authorization covering the exact engagement dates and activities.
  - **Evidence to collect:** Copy or reference ID of the signed authorization, retained with the engagement file.

- [ ] **Scope defined and agreed**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** The scope document lists what is in and out of scope, including any explicitly forbidden actions.
  - **Why it matters:** A clear scope prevents accidental testing of third-party or production-critical systems.
  - **How to validate:** Compare the scope document against the target environment and confirm boundaries with the client.
  - **Expected secure result:** A dated scope document acknowledged by both parties.
  - **Evidence to collect:** Scope document reference and acknowledgement record.

- [ ] **In-scope SSIDs listed**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Every SSID authorized for testing is named in writing.
  - **Why it matters:** Nearby networks may belong to neighbors or other tenants and must not be touched.
  - **How to validate:** Cross-reference the SSID list with a passive survey (airodump-ng or kismet) and flag any SSID not on the list.
  - **Expected secure result:** Only listed SSIDs are tested; all others are recorded but left untouched.
  - **Evidence to collect:** Approved SSID list and a passive survey capture (pcap or CSV) showing observed networks.

- [ ] **In-scope BSSIDs identified**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** The specific access point MAC addresses (BSSIDs) authorized for testing are recorded.
  - **Why it matters:** One SSID can be served by many APs; testing must target only authorized radios.
  - **How to validate:** Use airodump-ng to map each in-scope SSID to its BSSIDs and confirm against the client AP inventory.
  - **Expected secure result:** Each tested BSSID appears on the approved list.
  - **Evidence to collect:** BSSID-to-SSID mapping table and supporting capture.

- [ ] **Physical locations and test windows confirmed**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Building addresses, floors, and permitted testing times are documented.
  - **Why it matters:** Wireless testing is location-bound and some tests are limited to maintenance windows.
  - **How to validate:** Review the location list and schedule with the client point of contact.
  - **Expected secure result:** Agreed locations and windows are documented and understood by site staff.
  - **Evidence to collect:** Location list, schedule, and site access confirmation.

- [ ] **Access point inventory obtained**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** A client-provided inventory of authorized APs exists for rogue comparison.
  - **Why it matters:** Rogue AP detection depends on a known-good baseline.
  - **How to validate:** Obtain the inventory (model, BSSID, location, controller name) and spot-check against a survey.
  - **Expected secure result:** A complete, current AP inventory is available.
  - **Evidence to collect:** AP inventory export and a sample of survey results confirming entries.

- [ ] **Test accounts provisioned**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Dedicated, non-privileged test accounts are provided for authentication testing.
  - **Why it matters:** Using real employee accounts risks lockouts and exposes personal credentials.
  - **How to validate:** Confirm each test account can authenticate to the in-scope network and is flagged as a test identity.
  - **Expected secure result:** Test accounts exist, are isolated, and can be disabled after the engagement.
  - **Evidence to collect:** List of test account identifiers (not passwords) and provisioning confirmation.

- [ ] **Test certificates provided (enterprise networks)**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** For certificate-based EAP, test client certificates and the expected CA chain are supplied.
  - **Why it matters:** Certificate validation testing requires knowing the legitimate trust chain.
  - **How to validate:** Confirm the test certificate authenticates and record the issuing CA for later validation checks.
  - **Expected secure result:** Valid test certificates and documented trust chain are available.
  - **Evidence to collect:** Certificate metadata (issuer, subject, expiry) and CA chain reference.

- [ ] **Named network owners recorded**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** A named owner or administrator is recorded for each in-scope network.
  - **Why it matters:** Owners must be reachable to approve disruptive tests and confirm findings.
  - **How to validate:** Confirm each owner's name and contact details with the client.
  - **Expected secure result:** Every in-scope network maps to a reachable, named owner.
  - **Evidence to collect:** Owner contact list retained with the engagement file.

- [ ] **Rules of engagement agreed**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** The rules state which techniques are allowed, which require a window, and which are forbidden.
  - **Why it matters:** Disruptive wireless tests can affect production; the rules set clear boundaries.
  - **How to validate:** Review the rules and confirm that deauth, flood, and impersonation tests are marked window-only or forbidden.
  - **Expected secure result:** A signed rules-of-engagement document with disruptive-test constraints clearly stated.
  - **Evidence to collect:** Rules-of-engagement document reference.

- [ ] **Emergency contact and stop procedure defined**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** A 24-hour emergency contact and a clear stop-testing procedure are documented.
  - **Why it matters:** If testing causes an outage, the team must be able to stop and notify quickly.
  - **How to validate:** Confirm the contact is reachable and that both sides understand the stop signal.
  - **Expected secure result:** A tested escalation path with a named contact and agreed stop command.
  - **Evidence to collect:** Emergency contact record and documented stop procedure.

---

## B. Wireless discovery

- [ ] **SSID enumeration**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** All broadcasting and (where observable) non-broadcasting SSIDs in the area are enumerated.
  - **Why it matters:** A complete picture of visible networks frames the rest of the assessment.
  - **How to validate:** Run a passive survey with airodump-ng or kismet and export the observed SSID list.
  - **Expected secure result:** Only expected corporate and known neighbor SSIDs are present.
  - **Evidence to collect:** Survey CSV or pcap and a screenshot of the SSID list.

- [ ] **BSSID identification**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Each in-scope SSID is mapped to its serving BSSIDs.
  - **Why it matters:** Distinguishing legitimate radios from rogues depends on accurate BSSID mapping.
  - **How to validate:** Use airodump-ng to list BSSIDs per SSID and compare to the client AP inventory.
  - **Expected secure result:** All observed BSSIDs for in-scope SSIDs match inventory entries.
  - **Evidence to collect:** BSSID mapping table and supporting capture.

- [ ] **Frequency band in use**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether each network operates on 2.4 GHz, 5 GHz, or 6 GHz.
  - **Why it matters:** Band choice affects coverage, congestion, and which tests apply.
  - **How to validate:** Read the band and frequency from airodump-ng output or `iw dev <iface> scan`.
  - **Expected secure result:** Bands in use match the documented design.
  - **Evidence to collect:** Scan output showing frequency per BSSID.

- [ ] **Channel assignment**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** The operating channel of each in-scope AP.
  - **Why it matters:** Poor channel planning causes interference and can hint at misconfiguration.
  - **How to validate:** Capture channel per BSSID with airodump-ng or `iw` scan output.
  - **Expected secure result:** Channels follow a sensible, non-overlapping plan.
  - **Evidence to collect:** Channel listing per BSSID.

- [ ] **Channel width**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** The configured channel width (for example 20, 40, 80, or 160 MHz).
  - **Why it matters:** Wider channels increase throughput but raise interference risk in dense areas.
  - **How to validate:** Read channel width from `iw dev <iface> scan` or a Wireshark radiotap view.
  - **Expected secure result:** Channel width matches the documented design and local conditions.
  - **Evidence to collect:** Scan output or capture showing width per BSSID.

- [ ] **Encryption and cipher suite**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** The encryption type and cipher advertised by each network (for example WPA2, WPA3, open, WEP).
  - **Why it matters:** Open or legacy encryption (WEP, TKIP) is a serious weakness.
  - **How to validate:** Read the encryption and cipher fields from airodump-ng or the beacon frames in a Wireshark capture.
  - **Expected secure result:** No open or legacy encryption on corporate networks; modern ciphers only.
  - **Evidence to collect:** Capture of beacon frames showing the advertised cipher per BSSID.

- [ ] **Rogue AP inventory**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Any AP broadcasting a corporate SSID that is not in the client inventory.
  - **Why it matters:** A rogue AP can be used to intercept or misdirect client traffic.
  - **How to validate:** Compare surveyed BSSIDs against the inventory with airodump-ng or kismet output and list unmatched radios.
  - **Expected secure result:** No unexpected AP advertises a corporate SSID.
  - **Evidence to collect:** List of unmatched BSSIDs with capture timestamps and signal data.

- [ ] **Signal strength mapping**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Approximate signal strength of in-scope networks at tested locations.
  - **Why it matters:** Signal bleed beyond the building increases exposure to outside attackers.
  - **How to validate:** Record RSSI values with wavemon, airodump-ng, or `iw` at several points, including building edges.
  - **Expected secure result:** Coverage is intentional and does not spill excessively outside controlled areas.
  - **Evidence to collect:** RSSI readings with location notes and screenshots.

- [ ] **Unauthorized AP identification**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Employee-installed or unsanctioned APs attached to the corporate environment.
  - **Why it matters:** Unauthorized APs bypass controls and create uncontrolled entry points.
  - **How to validate:** Correlate survey results with inventory and, where authorized, with wired-side discovery to flag unsanctioned devices.
  - **Expected secure result:** No unauthorized AP is connected to the corporate network.
  - **Evidence to collect:** Device list, capture evidence, and (if available) switch port correlation.

---

## C. Authentication

- [ ] **WPA2 and WPA3 configuration**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Which protocol versions and modes (personal or enterprise) are in use.
  - **Why it matters:** WPA3 and WPA2-Enterprise offer stronger protections than WPA2-Personal or transition modes.
  - **How to validate:** Read the advertised AKM and RSN information from beacon frames in Wireshark.
  - **Expected secure result:** Corporate networks use WPA2-Enterprise or WPA3 with no legacy fallback where avoidable.
  - **Evidence to collect:** Capture showing the RSN and AKM fields per BSSID.

- [ ] **WPS status**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether Wi-Fi Protected Setup is enabled on any in-scope AP.
  - **Why it matters:** WPS, especially PIN-based, is a known weak point on many devices.
  - **How to validate:** Use wash to detect APs advertising WPS and record which have it enabled.
  - **Expected secure result:** WPS is disabled on all corporate APs.
  - **Evidence to collect:** wash output listing WPS state per BSSID.

- [ ] **EAP methods offered**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Which EAP methods the enterprise network accepts (for example EAP-TLS, PEAP, EAP-TTLS).
  - **Why it matters:** Certificate-based EAP-TLS is stronger than password-based methods that can be relayed.
  - **How to validate:** Observe the EAP negotiation in a capture during a test-account login, noting the offered methods.
  - **Expected secure result:** Strong methods are preferred and weak or deprecated inner methods are not allowed.
  - **Evidence to collect:** Capture of the EAP handshake with the negotiated method highlighted.

- [ ] **Certificate validation by clients**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether managed clients verify the RADIUS server certificate and CA.
  - **Why it matters:** Without server certificate validation, clients can be tricked into trusting a fake authenticator.
  - **How to validate:** In an approved maintenance window, stand up a lab EAP endpoint with eaphammer or hostapd-wpe using a test SSID (not a production SSID) and observe whether a test client refuses the untrusted certificate. This is used to confirm client behavior and generate a detection signature, not to collect real credentials.
  - **Expected secure result:** Test clients reject the unknown certificate and do not proceed.
  - **Evidence to collect:** Capture and client-side screenshot showing the certificate was rejected.

- [ ] **Authentication policy enforcement**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Password or certificate policy, lockout thresholds, and session controls.
  - **Why it matters:** Weak policy makes guessing and reuse attacks easier.
  - **How to validate:** Review the documented policy and confirm behavior with the test account where permitted.
  - **Expected secure result:** Policy matches corporate standards and is enforced in practice.
  - **Evidence to collect:** Policy document reference and test observations.

- [ ] **Invalid-credential handling**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** How the network responds to a known-bad credential on the test account.
  - **Why it matters:** Verbose errors can leak whether a username exists.
  - **How to validate:** Submit a deliberately wrong credential for the test account and review the RADIUS log and client message.
  - **Expected secure result:** Access is denied with a generic message and the event is logged.
  - **Evidence to collect:** RADIUS log line and client-side screenshot of the denial.

- [ ] **Disabled-user handling**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether a disabled test account is correctly refused.
  - **Why it matters:** Stale or disabled accounts that still authenticate are a common weakness.
  - **How to validate:** Have the client disable the test account, then attempt authentication and review the RADIUS log.
  - **Expected secure result:** The disabled account is denied access immediately.
  - **Evidence to collect:** RADIUS log line showing the rejection and the account state.

- [ ] **RADIUS logging and retention**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether authentication events are logged with enough detail and retained.
  - **Why it matters:** Logs are essential for detecting attacks and investigating incidents.
  - **How to validate:** With the administrator, confirm that the earlier test logins appear in the RADIUS logs with timestamps and outcomes.
  - **Expected secure result:** All authentication attempts are logged and retained per policy.
  - **Evidence to collect:** Sample log entries matching the test activity.

---

## D. Network access

- [ ] **VLAN assignment**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether wireless clients land on the correct VLAN for their role.
  - **Why it matters:** Wrong VLAN assignment can grant unintended access to sensitive segments.
  - **How to validate:** After authenticating with a test account, read the assigned IP and gateway with nmcli or `ip addr` and confirm the expected subnet.
  - **Expected secure result:** Each network places clients on its intended VLAN only.
  - **Evidence to collect:** IP configuration output and the expected VLAN mapping.

- [ ] **Guest network isolation**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether the guest network is isolated from internal resources.
  - **Why it matters:** Guest users should reach the internet only, not internal systems.
  - **How to validate:** From a guest-connected test client, attempt to reach a known internal host and confirm the attempt fails (capture with tcpdump or tshark).
  - **Expected secure result:** Guest clients cannot reach internal systems.
  - **Evidence to collect:** Capture showing blocked attempts to internal addresses.

- [ ] **Client isolation (same SSID)**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether clients on the same SSID can communicate with each other.
  - **Why it matters:** Lack of client isolation lets one compromised device reach peers directly.
  - **How to validate:** With two authorized test clients, attempt peer-to-peer traffic and observe with tcpdump whether it is permitted.
  - **Expected secure result:** Client isolation blocks peer traffic where policy requires it (commonly on guest networks).
  - **Evidence to collect:** Capture showing peer traffic blocked or allowed as expected.

- [ ] **Internal network access scope**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Which internal services an authenticated wireless client can reach.
  - **Why it matters:** Over-broad access expands the blast radius of a compromised client.
  - **How to validate:** From a test client, enumerate reachable in-scope services with an authorized, low-impact scan and record what responds.
  - **Expected secure result:** Access is limited to what the role requires (least privilege).
  - **Evidence to collect:** Scan output and reachability notes against the expected access matrix.

- [ ] **Management interface exposure**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether AP or controller management interfaces are reachable from client VLANs.
  - **Why it matters:** Exposed management planes are a high-value target.
  - **How to validate:** From a test client, attempt to reach management addresses and ports and confirm they are blocked (tcpdump or tshark capture).
  - **Expected secure result:** Management interfaces are not reachable from user or guest VLANs.
  - **Evidence to collect:** Capture showing blocked access to management endpoints.

- [ ] **Firewall restrictions between segments**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether segmentation rules between wireless and other segments are enforced.
  - **Why it matters:** Weak inter-segment rules undermine the value of VLANs.
  - **How to validate:** Test a representative set of allowed and denied flows from a test client and compare to the documented policy.
  - **Expected secure result:** Observed behavior matches the intended firewall policy.
  - **Evidence to collect:** Flow test results with captures and the policy reference.

- [ ] **DNS controls**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Which DNS servers clients are pushed and whether external DNS is restricted.
  - **Why it matters:** Unrestricted DNS can be used for exfiltration and to bypass filtering.
  - **How to validate:** Read the assigned DNS from the test client and attempt an external resolver query, observing with tshark whether it is permitted.
  - **Expected secure result:** Clients use approved resolvers and unauthorized external DNS is blocked.
  - **Evidence to collect:** DNS configuration output and capture of the resolver test.

- [ ] **DHCP controls**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** DHCP scope, lease options, and protection against rogue DHCP.
  - **Why it matters:** A rogue DHCP server can redirect clients to attacker-controlled gateways.
  - **How to validate:** Observe the DHCP exchange with tshark on the test client and confirm the offer comes from the expected server, and that DHCP snooping or equivalent protection is noted by the administrator.
  - **Expected secure result:** Only the authorized DHCP server responds and lease options are correct.
  - **Evidence to collect:** DHCP exchange capture and administrator confirmation of snooping controls.

---

## E. Wireless resilience

- [ ] **Protected Management Frames (802.11w / PMF)**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether PMF is required or at least capable on in-scope networks.
  - **Why it matters:** PMF protects management frames and limits certain deauthentication attacks.
  - **How to validate:** Read the RSN capabilities (MFPC and MFPR bits) from beacon frames in Wireshark.
  - **Expected secure result:** PMF is required on WPA3 and enabled where supported on WPA2-Enterprise.
  - **Evidence to collect:** Capture showing the PMF capability and requirement bits per BSSID.

- [ ] **Deauthentication monitoring**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether the wireless monitoring system detects deauthentication activity.
  - **Why it matters:** Deauth activity can indicate an attack in progress.
  - **How to validate:** In an approved maintenance window, send a brief, low-volume deauth burst against a dedicated test client with aireplay-ng solely to produce one detectable event, then confirm the monitoring system raised an alert. Do not sustain this against production clients.
  - **Expected secure result:** The monitoring system detects and alerts on the deauth event.
  - **Evidence to collect:** Capture of the test frames, the monitoring alert, and the window authorization note.

- [ ] **Rogue AP detection**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether the wireless system flags APs that are not in inventory.
  - **Why it matters:** Automated rogue detection catches what spot surveys miss.
  - **How to validate:** With client approval, review the controller or WIDS rogue classification and compare to your own survey findings.
  - **Expected secure result:** The system classifies and alerts on rogue or unknown APs.
  - **Evidence to collect:** Controller or WIDS rogue report and your matching survey data.

- [ ] **Authentication-flood detection**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether the monitoring system detects a burst of authentication or association attempts.
  - **Why it matters:** Floods can be used to disrupt service or stress the authenticator.
  - **How to validate:** In an approved maintenance window, generate a short, low-volume authentication burst with a tool such as mdk4 against a test BSSID only, enough to trigger one detection event, then confirm the alert. Do not run sustained or high-volume floods against production.
  - **Expected secure result:** The system detects the burst and raises an alert.
  - **Evidence to collect:** Capture of the test burst, the resulting alert, and the window authorization note.

- [ ] **Wireless IDS/IPS presence and coverage**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether a wireless IDS/IPS is deployed and covers the in-scope areas.
  - **Why it matters:** Monitoring blind spots let attacks go unnoticed.
  - **How to validate:** Review the WIDS/WIPS configuration and sensor placement with the administrator.
  - **Expected secure result:** Monitoring covers all in-scope locations with no significant gaps.
  - **Evidence to collect:** WIDS/WIPS configuration summary and coverage map.

- [ ] **AP failover and redundancy**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether coverage is maintained if an AP or controller fails.
  - **Why it matters:** Single points of failure affect availability.
  - **How to validate:** Review the redundancy design with the administrator; validate only through documented, client-run failover tests, not by disabling production hardware.
  - **Expected secure result:** Documented failover keeps critical coverage available.
  - **Evidence to collect:** Redundancy design notes and any client-provided failover test records.

- [ ] **Monitoring alert delivery**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether alerts reach the right team promptly.
  - **Why it matters:** Alerts that no one receives provide no protection.
  - **How to validate:** Confirm that the alerts generated by earlier window tests reached the responsible team.
  - **Expected secure result:** Alerts are delivered to a monitored channel in a timely manner.
  - **Evidence to collect:** Alert delivery records and recipient confirmation.

---

## F. Five GHz assessment

- [ ] **DFS channel behavior**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether APs on DFS channels behave correctly and vacate on radar detection.
  - **Why it matters:** Incorrect DFS handling can cause outages or regulatory issues.
  - **How to validate:** Observe DFS channel usage during the survey and review controller DFS event logs with the administrator.
  - **Expected secure result:** DFS channels are used appropriately and channel changes are handled cleanly.
  - **Evidence to collect:** Survey notes on DFS channels and relevant controller log entries.

- [ ] **Channel congestion (5 GHz)**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** How crowded the 5 GHz channels are in the environment.
  - **Why it matters:** Congestion degrades performance and reliability.
  - **How to validate:** Record the number of networks per channel from an airodump-ng or `iw` scan.
  - **Expected secure result:** Channel distribution avoids heavy overlap given the local conditions.
  - **Evidence to collect:** Per-channel network counts from the scan.

- [ ] **Channel width (5 GHz)**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** The channel widths configured on 5 GHz radios.
  - **Why it matters:** Overly wide channels in dense areas increase interference.
  - **How to validate:** Read channel width per BSSID from `iw dev <iface> scan` or a radiotap capture.
  - **Expected secure result:** Width suits the density and matches the design.
  - **Evidence to collect:** Scan or capture output showing width per 5 GHz BSSID.

- [ ] **Coverage at edge locations**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Whether 5 GHz coverage meets needs at the edges of in-scope areas.
  - **Why it matters:** Coverage gaps push clients to weaker bands or cause drops.
  - **How to validate:** Measure coverage at edge points with wavemon or airodump-ng and note weak areas.
  - **Expected secure result:** Coverage meets the documented design at tested points.
  - **Evidence to collect:** Coverage readings with location notes.

- [ ] **RSSI readings**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Received signal strength at representative client locations.
  - **Why it matters:** Low RSSI leads to poor throughput and roaming problems.
  - **How to validate:** Record RSSI with wavemon or `iw` at chosen points.
  - **Expected secure result:** RSSI meets the design threshold at tested locations.
  - **Evidence to collect:** RSSI values with location references.

- [ ] **Signal-to-noise ratio (SNR)**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** The SNR at representative locations.
  - **Why it matters:** Low SNR causes retransmissions and reduced throughput even with adequate signal.
  - **How to validate:** Read signal and noise figures from wavemon or `iw` and compute SNR.
  - **Expected secure result:** SNR meets the design threshold at tested points.
  - **Evidence to collect:** Signal and noise readings with calculated SNR.

- [ ] **Interference sources**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Presence of non-Wi-Fi or adjacent-network interference.
  - **Why it matters:** Interference degrades performance and can be hard to diagnose later.
  - **How to validate:** Note suspected interference from survey observations and, where available, from the controller spectrum view provided by the administrator.
  - **Expected secure result:** No significant unmanaged interference in the tested areas.
  - **Evidence to collect:** Survey notes and any spectrum data supplied by the client.

- [ ] **Roaming behavior**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** How a client transitions between APs while moving.
  - **Why it matters:** Poor roaming causes drops for voice and mobile use.
  - **How to validate:** Walk a route with a test client and observe BSSID transitions in a capture or with `iw event`.
  - **Expected secure result:** Clients roam smoothly without excessive drops.
  - **Evidence to collect:** Capture or event log of the BSSID transitions along the route.

- [ ] **Throughput (indicative)**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Indicative throughput at representative locations.
  - **Why it matters:** Throughput shortfalls affect usability.
  - **How to validate:** Run an agreed throughput test between a test client and an authorized endpoint, following the rules of engagement.
  - **Expected secure result:** Throughput meets the agreed baseline at tested points.
  - **Evidence to collect:** Throughput results with location and method notes.

- [ ] **Packet loss**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Packet loss at representative locations.
  - **Why it matters:** Loss harms real-time applications and signals coverage or interference issues.
  - **How to validate:** Measure loss with an agreed reachability test from the test client to an authorized endpoint.
  - **Expected secure result:** Packet loss stays within the agreed threshold.
  - **Evidence to collect:** Loss measurements with location and method notes.

---

## G. Reporting

- [ ] **Evidence organized per finding**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Each finding has its supporting evidence attached and labeled.
  - **Why it matters:** Findings must be reproducible and defensible.
  - **How to validate:** Confirm every finding references its captures, logs, or screenshots with timestamps.
  - **Expected secure result:** All findings are backed by clear, labeled evidence.
  - **Evidence to collect:** An evidence index mapping each finding to its artifacts.

- [ ] **Risk ratings assigned**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Each finding carries a consistent risk rating.
  - **Why it matters:** Ratings help the client prioritize remediation.
  - **How to validate:** Apply the agreed rating method (for example likelihood and impact) uniformly across findings.
  - **Expected secure result:** Ratings are consistent and justified.
  - **Evidence to collect:** Rating rationale recorded for each finding.

- [ ] **Clear finding descriptions**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Each finding is described in plain, specific language.
  - **Why it matters:** Readers of varying backgrounds must understand the issue.
  - **How to validate:** Review each description for clarity, affected assets, and reproducibility.
  - **Expected secure result:** Descriptions are clear, specific, and accurate.
  - **Evidence to collect:** The drafted finding text for peer review.

- [ ] **Business impact stated**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Each finding explains the impact in business terms.
  - **Why it matters:** Impact framing drives the decision to remediate.
  - **How to validate:** Confirm each finding links the technical issue to a concrete business consequence.
  - **Expected secure result:** Impact is explained in terms the client can act on.
  - **Evidence to collect:** Impact statements reviewed with the client contact.

- [ ] **Remediation guidance provided**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** Each finding includes practical remediation steps.
  - **Why it matters:** Actionable guidance speeds fixes.
  - **How to validate:** Confirm guidance is specific to the environment and realistic to implement.
  - **Expected secure result:** Remediation steps are clear, prioritized, and feasible.
  - **Evidence to collect:** Remediation section reviewed for completeness.

- [ ] **Retest plan agreed**. Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
  - **What to check:** A plan to retest fixed findings is agreed with the client.
  - **Why it matters:** Retesting confirms that remediation worked.
  - **How to validate:** Confirm scope, timing, and criteria for the retest with the client.
  - **Expected secure result:** A documented retest plan exists and is accepted.
  - **Evidence to collect:** Retest plan reference and client acknowledgement.

---

## Sign-off

- Tester: ________________________________________
- Date: __________________________________________
- Scope reference: ________________________________
- Overall status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
