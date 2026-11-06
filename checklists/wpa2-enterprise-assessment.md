# WPA2-Enterprise (802.1X / EAP) Assessment Checklist

Purpose: a detailed, authorized checklist for assessing WPA2-Enterprise networks that use 802.1X with EAP and a RADIUS backend.

This checklist is for in-scope, authorized, or lab use only. Impersonation, handshake analysis, and credential cracking steps use clearly labelled lab SSIDs, test identities, and supplied or synthetic captures, never real employee sessions or production identities. All captures and recovered material are stored encrypted and destroyed after reporting. Do not run sustained-disruption activity against production networks.

**Status values:**
- `PASS`: the item was validated and meets the secure or expected state.
- `FAIL`: the item was validated and does not meet the secure or expected state.
- `N/A`: the item does not apply to this environment or scope.
- `NOT TESTED`: the item was in scope but has not yet been assessed.
- `NEEDS REVIEW`: results are inconclusive and require a second look or client input.

> **Most sensitive step:** AP or RADIUS impersonation (rogue authenticator) testing is the most sensitive activity in this checklist. It must run only against test identities on a clearly labelled lab SSID, never against real employees or production credentials. Confirm written authorization, isolate the test radio, and stop immediately if any non-test client associates.

---

## EAP Method Identification

- [ ] **Identify the EAP method(s) in use**  Status: `NOT TESTED`
  - **What to check:** Which EAP methods the network negotiates (PEAP, EAP-TTLS, EAP-TLS, EAP-FAST), including any fallback.
  - **Why it matters:** The EAP method determines the trust model. Password-based methods (PEAP, EAP-TTLS, EAP-FAST) depend on server certificate validation, while EAP-TLS uses mutual certificates.
  - **How to validate:** Observe the EAP negotiation in a passive capture, or review RADIUS and supplicant configuration. For lab validation, inspect the EAP Request/Identity and method-type frames in a pcap.
  - **Expected secure result:** A strong method is in use (EAP-TLS preferred, or PEAP/EAP-TTLS with enforced server validation), with no weak fallback.
  - **Evidence to collect:** pcap of the EAP exchange and configuration screenshots of the supplicant profile.

## RADIUS Configuration

- [ ] **Review RADIUS server configuration and placement**  Status: `NOT TESTED`
  - **What to check:** RADIUS server roles, redundancy, network placement, and which authenticators (APs/controllers) are authorized clients.
  - **Why it matters:** Misconfigured RADIUS clients or exposed servers can allow unauthorized authenticators or weaken the authentication path.
  - **How to validate:** Review RADIUS server configuration, the NAS/client list, and network segmentation with the client. Confirm only authorized APs and controllers are defined as clients.
  - **Expected secure result:** RADIUS is segmented, redundant, and only trusted authenticators are configured.
  - **Evidence to collect:** Configuration export (secrets redacted), RADIUS client list screenshot, and a network placement note.

## Server Certificate Validity and Chain

- [ ] **Validate the RADIUS server certificate and its chain**  Status: `NOT TESTED`
  - **What to check:** That the server presents a certificate issued by a trusted CA with a complete, valid chain and correct subject/SAN.
  - **Why it matters:** The server certificate is the anchor of trust for password-based EAP. A broken or self-signed chain erodes that trust.
  - **How to validate:** Inspect the server certificate from the EAP-TLS tunnel setup in a pcap, or review it on the RADIUS server, and verify the chain to a trusted root.
  - **Expected secure result:** A valid certificate from a trusted CA with a complete chain and correct name fields.
  - **Evidence to collect:** Exported certificate details, chain validation output, and a pcap of the certificate exchange.

## Client Server-Certificate Validation Behaviour (Core Flaw)

- [ ] **Test whether clients validate the RADIUS server certificate**  Status: `NOT TESTED`
  - **What to check:** Whether a test client, using a test identity on a clearly labelled lab SSID, will complete authentication against an untrusted or substituted server certificate.
  - **Why it matters:** This is the core WPA2-Enterprise flaw. If clients do not validate the server certificate, an impersonating authenticator can harvest inner credentials. Correct behavior is the client refusing to connect.
  - **How to validate:** In the lab only, stand up a test authenticator presenting a non-trusted certificate and observe the test client. **Connected = FAIL** (the client did not validate). **Refused / rejected = PASS** (the client validated and declined). Use only test identities.
  - **Expected secure result:** The test client refuses to authenticate to the untrusted server (`PASS`), confirming certificate validation and trusted-CA pinning are enforced via managed profiles.
  - **Evidence to collect:** Screenshot of the client refusal or error, the test authenticator log, and a pcap showing the aborted exchange.

## Certificate Expiry

- [ ] **Check server certificate expiry and renewal process**  Status: `NOT TESTED`
  - **What to check:** The certificate validity window and the organization's renewal and monitoring process.
  - **Why it matters:** An expired certificate can cause outages and, if handled by loosening validation, can degrade security.
  - **How to validate:** Read the notBefore/notAfter fields from the certificate and confirm a renewal and alerting process with the client.
  - **Expected secure result:** The certificate is within its validity window, with a tracked renewal process well ahead of expiry.
  - **Evidence to collect:** Certificate validity screenshot and renewal process note.

## Certificate Revocation (CRL / OCSP)

- [ ] **Verify certificate revocation checking**  Status: `NOT TESTED`
  - **What to check:** Whether CRL or OCSP endpoints are published and whether revocation is checked in the trust path.
  - **Why it matters:** Without revocation checking, a compromised certificate remains trusted until expiry.
  - **How to validate:** Inspect the CRL distribution point and OCSP (AIA) fields in the certificate, and confirm the validation process with the client PKI team.
  - **Expected secure result:** Revocation endpoints are published and reachable, and revocation is considered in the trust decision.
  - **Evidence to collect:** Certificate extension details and notes on revocation process.

## Identity Mapping and Outer-Identity Exposure

- [ ] **Assess outer identity and identity privacy**  Status: `NOT TESTED`
  - **What to check:** Whether the outer (cleartext) identity exposes real usernames, and whether an anonymous outer identity is used.
  - **Why it matters:** The outer identity is visible before the TLS tunnel forms. Exposing real usernames aids targeting and enumeration.
  - **How to validate:** Observe the EAP Response/Identity (outer identity) in a pcap and compare it to the inner identity within the tunnel. Confirm supplicant profile settings.
  - **Expected secure result:** The outer identity is anonymized (for example `anonymous@realm`), and real usernames appear only inside the encrypted tunnel.
  - **Evidence to collect:** pcap showing outer versus inner identity and supplicant configuration screenshot.

- [ ] **Review identity-to-authorization mapping**  Status: `NOT TESTED`
  - **What to check:** How authenticated identities map to users, groups, and machine accounts in the directory and RADIUS policy.
  - **Why it matters:** Loose or incorrect mapping can grant access beyond what an identity should have.
  - **How to validate:** Review RADIUS policy and directory group mappings with the client.
  - **Expected secure result:** Each identity maps to the correct least-privilege authorization.
  - **Evidence to collect:** Policy mapping export and screenshots (identifiers redacted as needed).

## Shared-Secret Strength

- [ ] **Assess the RADIUS shared-secret strength**  Status: `NOT TESTED`
  - **What to check:** The length and randomness of the shared secret between each authenticator and the RADIUS server.
  - **Why it matters:** A weak shared secret undermines the integrity of the RADIUS exchange and can be targeted offline if captured.
  - **How to validate:** Confirm the secret length and generation method through configuration review and interview. Do not transmit or expose the secret value.
  - **Expected secure result:** Long, random, unique shared secrets per authenticator.
  - **Evidence to collect:** Policy statement and configuration note confirming length and uniqueness (value redacted).

## Dynamic VLAN Assignment

- [ ] **Verify dynamic VLAN assignment behaviour**  Status: `NOT TESTED`
  - **What to check:** Whether RADIUS returns VLAN attributes to place authenticated devices into the correct network segment.
  - **Why it matters:** Dynamic VLANs enforce segmentation. Misassignment can place devices on more privileged segments than intended.
  - **How to validate:** Review RADIUS policy for VLAN attributes and, with a test identity, confirm the assigned VLAN matches policy. Inspect the RADIUS Access-Accept attributes in a log or lab capture.
  - **Expected secure result:** Each identity lands on its intended VLAN with no privilege escalation.
  - **Evidence to collect:** RADIUS log showing VLAN attributes and a segmentation verification note.

## Authorization Rules

- [ ] **Review authorization and network-access policy rules**  Status: `NOT TESTED`
  - **What to check:** The conditions (identity, device, posture, time, location) that grant or deny access.
  - **Why it matters:** Overly broad authorization rules weaken the value of strong authentication.
  - **How to validate:** Review the RADIUS policy rule set with the client and confirm least-privilege and default-deny behavior.
  - **Expected secure result:** Rules are least-privilege, default-deny, and consistent with documented access policy.
  - **Evidence to collect:** Policy rule export and review notes.

## Authentication Logging

- [ ] **Confirm authentication logging and retention**  Status: `NOT TESTED`
  - **What to check:** Whether successful and failed authentications are logged, forwarded, and retained.
  - **Why it matters:** Logging supports detection, investigation, and demonstrates that impersonation attempts would be visible.
  - **How to validate:** Review RADIUS logs, confirm forwarding to central logging/SIEM, and verify a test authentication appears with expected detail.
  - **Expected secure result:** Authentications are logged with sufficient detail, forwarded centrally, and retained per policy.
  - **Evidence to collect:** Sample RADIUS log entries (identifiers redacted) and a logging configuration screenshot.

## Guest and Network Isolation

- [ ] **Verify guest and inter-client isolation**  Status: `NOT TESTED`
  - **What to check:** Whether guest networks are isolated from corporate segments and whether client isolation is enforced where required.
  - **Why it matters:** Poor isolation lets a compromised or untrusted device reach sensitive segments or peer devices.
  - **How to validate:** Review segmentation and firewall rules, and confirm with a scoped connectivity check from a test device that cross-segment access is blocked.
  - **Expected secure result:** Guest traffic is isolated from corporate resources, and client isolation is enforced where policy requires.
  - **Evidence to collect:** Segmentation diagram, firewall rule export, and connectivity test notes.

## EAP-TLS Client-Certificate Lifecycle

- [ ] **Assess client-certificate issuance and enrollment**  Status: `NOT TESTED`
  - **What to check:** How client certificates are issued, who approves them, and how identity is proven at enrollment.
  - **Why it matters:** Weak issuance lets unauthorized devices or users obtain trusted certificates.
  - **How to validate:** Review the enrollment and approval process and the issuing CA policy with the client PKI team.
  - **Expected secure result:** Certificates are issued only after verified enrollment through a controlled process.
  - **Evidence to collect:** Enrollment process documentation and CA policy reference.

- [ ] **Check whether private keys are exportable**  Status: `NOT TESTED`
  - **What to check:** Whether client private keys can be exported from the device or are hardware-protected (TPM or secure element).
  - **Why it matters:** Exportable keys can be copied to unauthorized devices, defeating the certificate binding.
  - **How to validate:** Review the certificate template and device key-storage settings with the client.
  - **Expected secure result:** Private keys are marked non-exportable and, where possible, hardware-backed.
  - **Evidence to collect:** Certificate template settings and device policy screenshot.

- [ ] **Confirm device versus user certificate scoping**  Status: `NOT TESTED`
  - **What to check:** Whether certificates are scoped to devices, users, or both, consistent with the access model.
  - **Why it matters:** Incorrect scoping can grant user-level access from an unmanaged device or vice versa.
  - **How to validate:** Review certificate subject fields and RADIUS policy mapping with the client.
  - **Expected secure result:** Scoping matches the documented access model (for example machine plus user where required).
  - **Evidence to collect:** Certificate subject details and policy mapping note.

- [ ] **Review client-certificate revocation and renewal**  Status: `NOT TESTED`
  - **What to check:** How client certificates are revoked on loss or offboarding and how renewal is handled.
  - **Why it matters:** Without effective revocation, a lost or offboarded device keeps network access.
  - **How to validate:** Review the revocation process and confirm RADIUS honors CRL/OCSP for client certificates.
  - **Expected secure result:** Revocation is timely and enforced, with a tracked renewal process.
  - **Evidence to collect:** Revocation process documentation and a sample revocation record (identifiers redacted).

## Impersonation Testing (Lab-Only, Test Identities)

- [ ] **Perform rogue-authenticator impersonation in the lab only**  Status: `NOT TESTED`
  - **What to check:** Whether a test client, using a test identity on a clearly labelled lab SSID, can be induced to disclose inner credentials to an impersonating RADIUS/AP that presents an untrusted certificate.
  - **Why it matters:** This validates, in a controlled way, the client-side certificate-validation finding and demonstrates real impact if validation is absent.
  - **How to validate:** In an isolated lab, configure `eaphammer` or `hostapd-wpe` as the rogue authenticator against test identities on a clearly labelled lab SSID. Observe whether the test supplicant proceeds. Stop immediately if any non-test device associates. Never target real employees or production credentials. See the most-sensitive-step caution above.
  - **Expected secure result:** The test client validates the server certificate and refuses, so no inner credential material is disclosed.
  - **Evidence to collect:** Lab tool log, pcap of the aborted or completed exchange, and a screenshot of the client behavior. Any captured lab challenge/response is held encrypted.

- [ ] **Offline MSCHAPv2 analysis on captured lab material only**  Status: `NOT TESTED`
  - **What to check:** Whether MSCHAPv2 challenge/response material captured from the lab test identity could be recovered offline, demonstrating the weakness of password-based inner methods when server validation fails.
  - **Why it matters:** MSCHAPv2 is susceptible to offline analysis, reinforcing why server-certificate validation and strong methods matter.
  - **How to validate:** Operate strictly on lab-captured material from test identities. Use `asleap`, or convert and run `hashcat -m 5500`, within the agreed time box. Keep all material in the encrypted engagement store.
  - **Expected secure result:** With server validation enforced, no usable challenge/response is captured, so this analysis is not possible against real identities.
  - **Evidence to collect:** Tool session log (command, runtime, result status) and a note that only lab test-identity material was used, with any recovered value redacted and the raw value held encrypted.

---

## Sign-off

- **Tester:** ____________________
- **Date:** ____________________
- **Scope reference:** ____________________
- **Overall status:** `PASS` / `FAIL` / `N/A` / `NOT TESTED` / `NEEDS REVIEW`
