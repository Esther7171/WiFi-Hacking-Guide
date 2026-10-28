# <div align="center">**Wireless Penetration Testing Checklist**</div>
## Scope In
* APs, clients, IoT devices, printers, switches . Record MAC, vendor OUI, hostname (if resolvable), and role.
* Discover devices currently connected to wireless networks and note their association timestamps.
* Identify SSIDs (visible and hidden) and record SSID purpose (corporate, guest, IoT, captive portal).
* Verify whether the same AP/router serves 2.4 GHz and 5 GHz; document band assignments and band‑steering.
* Perform a site survey: map AP locations, antenna types, coverage overlap, dead zones, and signal bleed beyond building boundaries.
* Check for external USB or PCIe Wi‑Fi adapters in use (those that support monitor/promiscuous mode). Inventory endpoints and look for unfamiliar wireless adapter hardware (USB dongles, SDIO/PCIe cards).
* Verify Wi‑Fi encryption settings: WPA3 is recommended; if WPA2 is used, ensure AES/CCMP is enabled, TKIP is disabled, 802.11w (Management Frame Protection / PMF) is active, and any transition modes are properly configured

## Authentication
* Ensure router admin access is restricted to authorized administrators only for configuration purposes.
* Ensure all management interfaces use HTTPS; disable HTTP access.
* Ensure the gateway does not use default passwords; enforce strong password complexity (8–14 characters, at least one uppercase letter, one special character like !@#$%^, and a mix of A-Z, a-z, 0-9).
* Ensure router/AP firmware is up to date and vendor-recommended hardening is applied.
* Ensure WPS is disabled across the organization.
* Check that guest networks, employee networks, and captive portals are isolated on separate VLANs with no unintended crossover.
* Confirm **Enterprise 802.1X** (PEAP, EAP‑TLS, TTLS, FAST) is used for corporate networks where applicable.
* Review **RADIUS configuration**, server certificate validity, CA chain management, and server certificate pinning.
* Evaluate **PSK vs 802.1X** usage and verify appropriate EAP types (PEAP, EAP‑TLS, TTLS) are enforced.

### Key rotation (recommended)

| Key Type                      | NIST Recommendation                    | Rotation Period (recommended)                        |
| ----------------------------- | -------------------------------------- | ---------------------------------------------------- |
| PTK / GTK (session keys)      | Ephemeral, automatic                   | Each client session / GTK lifetime (vendor default)  |
| Master symmetric key / PSK    | Symmetric key cryptoperiod (SP 800‑57) | ≤ 1 year; rotate immediately if compromise suspected |
| RADIUS server keys / certs    | Protect master key; rotate per PKI     | 1 year recommended                                   |
| Client certificates (EAP‑TLS) | Validity per organizational policy     | 1–3 years                                            |

* Inventory **client OS and supplicant behavior**; check whether clients accept insecure EAP types or fail to validate certificates.
* Look for rogue connectors (personal APs, phone hotspots). Check client devices for enabled tethering/hostpot settings and verify whether any such devices are bridging traffic to corporate VLANs; log findings and timestamps.
* Validate **separation of management and production planes**: confirm AP management interfaces are not reachable from untrusted networks, and ensure SNMP, SSH, and Telnet are securely configured.SNMP hardening — disable SNMPv1/v2 where possible; require SNMPv3 or remove SNMP if unused.
* PMF / 802.11w enforcement check — ensure PMF is enforced where supported and document clients that don’t support it.
* Test for WEP traffic and attempt to recover any captured keystreams only if explicitly authorized; document whether WEP frames exist (WEP is deprecated and should be replaced).

* If an SSID is hidden, attempt an authorized deauthentication to force client reassociation and capture the SSID/association frames for analysis; log timestamps and monitoring detections.

* Test for packet‑level attacks (e.g., Korek / chop‑chop variants) only in scope and under controlled conditions to determine whether keystream/PRGA material can be derived from captured frames; document methods used and detection/alerting behavior.
 * aireplay-ng -4 -b <AP MAC> -h <Source MAC> <interface>
  * -4: the chopchop attack
  * -b: the AP MAC address
  * -h: the source (probably your) MAC address
  * <interface>: the monitor mode interface

* Test for fragmentation attacks only with explicit authorization — attempt to generate a PRGA/XOR keystream from captured fragments to evaluate whether packet injection is possible; document capture evidence, detection/alerting, and any successful injection capability.
  * aireplay-ng -5 -b `<AP MAC>` -h `<source mac>` `<interface>`
    * `-5`: the fragmentation attack
    * `-b`: AP MAC address
    * `-h`: Source MAC address
    * `<interface>`: the monitor mode interface name. the main aim of fragmentation attack is to generate a PRGA XOR file which later can be used for packet injection.

* Test for packet injection **only with explicit authorization** — attempt to create encrypted packets for injection using a PRGA/XOR keystream derived from prior attacks (e.g., chop‑chop or fragmentation) to validate whether packet injection is possible and detected.

* Use a packet‑forging tool to build encrypted frames (ARP, ICMP, NULL, etc.) and attempt controlled injection into the target BSS.
    * packetforge-ng -0 -a `<AP MAC>` -h `<Your MAC>` -k `<Dest IP>` -l `<Source IP>` -y `<xor file>` -w `<output file>`
        * `-0`: generate an ARP  request packet
        * `-a`: the AP MAC address
        * `-h`: the source (usually yours) MAC address
        * `-k`: the destination IP i.e. in ARP, this is “Who has this IP”
        * `-l`: the source IP i.e. in ARP, this is “Tell this IP”
        * `-y`: the PRGA filename
        * `-w`: the filename to save the packet to (Note 1: if you are not sure about the source & destination IP address, you can enter 255.255.255.255 in both the souce & destination ip address field, it should work. however if you have the ip address than that's better. Note 2: aobve command is to generate ARP packet however it is also possible)
* Test for Shared key Fake authentication attack.
* Use network segmentation and NAC to limit client to client traffic.
* Deploy and tune wireless IDS/IPS signatures for rogue APs, ARP spoof, and DHCP anomalies. 
* DHCP snooping / Dynamic ARP Inspection / IP Source Guard — verify these switch features are enabled to mitigate ARP/DHCP MITM.


## Penetration testing — WPA/WPA2/WPA3 WLANs (authorized only)

* Test Deauth — perform an authorized deauthentication and verify it is recorded by the firewall, WLC/AP controller, wireless IDS/IPS, and SIEM; collect pcaps and controller logs, correlate timestamps, and document detection/alerts.  
* Test Man‑in‑the‑Middle (MITM) detection & evidence capture (authorized only)
* Conduct approved stress/DoS tests (radio or traffic‑based) in a maintenance window to evaluate failover and mitigation controls — document business impact and recovery.  
* Test MAC‑flooding behavior in a controlled test environment to evaluate AP/switch stability, iptables/firewall behavior, and CPU/memory impact.  
* Perform authorized fake‑auth/association attempts and verify whether these are logged and alerted by monitoring systems.  
* Scan for unauthorized APs and misconfigured bridge devices; document detection and response mechanisms (alerts, containment). Avoid active rogue injection unless explicitly in scope and during a safety window.  
* Verify logging retention and SIEM correlation for wireless anomalies (multiple failed authentications, sudden influx of BSSIDs, unusual association patterns); ensure wireless IDS/IPS presence or equivalent detection is enabled.  
* Check for backend service weaknesses that affect wireless security (possible DNS spoofing, unauthorized DHCP servers, weak DHCP configurations).  
* With explicit authorization, test MAC‑spoof detection by changing your host MAC to a known network MAC and verifying logs/alerts. 
* Capture EAPOL/4‑way handshakes for in‑scope networks and confirm they appear in logs/pcaps for forensic purposes; perform offline password‑strength analysis only when permitted.  
* Confirm whether legacy or weak authentication types (e.g., LEAP) are present; capture packets (pcap) and identify the EAP method in use (PEAP, EAP‑TLS, TTLS, etc.).  
* Inspect physical security: unlocked closets, exposed patch panels, and reachable external antennas that could allow tampering or unauthorized wired access.  
* Verify AP/router firmware versions and flag any outdated firmware; ensure vendor hardening and patching policies are applied.
* PMKID / hash capture tests — test PMKID extraction (hash capture) and offline cracking as an alternative to full 4‑way handshake captures.
* Spectrum analysis — run a spectrum scan (to detect non‑Wi‑Fi interference and hidden jammers).
