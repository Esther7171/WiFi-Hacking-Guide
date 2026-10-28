# WPA2-Enterprise / 802.1X Penetration Testing

> **Authorised testing only.** This covers testing a WPA2-Enterprise (802.1X / EAP) network you own or have **written permission** to assess, inside an agreed scope and test window. The impersonation and credential-capture steps below collect real staff credentials, so they are among the most sensitive things you can do on an engagement: get them named explicitly in the rules-of-engagement, store any captured material encrypted, and destroy it after reporting. See the [legal section in the main guide](../README.md#legal-and-ethics).

WPA2-Personal uses one shared passphrase (PSK). **WPA2-Enterprise** instead authenticates each user individually against a **RADIUS** server using **802.1X / EAP**, usually with a username and password (PEAP or EAP-TTLS) or a client certificate (EAP-TLS). There is no shared WiFi password to crack. The test is different, and so is the main weakness.

**The single most important flaw to test for:** whether client devices **validate the RADIUS server certificate**. If a laptop or phone will hand its credentials to any AP that advertises the right SSID, an attacker can stand up a fake AP plus a fake RADIUS server, and the client will authenticate *to the attacker* and leak its username and an MSCHAPv2 challenge/response that can be cracked offline. Almost every real WPA2-Enterprise finding traces back to this one misconfiguration.

---

## The testing workflow

### 1. Scope and authorisation (purpose: stay legal and safe)
Agree in writing which SSID/RADIUS realm is in scope, the test window, whether credential capture is permitted, and how captured credentials are handled and destroyed. Confirm you will not disrupt production authentication during business hours.
- **Tool:** the signed rules-of-engagement document. Nothing starts without it.

### 2. Identify the network and EAP method (purpose: know what you are testing)
Confirm the target is 802.1X and find which EAP method it uses. PEAP and EAP-TTLS (password-based) are attackable via impersonation; EAP-TLS (client certificates) is not credential-phishable and changes the whole approach.
- **Tools:**
  ```bash
  sudo airodump-ng wlan0mon --band abg          # find the SSID, BSSID, channel, confirm WPA2 MGT (Enterprise)
  sudo crEAP -i wlan0mon                         # passively identify EAP types and usernames in the air
  sudo eapeak -f capture.pcap                    # parse a capture for EAP methods and identities
  ```
  In airodump, the `AUTH` column shows **MGT** for Enterprise (versus **PSK** for Personal).

### 3. Harvest valid usernames (purpose: targeting and spraying)
EAP identities (usernames) are often sent in the clear in the outer identity. Collecting them lets you later test password spraying and shows the client which usernames leak.
- **Tools:** `crEAP` and `eapeak` (above) extract usernames passively. Note them for the report; do not act on them beyond scope.

### 4. Impersonate the RADIUS server (purpose: test certificate validation, the core flaw)
Stand up a rogue AP with the target SSID and a fake RADIUS endpoint. A client that does not validate the server certificate will connect and send its MSCHAPv2 challenge/response, which you capture. This is the heart of a WPA2-Enterprise test.
- **Tools:**
  ```bash
  # eaphammer: the modern all-in-one (generates certs, runs the rogue AP + RADIUS, logs creds)
  sudo ./eaphammer --cert-wizard                                  # one-time: build the fake cert
  sudo ./eaphammer -i wlan0 --channel 6 --auth wpa-eap \
       --essid CorpWiFi --creds                                   # rogue AP, capture credentials

  # hostapd-wpe: the classic alternative
  sudo hostapd-wpe /etc/hostapd-wpe/hostapd-wpe.conf
  ```
  A captured result looks like a username plus an MSCHAPv2 `challenge` and `response`. **If no client connects, that is a pass:** it means certificate validation is enforced. Record it as such.

### 5. Crack the captured MSCHAPv2 (purpose: prove the password is recoverable)
A captured challenge/response can be cracked offline to recover the user's password, or (for MSCHAPv2) the NT hash via a guaranteed DES break. This is done away from the target.
- **Tools:**
  ```bash
  asleap -C <challenge> -R <response> -W /usr/share/wordlists/rockyou.txt   # wordlist crack
  hashcat -m 5500 captured.hash /usr/share/wordlists/rockyou.txt            # NETNTLMv1 / MSCHAPv2
  ```
  Recovering even one password that then works on email or VPN is the finding that lands the report.

### 6. Password spraying against 802.1X (purpose: test password policy and lockout)
With valid usernames and a common password, test whether the 802.1X front end allows online guessing and whether lockout fires. Keep attempts low and in the agreed window to avoid locking real staff out.
- **Tool:**
  ```bash
  sudo python3 air-hammer.py -i wlan0 -e CorpWiFi -u users.txt -p 'Winter2026!'
  ```

### 7. EAP-TLS environments (purpose: adjust when passwords are not in play)
If the network uses EAP-TLS (client certificates), impersonation will not harvest passwords. Pivot to: certificate issuance and revocation process, whether private keys are exportable from clients, device-vs-user cert scoping, and whether a stolen device grants network access. This is a process and endpoint review more than a radio attack.
- **Tools:** `wpa_supplicant`/profile review on a sample client, and certificate-store inspection on the endpoint.

### 8. Detection and defence (purpose: the deliverable)
Every step above has a defence. This is what the client pays for.
- **Detection:** a wireless IDS (Kismet, nzyme) flags a second AP advertising the corporate ESSID with a different BSSID, and RADIUS logs show authentication attempts against an unknown NAS. See [how the blue team detects it](../README.md#how-the-blue-team-detects-it).
- **Fixes to recommend:**
  - **Enforce server-certificate validation on every client** (validate CN/SAN and pin the internal CA). This single setting defeats the impersonation attack.
  - **Prefer EAP-TLS** (mutual certificate auth) over PEAP/TTLS-MSCHAPv2 where feasible.
  - **Use a dedicated private CA** for RADIUS, never a public one, so clients can pin it.
  - **Enforce lockout and strong password policy** at the RADIUS/identity layer.
  - **Enable 802.11w (PMF)** and segment the WLAN as in the [main hardening list](../README.md#hardening-and-defence).

---

## Professional checklist

Copy this into the engagement notes and tick each item.

```
WPA2-ENTERPRISE / 802.1X TEST CHECKLIST
[ ] Written authorisation and scope signed (SSID, realm, window, creds handling)
[ ] Target confirmed as 802.1X (airodump AUTH = MGT)
[ ] EAP method identified (PEAP / EAP-TTLS / EAP-TLS / EAP-FAST)
[ ] Outer-identity usernames harvested (crEAP / eapeak)
[ ] Rogue AP + fake RADIUS stood up (eaphammer / hostapd-wpe)
[ ] Client certificate-validation behaviour recorded (connected = FAIL, refused = PASS)
[ ] MSCHAPv2 challenge/response captured (if any client connected)
[ ] Offline crack attempted (asleap / hashcat -m 5500)
[ ] Password spray tested within scope, lockout behaviour noted (air-hammer)
[ ] EAP-TLS cert process reviewed (if applicable)
[ ] IDS / RADIUS-log detection validated with the blue team
[ ] All captured credentials stored encrypted and scheduled for destruction
[ ] Findings, evidence, and remediation written up
```

## Reporting format

One block per finding. Keep it factual, evidence-backed, and tied to a fix.

```
FINDING: <short title, e.g. "Clients do not validate RADIUS server certificate">
SEVERITY: Critical / High / Medium / Low / Informational
AFFECTED: <SSID, client platforms, user groups observed>

DESCRIPTION:
<What the weakness is, in plain language. e.g. Windows clients on CorpWiFi
accept any RADIUS server presenting the SSID, with no CA validation enforced
by GPO.>

EVIDENCE:
<Redacted proof: captured username(s) with the password masked, a screenshot
of the rogue-AP log, timestamps. Never print full plaintext credentials in
the report body.>

IMPACT:
<What an attacker gains. e.g. Any attacker in RF range can capture and crack
domain credentials, which also grant VPN and email access.>

LIKELIHOOD:
<How easy and how likely. e.g. Trivial: a laptop and a $30 adapter in the
car park, no prior access needed.>

REMEDIATION:
<Specific, actionable. e.g. Deploy GPO/MDM profile enforcing server-cert
validation against the internal CA (CN: radius.corp.local); migrate to
EAP-TLS within two quarters; enable account lockout at 5 attempts.>

STATUS: Open
```

### Severity guidance
- **Critical** credentials captured and cracked, no cert validation (full domain-credential exposure)
- **High** cert validation off but crack not completed in the window, or weak password policy with no lockout
- **Medium** usernames leak in outer identity, PEAP-MSCHAPv2 in use but validation enforced
- **Informational** EAP-TLS enforced and validated correctly (document the good posture too)

---

*Written as educational and defensive security material for authorised assessments. Red-team findings exist to drive the blue-team fixes above.*
