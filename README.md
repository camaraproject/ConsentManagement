<a href="https://github.com/camaraproject/ConsentManagement/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/camaraproject/ConsentManagement?style=plastic"></a>
<a href="https://github.com/camaraproject/ConsentManagement/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/camaraproject/ConsentManagement?style=plastic"></a>
<a href="https://github.com/camaraproject/ConsentManagement/pulls" title="Open Pull Requests"><img src="https://img.shields.io/github/issues-pr/camaraproject/ConsentManagement?style=plastic"></a>
<a href="https://github.com/camaraproject/ConsentManagement/graphs/contributors" title="Contributors"><img src="https://img.shields.io/github/contributors/camaraproject/ConsentManagement?style=plastic"></a>
<a href="https://github.com/camaraproject/ConsentManagement" title="Repo Size"><img src="https://img.shields.io/github/repo-size/camaraproject/ConsentManagement?style=plastic"></a>
<a href="https://github.com/camaraproject/ConsentManagement/blob/main/LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=plastic"></a>
<a href="https://github.com/camaraproject/ConsentManagement/releases/latest" title="Latest Release"><img src="https://img.shields.io/github/release/camaraproject/ConsentManagement?style=plastic"></a>
<a href="https://github.com/camaraproject/Governance/blob/main/ProjectStructureAndRoles.md" title="Sandbox API Repository"><img src="https://img.shields.io/badge/Sandbox%20API%20Repository-yellow?style=plastic"></a>

# ConsentManagement

Sandbox API Repository to describe, develop, document, and test the ConsentManagement Service API(s) within the Working Group [Identity And Consent Management](https://lf-camaraproject.atlassian.net/wiki/spaces/CAM/pages/14561383/Identity+Consent+Management).

* API Repository [wiki page](https://lf-camaraproject.atlassian.net/wiki/x/WgDDH)

## Scope

* Service API(s) “ConsentManagement” (see APIBacklog.md) 
* The API(s) provide(s) the API consumer with the ability to:  
  * **Create Consent**: Allows API Consumers to create a new Consent for a User, specifying the requested scope(s) and Purpose. The API Consumer must provide the necessary information to capture the User's Consent.
  * **Update Consent**: Enables API Consumers to update an existing Consent and change its status.
  * **Retrieve Consent Information**: Allows API Consumers to retrieve information about existing Consents for a User based on specified scope(s) and Purpose. This operation can also return the Consent texts presented to the User during the Consent Capture process if requested.

    It is important to note that the API Provider remains fully responsible for Consent storage, auditing and transparency. Access to this functionality is restricted to trusted API Consumers in accordance with the API Provider's policy. This API only applies to scenarios involving the legal basis of Consent. Scenarios involving a different legal basis for data processing are excluded and would be handled by the API Provider through non-delegated mechanisms.
* Describe, develop, document, and test the API(s)
* Started: December 2025
<!-- * Incubating stage since: {{incubation date}} --> 

<!-- CAMARA:RELEASE-INFO:START -->
<!-- The following section is automatically maintained by the CAMARA project-administration tooling: https://github.com/camaraproject/project-administration -->

## Release Information

> [!NOTE]
> This repository has only pre-release versions available yet. Pre-releases are for testing and may change before public release.

* The latest pre-release is [r1.1](https://github.com/camaraproject/ConsentManagement/releases/tag/r1.1) (release candidate), with the following API versions:
  * **consent-management 0.1.0-rc.1**
  [[YAML]](https://github.com/camaraproject/ConsentManagement/blob/r1.1/code/API_definitions/consent-management.yaml)  [[ReDoc]](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ConsentManagement/r1.1/code/API_definitions/consent-management.yaml&nocors)  [[Swagger]](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ConsentManagement/r1.1/code/API_definitions/consent-management.yaml)

* For changes see [CHANGELOG](https://github.com/camaraproject/ConsentManagement/tree/main/CHANGELOG)

_The above section is automatically synchronized by CAMARA project-administration._
<!-- CAMARA:RELEASE-INFO:END -->

## Contributing

* Meetings are held virtually 

  * Schedule: Every 2 weeks on Wednesdays at 14:00 UTC (IdentityAndConsentManagement Working Group meeting)
  * [Registration / Join](https://zoom-lfx.platform.linuxfoundation.org/meeting/94629188836?password=278b4c8a-f370-43bf-bac1-b30a39f169f3)
  * Minutes: Access [meeting minutes](https://lf-camaraproject.atlassian.net/wiki/x/lE7e)
  * Subscribe / Unsubscribe to the mailing list <https://lists.camaraproject.org/g/wg-icm>.
  * A message to the community of the Working Group can be sent using <wg-icm@lists.camaraproject.org>.
