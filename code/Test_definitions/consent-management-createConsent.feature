Feature: CAMARA Consent Management API, vwip - Operation createConsent

  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  # * Scope required: consent-management:create
  # * The API supports both two-legged and three-legged access tokens:
  #   - Two-legged: phoneNumber MUST be provided in the request body
  #   - Three-legged: phoneNumber MUST NOT be provided (subject identified from the token)
  #
  # Testing assets:
  # * Phone number supported by the service with valid scope(s), purpose, and consentTextId allowed for the API Consumer
  # * Phone number for which the API Provider assigns an expiration date to newly created Consents, if applicable
  # * A consentTextId value that does not match any valid consent text version for the requested scope(s) and purpose
  # * A phone number for which a Consent already exists for a given scope(s) and purpose
  #
  # References to OAS spec schemas refer to schemas specified in consent-management.yaml

  Background: Common createConsent setup
    Given an environment at "apiRoot"
    And the resource "/consent-management/vwip/consents"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/CreateConsentRequestBody"

  ############################ Happy Path Scenarios #############################################

  @consent_management_createConsent_01_success
  Scenario Outline: Create Consent successfully
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.scopes" is set to a valid scope list allowed for the API Consumer
    And the request body property "$.purpose" is set to a valid purpose for the requested scope(s)
    And the request body property "$.consentTextId" is set to a valid consentTextId for the requested scope(s) and purpose
    And the request body property "$.consentStatus" is set to "<consentStatus>"
    And the request body is compliant with the schema at "#/components/schemas/CreateConsentRequestBody"
    When the request "createConsent" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/CreateConsentResponseBody"
    And the response property "$.consentId" is present
    And the response property "$.creationDate" is present

    Examples:
      | consentStatus |
      | GRANTED       |
      | DENIED        |

  @consent_management_createConsent_02_expirationDate_present
  Scenario: The expirationDate is present in the response when the API Provider assigns an expiration date
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.scopes" is set to a valid scope list allowed for the API Consumer
    And the request body property "$.purpose" is set to a valid purpose for the requested scope(s)
    And the request body property "$.consentTextId" is set to a valid consentTextId for the requested scope(s) and purpose
    And the request body property "$.consentStatus" is set to "GRANTED"
    And the API Provider assigns an expiration date to newly created Consents
    When the request "createConsent" is sent
    Then the response status code is 201
    And the response body complies with the OAS schema at "#/components/schemas/CreateConsentResponseBody"
    And the response property "$.consentId" is present
    And the response property "$.creationDate" is present
    And the response property "$.expirationDate" is present and its value is in the future

  ############################ Error Scenarios #############################################

  # Error scenarios for management of input parameter phoneNumber (C02)

  @consent_management_createConsent_C02.01_phone_number_not_schema_compliant
  Scenario: Phone number value does not comply with the schema
    Given the header "Authorization" is set to a valid access token which does not identify a single phone number
    And the request body property "$.phoneNumber" does not comply with the OAS schema at "#/components/schemas/PhoneNumber"
    When the request "createConsent" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_C02.02_phone_number_not_found
  Scenario: Phone number not found
    Given the header "Authorization" is set to a valid access token which does not identify a single phone number
    And the request body property "$.phoneNumber" is compliant with the schema but does not identify a valid phone number
    When the request "createConsent" is sent
    Then the response status code is 404
    And the response property "$.status" is 404
    And the response property "$.code" is "IDENTIFIER_NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_C02.03_unnecessary_phone_number
  Scenario: Phone number not to be included when it can be deduced from the access token
    Given the header "Authorization" is set to a valid access token identifying a phone number
    And the request body property "$.phoneNumber" is set to a valid phone number
    When the request "createConsent" is sent
    Then the response status code is 422
    And the response property "$.status" is 422
    And the response property "$.code" is "UNNECESSARY_IDENTIFIER"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_C02.04_missing_phone_number
  Scenario: Phone number not included and cannot be deduced from the access token
    Given the header "Authorization" is set to a valid access token which does not identify a single phone number
    And the request body property "$.phoneNumber" is not included
    When the request "createConsent" is sent
    Then the response status code is 422
    And the response property "$.status" is 422
    And the response property "$.code" is "MISSING_IDENTIFIER"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_C02.05_phone_number_not_supported
  Scenario: Service not available for the phone number
    Given that the service is not available for all phone numbers commercialized by the operator
    And a valid phone number, identified by the token or provided in the request body, for which the service is not applicable
    When the request "createConsent" is sent
    Then the response status code is 422
    And the response property "$.status" is 422
    And the response property "$.code" is "SERVICE_NOT_APPLICABLE"
    And the response property "$.message" contains a user friendly text

  # Syntax Error scenarios

  @consent_management_createConsent_400.01_schema_not_compliant
  Scenario: Invalid Argument. Generic Syntax Exception
    Given the request body is included but is not compliant with the schema at "#/components/schemas/CreateConsentRequestBody"
    When the request "createConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_400.02_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "createConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_400.03_empty_request_body
  # 3-legged scenario only. It happens when request body has at least one required property
  # NOTE: Recommended value for "$.message" (NOT NORMATIVE) is "Missing mandatory parameter(s)"
  Scenario: Empty object as request body
    Given the request body is set to {}
    When the request "createConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_400.04_missing_required_property
  Scenario Outline: Error response for missing required property in request body
    Given the request body property "<required_property>" is not included
    When the request "createConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | required_property  |
      | $.scopes           |
      | $.purpose          |
      | $.consentStatus    |
      | $.consentTextId    |

  @consent_management_createConsent_400.05_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "createConsent" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_400.06_scopes_empty_array
  Scenario: The scopes field is an empty array
    Given the request body property "$.scopes" is set to []
    When the request "createConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_400.07_purpose_invalid_format
  Scenario: The purpose field does not comply with the required format
    Given the request body property "$.purpose" does not comply with the OAS schema at "#/components/schemas/Purpose"
    When the request "createConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_400.08_consentStatus_invalid_value
  Scenario: The consentStatus field has an invalid value
    Given the request body property "$.consentStatus" is set to a value not in the allowed enum ["GRANTED", "DENIED"]
    When the request "createConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Specific 400 error scenarios

  @consent_management_createConsent_400.09_invalid_consent_text_id
  Scenario: Invalid consent text ID
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.scopes" is set to a valid scope list allowed for the API Consumer
    And the request body property "$.purpose" is set to a valid purpose for the requested scope(s)
    And the request body property "$.consentStatus" is set to "GRANTED"
    And the request body property "$.consentTextId" is set to a value that does not match any valid consent text version for the requested scope(s) and purpose
    When the request "createConsent" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "CONSENT_MGMT.INVALID_CONSENT_TEXT_ID"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  # Authentication/Authorization errors

  # Generic 401 errors

  @consent_management_createConsent_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "createConsent" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "createConsent" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "createConsent" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @consent_management_createConsent_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "consent-management:create"
    When the request "createConsent" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @consent_management_createConsent_403.02_api_client_token_mismatch
  Scenario: Consent not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the Consent
    When the request "createConsent" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Specific 403 error scenarios

  @consent_management_createConsent_403.03_not_allowed_scopes_purpose
  # e.g. the API Consumer has not onboarded the appropriate API(s) with the API Provider for the declared purpose.
  Scenario: The requested scope(s) and purpose combination is not allowed
    Given a valid phone number identified by the token or provided in the request body
    And the request body properties "$.scopes" and "$.purpose" are set to a combination not allowed for the API Consumer
    When the request "createConsent" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "CONSENT_MGMT.NOT_ALLOWED_SCOPES_PURPOSE"
    And the response property "$.message" contains a user friendly text

  # Generic 409 errors

  @consent_management_createConsent_409.01_duplicated_resource
  Scenario: Conflict due to existing Consent
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.scopes" is set to a valid scope list allowed for the API Consumer
    And the request body property "$.purpose" is set to a valid purpose for the requested scope(s)
    And the request body property "$.consentTextId" is set to a valid consentTextId for the requested scope(s) and purpose
    And the request body property "$.consentStatus" is set to "GRANTED"
    And a Consent for the given User, scope(s), and purpose already exists
    When the request "createConsent" is sent
    Then the response status code is 409
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 409
    And the response property "$.code" is "ALREADY_EXISTS"
    And the response property "$.message" contains a user friendly text
