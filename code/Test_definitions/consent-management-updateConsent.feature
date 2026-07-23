Feature: CAMARA Consent Management API, v0.1.0 - Operation updateConsent

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
    And the resource "/consent-management/v0.1/consents/{consentId}"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/UpdateConsentRequestBody"
    And the path parameter "consentId" is set by default to an existing value

  ############################ Happy Path Scenarios #############################################

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

  ############################ Error Scenarios #############################################

  # Syntax Error scenarios

  @consent_management_updateConsent_400.01_schema_not_compliant
  Scenario: Invalid Argument. Generic Syntax Exception
    Given the request body is included but is not compliant with the schema at "#/components/schemas/UpdateConsentRequestBody"
    When the request "updateConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_updateConsent_400.02_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "updateConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_updateConsent_400.03_missing_required_property
  Scenario Outline: Error response for missing required property in request body
    Given the request body property "<required_property>" is not included
    When the request "updateConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | required_property |
      | $.consentStatus   |

  @consent_management_updateConsent_400.04_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "updateConsent" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_updateConsent_400.05_consentStatus_invalid_value
  Scenario: The consentStatus field has an invalid value
    Given the request body property "$.consentStatus" is set to a value not in the allowed enum ["GRANTED", "DENIED"]
    When the request "updateConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  # Authentication/Authorization errors

  # Generic 401 errors

  @consent_management_updateConsent_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "updateConsent" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @consent_management_updateConsent_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "updateConsent" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @consent_management_updateConsent_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "updateConsent" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @consent_management_updateConsent_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "consent-management:update"
    When the request "updateConsent" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @consent_management_updateConsent_403.02_api_client_token_mismatch
  Scenario: Consent not managed by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the Consent
    When the request "updateConsent" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @consent_management_updateConsent_404.01_not_found
  Scenario: non-existing consentId
    Given the path parameter "consentId" is set to a random UUID
    When the request "updateConsent" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
