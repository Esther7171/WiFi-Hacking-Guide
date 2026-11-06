# Wireless Assessment: Final Report Template

Purpose: a reusable template for writing up the results of an authorized Wi-Fi penetration test or wireless assessment. Copy this file per engagement and fill in each section. Replace guidance text in brackets.

## Executive Summary

[One to three short paragraphs for a non-technical reader. Cover: what was assessed, over what period, the overall security posture in plain language, the most important themes (for example, authentication strength, segmentation, rogue-AP exposure), and the headline count of findings by severity.]

Summary of findings by severity:

| Severity | Count |
| --- | --- |
| Critical | |
| High | |
| Medium | |
| Low | |
| Informational | |

Key themes:
- [Theme 1, for example: enterprise authentication is strong but client certificate validation is inconsistent.]
- [Theme 2]
- [Theme 3]

## Scope and Methodology

**Authorization:** [Reference to the signed authorization, requesting party, and date. Testing was performed only within the authorized scope.]

**Scope:**
- In scope: [sites, SSIDs, bands, client types, or systems covered.]
- Out of scope: [anything explicitly excluded.]
- Testing window: [dates and times.]
- Constraints: [adapter limits, regulatory-domain gaps, change-freeze windows, or other limitations that affected coverage.]

**Approach:** [Describe the method at a high level: passive discovery, signal and spectrum assessment, configuration review, rogue and evil-twin detection in a lab context, and hardening verification. Note that any impersonation testing used lab-only labelled SSIDs and synthetic identities.]

**Tools and techniques:** [List the tools and methods used, for example passive scanning, beacon and frame decoding, throughput and loss measurement, and configuration review. Name tools honestly and note which were used where.]

## Severity Scale

| Severity | Definition |
| --- | --- |
| Critical | A weakness that is readily exploitable and leads directly to compromise of sensitive systems or data, or to broad unauthorized access. Requires urgent action. |
| High | A serious weakness that is likely exploitable and has significant impact, though it may need a specific condition or some effort. Should be remediated promptly. |
| Medium | A weakness with moderate impact or one that requires a less likely combination of conditions. Should be remediated on a planned basis. |
| Low | A minor weakness with limited impact or low likelihood of exploitation. Address as part of routine hardening. |
| Informational | An observation that is not a direct weakness but is worth noting for awareness, defence in depth, or future planning. |

## Findings

Record each finding using the block below. Keep evidence redacted so the report can be shared safely.

```
Finding ID:        [Short unique id, for example WIFI-001]
Title:             [Concise description of the issue]
Severity:          [Critical / High / Medium / Low / Informational]
Affected asset:    [SSID, AP, controller, RADIUS server, VLAN, or client scope]
Description:       [What the issue is, in clear terms]
Root cause:        [Why the issue exists: misconfiguration, default setting, missing control, legacy support]
Evidence (redacted): [What was observed and the artifact produced, for example a decoded beacon, a scan listing, or a config extract, with identifiers redacted]
Expected result:   [What a secure configuration or behaviour would look like]
Actual result:     [What was actually observed]
Business impact:   [What the issue could mean for the organisation if left unaddressed]
Remediation:       [Specific, actionable steps to fix the issue]
Retest status:     [NOT TESTED / PASS / FAIL / N/A / NEEDS REVIEW, with date when retested]
```

### Worked Example (SAMPLE)

The following finding is a SAMPLE using a synthetic case for illustration only. It does not describe a real environment, network, or result.

```
Finding ID:        WIFI-001 (SAMPLE)
Title:             Client profiles do not enforce RADIUS server-certificate validation
Severity:          High
Affected asset:    Enterprise SSID "LAB-CORP-WIFI" (sample), managed laptop fleet (sample)
Description:       Managed client Wi-Fi profiles for the enterprise SSID are configured
                   without strict server-certificate validation. The profile does not pin
                   the expected certificate authority or server name, and allows a
                   prompt-to-trust fallback.
Root cause:        The client profile was deployed from a template that left certificate
                   validation optional, and the setting was never hardened.
Evidence (redacted): Export of the sample client Wi-Fi profile showing the validation option
                   disabled, with device identifiers redacted. In an isolated lab, a client
                   with this profile completed authentication against a test access point
                   broadcasting a labelled test SSID and presenting an untrusted certificate,
                   using the synthetic identity testuser@lab.example.
Expected result:   Clients validate the RADIUS server certificate, the expected CA, and the
                   server name, and refuse authentication against unknown certificates with no
                   user override.
Actual result:     The sample client did not enforce validation and proceeded against the
                   untrusted test server in the lab.
Business impact:   An impersonating access point could induce clients to send enterprise
                   credentials to an attacker-controlled server, enabling account compromise.
Remediation:       Update the deployed client Wi-Fi profiles to require certificate and
                   server-name validation, pin the trusted CA, and remove the prompt-to-trust
                   fallback. Re-deploy through management tooling and confirm on a sample host.
Retest status:     NOT TESTED
```

## Retesting

After remediation, retest each finding and update its Retest status with the date and outcome. A finding is only closed when a retest confirms the expected secure result. Record any finding that could not be retested, with the reason (for example, change-freeze or access limitation), so residual risk is clear. Keep the original finding text intact and add the retest outcome rather than overwriting it, so the engagement history remains auditable.

## Appendices

- Appendix A: Detailed scope and asset inventory.
- Appendix B: Tool output and capture references (redacted).
- Appendix C: Supporting configuration extracts (redacted).
