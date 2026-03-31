Feature: CAMARA Consent Management API, vwip - Operation updateConsent

  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  # * Scope required: consent-management:update
  # * consentId: identifier of an existing User Consent in a state that allows the requested status transition
  #
  # Testing assets:
  # * A valid consentId identifying an existing User Consent that can be updated to GRANTED status
  # * A valid consentId identifying an existing User Consent that can be updated to DENIED status
  # * A valid consentId identifying an existing User Consent with an expiration date set
  # * A consentId value that does not identify any existing User Consent
  #
  # References to OAS spec schemas refer to schemas specified in consent-management.yaml

  Background: Common updateConsent setup
    Given an environment at "apiRoot"
    And the resource "/consent-management/vwip/consents/{consentId}"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/UpdateConsentRequestBody"

  # Success scenarios

  @consent_management_updateConsent_01_success
  Scenario Outline: Update Consent status successfully
    Given a valid "consentId" identifying an existing User Consent that allows transition to "<consentStatus>"
    And the request body property "$.consentStatus" is set to "<consentStatus>"
    When the request "updateConsent" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/UpdateConsentResponseBody"
    And the response property "$.consentId" matches the requested consentId
    And the response property "$.creationDate" is present

    Examples:
      | consentStatus |
      | GRANTED       |
      | DENIED        |

  @consent_management_updateConsent_02_expirationDate_present
  Scenario: The expirationDate is present in the response when the User Consent has an expiration date set
    Given a valid "consentId" identifying an existing User Consent with an expiration date set
    And the request body property "$.consentStatus" is set to "GRANTED"
    When the request "updateConsent" is sent
    Then the response status code is 200
    And the response body complies with the OAS schema at "#/components/schemas/UpdateConsentResponseBody"
    And the response property "$.consentId" is present
    And the response property "$.creationDate" is present
    And the response property "$.expirationDate" is present and its value is in the future

  # Generic 400 errors

  @consent_management_updateConsent_400.1_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "updateConsent" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_updateConsent_400.2_missing_consentStatus
  Scenario: Missing required field consentStatus
    Given the request body property "$.consentStatus" is not included
    When the request "updateConsent" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_updateConsent_400.3_consentStatus_invalid_value
  Scenario: The consentStatus field has an invalid value
    Given the request body property "$.consentStatus" is set to a value not in the allowed enum ["GRANTED", "DENIED"]
    When the request "updateConsent" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_updateConsent_400.4_x_correlator_not_compliant
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" is set to a value which is not compliant with the schema at "#/components/schemas/XCorrelator"
    And the request body is set to a valid request body
    When the request "updateConsent" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Generic 401 errors

  @consent_management_updateConsent_401.1_no_authorization_header
  Scenario: No Authorization header
    Given the header "Authorization" is removed
    And the request body is set to a valid request body
    When the request "updateConsent" is sent
    Then the response status code is 401
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @consent_management_updateConsent_401.2_expired_access_token
  Scenario: Expired access token
    Given the header "Authorization" is set to an expired access token
    And the request body is set to a valid request body
    When the request "updateConsent" is sent
    Then the response status code is 401
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @consent_management_updateConsent_401.3_invalid_access_token
  Scenario: Invalid access token
    Given the header "Authorization" is set to an invalid access token
    And the request body is set to a valid request body
    When the request "updateConsent" is sent
    Then the response status code is 401
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @consent_management_updateConsent_403.1_invalid_token_permissions
  Scenario: Inconsistent access token permissions
    # To test this scenario, it will be necessary to obtain a token without the required scope
    Given the header "Authorization" is set to an access token without the required scope
    And the request body is set to a valid request body
    When the request "updateConsent" is sent
    Then the response status code is 403
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @consent_management_updateConsent_404.1_consent_not_found
  Scenario: Consent ID not found
    Given the path parameter "consentId" is set to a value that does not exist
    When the request "updateConsent" is sent
    Then the response status code is 404
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
