# 5 GHz Wireless Assessment Checklist

Purpose: a repeatable checklist for assessing the health, performance, and spectrum behaviour of a 5 GHz Wi-Fi deployment during an authorized engagement.

> Status values used throughout this checklist:
> - `PASS`: the item was validated and meets the expected secure or healthy result.
> - `FAIL`: the item was validated and does not meet the expected result.
> - `N/A`: the item does not apply to this environment (for example, a band or feature that is not deployed).
> - `NOT TESTED`: the item is in scope but has not yet been checked.
> - `NEEDS REVIEW`: a result was obtained but requires a second opinion, more data, or client confirmation before a verdict is set.

All testing assumes written authorization and a defined scope. Only scan and capture on networks and bands you are permitted to assess.

## Spectrum and Band Coverage

- [ ] **UNII band availability (UNII-1, UNII-2, UNII-2e, UNII-3)**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Which of the UNII sub-bands are in use by the deployment, and whether the access points advertise channels across the expected ranges (UNII-1 low channels, UNII-2 and UNII-2e mid channels, UNII-3 upper channels).
  - **Why it matters:** Using only a narrow slice of the 5 GHz spectrum crowds a few channels and leaves usable spectrum idle, which raises interference and lowers capacity.
  - **How to validate:** Run a passive scan with `iw dev <iface> scan` or capture beacons with kismet, then group discovered APs by channel and sub-band.
  - **Expected secure result:** Channel use is spread across available sub-bands in line with the design, with no unexplained clustering.
  - **Evidence to collect:** A channel-by-channel inventory table and the raw scan output file.

- [ ] **Regulatory domain and driver channel support**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** The regulatory domain set on the testing adapter and whether the wireless driver can scan or capture on every channel in scope (some adapters and regions restrict certain channels or DFS channels).
  - **Why it matters:** If the survey adapter cannot legally or technically see a channel, missing APs can be mistaken for good coverage or a clean band.
  - **How to validate:** Check the domain with `iw reg get` and list supported channels and allowed modes with `iw list`. Note any channels marked as no-IR, disabled, or radar-only.
  - **Expected secure result:** The adapter can observe all in-scope channels, or any gap is documented so findings account for it.
  - **Evidence to collect:** Output of `iw reg get` and the relevant channel section of `iw list`, plus a note of adapter model and driver.

- [ ] **Channel allocation and planning**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether neighbouring APs use non-overlapping channels and whether the channel plan matches the intended coverage layout.
  - **Why it matters:** Poor channel planning causes co-channel contention and reduces effective throughput even when signal looks strong.
  - **How to validate:** Build a map of AP BSSID to channel from a kismet or `iw scan` capture and compare adjacent cells.
  - **Expected secure result:** Adjacent cells reuse channels only where physical separation makes it safe, following the documented plan.
  - **Evidence to collect:** Channel reuse map and the source scan data.

## DFS and Radar Behaviour

- [ ] **Non-DFS vs DFS channel usage**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Which channels in use are DFS channels (subject to radar detection) versus non-DFS channels.
  - **Why it matters:** DFS channels can be vacated automatically when radar is detected, so a deployment that relies heavily on them may see sudden channel changes and brief client disruption.
  - **How to validate:** Classify observed channels against the DFS designations for the regulatory domain, using the channel flags from `iw list`.
  - **Expected secure result:** DFS use is intentional and the design tolerates occasional radar-driven channel changes.
  - **Evidence to collect:** A list of in-use channels tagged DFS or non-DFS.

- [ ] **Radar-avoidance (DFS) channel-change behaviour**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether APs on DFS channels perform the required listen period before transmitting and whether they move cleanly off a channel when a radar event is signalled.
  - **Why it matters:** Incorrect DFS behaviour can either break regulatory compliance or cause repeated outages.
  - **How to validate:** Observe beacon presence over time with kismet or a long `tcpdump` capture, and note any mid-session channel changes on DFS channels.
  - **Expected secure result:** APs begin transmitting only after the listen period and relocate to an alternate channel when required, with clients reconnecting promptly.
  - **Evidence to collect:** Timeline notes of beacon activity and any observed channel transitions.

## Channel Width and Spectrum Efficiency

- [ ] **Channel width selection (20/40/80/160 MHz)**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** The channel width each AP uses and whether wide channels are justified by client density and spectrum availability.
  - **Why it matters:** Very wide channels raise peak throughput but reduce the number of non-overlapping channels, which can increase interference in dense areas.
  - **How to validate:** Read the HT and VHT or HE operation elements from beacon frames in wireshark, or note the width reported by `iw dev <iface> scan`.
  - **Expected secure result:** Channel width matches the environment: wider only where spectrum and density allow, narrower in crowded areas.
  - **Evidence to collect:** Per-AP channel width list and a sample decoded beacon.

- [ ] **Co-channel and adjacent-channel interference**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** How many APs share each channel (co-channel) and whether overlapping wide channels create adjacent-channel interference.
  - **Why it matters:** Co-channel contention forces devices to share airtime, while adjacent-channel overlap raises the noise floor.
  - **How to validate:** Group discovered BSSIDs by channel and width using kismet output, and review retry and airtime indicators in a wireshark capture.
  - **Expected secure result:** Co-channel counts are within the design target and no avoidable adjacent overlap is present.
  - **Evidence to collect:** Co-channel grouping table and interference notes.

## Signal and Link Quality

- [ ] **RSSI (received signal strength)**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Signal strength at representative client locations across the coverage area.
  - **Why it matters:** Weak RSSI leads to low data rates, retries, and dropped sessions.
  - **How to validate:** Read live RSSI with wavemon or `iw dev <iface> link` at each survey point and record the value with its location.
  - **Expected secure result:** RSSI meets the design threshold (for example, the client target set for the environment) at all intended coverage points.
  - **Evidence to collect:** Location-tagged RSSI readings and a note of the measurement device.

- [ ] **Signal-to-noise ratio (SNR)**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** The margin between signal and the local noise floor at each survey point.
  - **Why it matters:** A strong signal with a high noise floor still performs poorly, so SNR is a better predictor of real throughput than RSSI alone.
  - **How to validate:** Observe signal and noise with wavemon or derive SNR from captured radiotap headers in wireshark.
  - **Expected secure result:** SNR stays above the threshold needed for the intended data rate in each area.
  - **Evidence to collect:** SNR readings per location and the captured noise-floor figures.

- [ ] **Channel congestion and airtime**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** How busy each in-use channel is, including traffic from networks outside the client estate.
  - **Why it matters:** A congested channel limits performance regardless of signal quality.
  - **How to validate:** Capture over time with tcpdump or kismet and review frame volume and retry rates per channel in wireshark.
  - **Expected secure result:** Channel busy time stays within the design budget during representative load.
  - **Evidence to collect:** Per-channel utilisation summary and capture files.

## Coverage and Roaming

- [ ] **Coverage uniformity**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether every intended area has usable 5 GHz signal, including edges, stairwells, and rooms with heavy attenuation.
  - **Why it matters:** Coverage holes push clients down to lower rates or back to 2.4 GHz, hurting performance.
  - **How to validate:** Walk the site recording RSSI and SNR with wavemon at a consistent grid of points. Commercial survey tools (NetSpot, Ekahau, Hamina, WiFi Explorer) exist and can produce heat maps, but they are optional.
  - **Expected secure result:** No unexpected coverage gaps in intended areas.
  - **Evidence to collect:** A point grid of readings, and an optional heat map if a survey tool was used.

- [ ] **Client roaming behaviour (802.11k/v/r where present)**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Whether the deployment advertises roaming assist features where relevant: neighbour reports (802.11k), BSS transition management (802.11v), and fast transition (802.11r).
  - **Why it matters:** Without roaming assistance, clients can cling to a distant AP (sticky client) and suffer poor rates, or roam slowly enough to break voice and video.
  - **How to validate:** Decode beacon and association frames in wireshark to confirm the presence of RRM, BSS transition, and FT elements, and observe a client moving between cells in a capture.
  - **Expected secure result:** Supported roaming features are advertised consistently and clients transition between APs without long interruptions.
  - **Evidence to collect:** Decoded frames showing the roaming elements and a capture of a roaming event.

## Throughput and Transport Performance

- [ ] **Throughput measurement**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Achievable upload and download throughput at representative locations.
  - **Why it matters:** Throughput is the outcome users feel and reflects the combined effect of signal, congestion, and width.
  - **How to validate:** Run `iperf3` between a client and a controlled server on the wired side, testing both TCP and UDP where appropriate.
  - **Expected secure result:** Throughput meets the agreed target at each test location.
  - **Evidence to collect:** `iperf3` result logs with location and channel noted.

- [ ] **Packet loss**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Loss rate under representative load, especially at coverage edges.
  - **Why it matters:** Loss triggers retransmissions that waste airtime and degrade real-time traffic.
  - **How to validate:** Use `iperf3` in UDP mode to report loss, and cross-check retry rates in a wireshark capture.
  - **Expected secure result:** Loss stays within the agreed tolerance across the coverage area.
  - **Evidence to collect:** UDP loss figures and retry-rate notes.

- [ ] **Latency and jitter**  (Status: `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`)
  - **What to check:** Round-trip latency and its variation, which matter for voice, video, and interactive apps.
  - **Why it matters:** High or unstable latency breaks real-time services even when average throughput is fine.
  - **How to validate:** Measure with a controlled latency test (for example, timed round-trips to a wired target) and review `iperf3` jitter output for UDP streams.
  - **Expected secure result:** Latency and jitter stay within the agreed limits during representative load.
  - **Evidence to collect:** Latency and jitter logs tied to location and channel.

## Sign-off

| Field | Detail |
| --- | --- |
| Assessor | |
| Date | |
| Scope reference | |
| Authorization reference | |
| Tools and adapter used | |
| Overall result | |
| Reviewer | |

Testing performed under written authorization only. Record any scope limitations, adapter restrictions, or regulatory-domain gaps that affected results.
