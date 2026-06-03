# Changelog ConsentManagement

<!-- TOC:START -->
## Table of Contents
- [r1.1](#r11)
<!-- TOC:END -->

**Please be aware that the project will have frequent updates to the main branch. There are no compatibility guarantees associated with code in any branch, including main, until it has been released. For example, changes may be reverted before a release is published. For the best results, use the latest published release.**

The below sections record the changes for each API version in each release as follows:

* for an alpha release, the delta with respect to the previous release
* for the first release-candidate, all changes since the last public release
* for subsequent release-candidate(s), only the delta to the previous release-candidate
* for a public release, the consolidated changes since the previous public release

# r1.1

## Release Notes

This release candidate contains the definition and documentation of
* consent-management 0.1.0-rc.1

The API definition(s) are based on
* Commonalities 0.8.0
* Identity and Consent Management 0.5.0

## consent-management 0.1.0-rc.1

**consent-management 0.1.0-rc.1 is the first release candidate of the version 0.1.0**

Version 0.1.0 provides the initial API definition and documentation for the consent-management API, which is part of the Identity and Consent Management (ICM) Working Group.

- This API version provides API Consumers with the ability to:

    - **Create Consent**: Allows API Consumers to create a new Consent for a User, specifying the requested scope(s) and Purpose. The API Consumer must provide the necessary information to capture the User's Consent.
    - **Update Consent**: Enables API Consumers to update an existing Consent and change its status.
    - **Retrieve Consent Information**: Allows API Consumers to retrieve information about existing Consents for a User based on specified scope(s) and Purpose. This operation can also return the Consent texts presented to the User during the Consent Capture process if requested.

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ConsentManagement/r1.1/code/API_definitions/consent-management.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ConsentManagement/r1.1/code/API_definitions/consent-management.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/ConsentManagement/blob/r1.1/code/API_definitions/consent-management.yaml)

### Added

* Initial consent-management API definition and documentation

### Changed

### Fixed

### Removed

**Full Changelog**: https://github.com/camaraproject/ConsentManagement/commits/r1.1

