Feature: CAMARA Consent Management API, vwip - Operation retrieveConsentInfo

  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  # * Scope required: consent-management:retrieve-info
  # * The API supports both two-legged and three-legged access tokens:
  #   - Two-legged: phoneNumber MUST be provided in the request body
  #   - Three-legged: phoneNumber MUST NOT be provided (subject identified from the token)
  #
  # Testing assets:
  # * Phone number with Consents in different statuses (PENDING, REQUESTED, GRANTED, DENIED, EXPIRED)
  # * Phone number with a Consent in GRANTED or DENIED status that has an expiration date set in the future
  # * Phone number with scopes relating to more than one API under the same purpose
  # * Phone number with no matching APIs under Consent legal basis
  #
  # References to OAS spec schemas refer to schemas specified in consent-management.yaml

  Background: Common retrieveConsentInfo setup
    Given an environment at "apiRoot"
    And the resource "/consent-management/vwip/consents/retrieve-info"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/RetrieveConsentInfoRequestBody"

  ############################ Happy Path Scenarios #############################################

  # Success scenarios

  @consent_management_retrieveConsentInfo_01_generic_success
  Scenario Outline: Retrieve Consent Information with different statuses
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.scopes" is set to a valid scope list
    And the request body property "$.purpose" is set to a valid purpose for the requested scope(s)
    And the User Consent is currently in "<status>" status
    And the request body property "$.requestConsentText" is set to false
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/RetrieveConsentInfoResponseBody"
    And the response property "$[*].scopes[*]" is either equal to or a subset of the requested scopes
    And the response property "$[*].purpose" matches the requested purpose
    And the response property "$[*].consentStatus" is "<status>"
    And the response property "$[*].consentText" is not present

    Examples:
      | status    |
      | PENDING   |
      | REQUESTED |
      | GRANTED   |
      | DENIED    |
      | EXPIRED   |

  @consent_management_retrieveConsentInfo_02_with_consent_text
  # When the API Provider supports RFC 7231, the "Content-Language" header will be included in the response
  Scenario: Retrieve Consent Information requesting consent texts
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.requestConsentText" is set to true
    And the header "Accept-Language" is set to a valid language tag
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/RetrieveConsentInfoResponseBody"
    And the response property "$[*].consentText" is present
    And the response property "$[*].consentText.title" is present
    And the response property "$[*].consentText.description" is present
    And the response property "$[*].consentText.consentTextId" is present
    And the response header "Content-Language", if present, its value is a language tag compatible with the requested Accept-Language preference

  @consent_management_retrieveConsentInfo_03_with_consent_text_no_accept_language
  # If supported, the "Content-Language" header may be included to specify the API Provider’s default response language
  Scenario: Retrieve Consent Information requesting consent texts without Accept-Language header
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.requestConsentText" is set to true
    And the header "Accept-Language" is not included
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/RetrieveConsentInfoResponseBody"
    And the response property "$[*].consentText" is present
    And the response property "$[*].consentText.title" is present
    And the response property "$[*].consentText.description" is present
    And the response property "$[*].consentText.consentTextId" is present
    And the response header "Content-Language", if present, its value is a valid BCP 47 language tag

  @consent_management_retrieveConsentInfo_04_empty_array
  Scenario: Retrieve Consent Information with no matching APIs under Consent legal basis
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.scopes" is set to a valid scope list
    And the request body property "$.purpose" is set to a valid purpose for the requested scope(s)
    And the request body properties "$.scopes" and "$.purpose" do not match any API(s) under Consent legal basis
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body is an empty array []

  @consent_management_retrieveConsentInfo_05_multiple_consent_info_items
  Scenario: Retrieve Consent Information returns more than one item when scopes relate to multiple APIs
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.scopes" is set to a valid scope list that relates to more than one API
    And the request body property "$.purpose" is set to a valid purpose for the requested scope(s)
    And the request body property "$.requestConsentText" is set to a valid value
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/RetrieveConsentInfoResponseBody"
    And the response property "$[*]" contains more than one item
    And the response property "$[*].scopes[*]" is either equal to or a subset of the requested scopes
    And the response property "$[*].purpose" matches the requested purpose

  @consent_management_retrieveConsentInfo_06_consentId_and_creationDate_absent_when_pending
  Scenario: The consentId and creationDate are absent in the response when the consent status is PENDING
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.scopes" is set to a valid scope list
    And the request body property "$.purpose" is set to a valid purpose for the requested scope(s)
    And the User Consent is currently in "PENDING" status
    And the request body property "$.requestConsentText" is set to false
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/RetrieveConsentInfoResponseBody"
    And the response property "$[*].consentId" is not present
    And the response property "$[*].creationDate" is not present

  @consent_management_retrieveConsentInfo_07_consentId_and_creationDate_present
  Scenario Outline: The consentId and creationDate are present in the response when the consent status is not PENDING
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.scopes" is set to a valid scope list
    And the request body property "$.purpose" is set to a valid purpose for the requested scope(s)
    And the User Consent is currently in "<status>" status
    And the request body property "$.requestConsentText" is set to false
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/RetrieveConsentInfoResponseBody"
    And the response property "$[*].consentId" is present
    And the response property "$[*].creationDate" is present and its value is in the past

    Examples:
      | status    |
      | REQUESTED |
      | GRANTED   |
      | DENIED    |
      | EXPIRED   |

  @consent_management_retrieveConsentInfo_08_expirationDate_present_and_in_future
  Scenario Outline: The expirationDate is present and in the future when the User Consent has not yet expired
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.scopes" is set to a valid scope list
    And the request body property "$.purpose" is set to a valid purpose for the requested scope(s)
    And the User Consent is currently in "<status>" status with an expiration date set in the future
    And the request body property "$.requestConsentText" is set to false
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/RetrieveConsentInfoResponseBody"
    And the response property "$[*].consentId" is present
    And the response property "$[*].creationDate" is present and its value is in the past
    And the response property "$[*].expirationDate" is present and its value is in the future

    Examples:
      | status  |
      | GRANTED |
      | DENIED  |

  @consent_management_retrieveConsentInfo_09_expirationDate_present_and_in_past
  Scenario: The expirationDate is present and in the past when the User Consent has expired
    Given a valid phone number identified by the token or provided in the request body
    And the request body property "$.scopes" is set to a valid scope list
    And the request body property "$.purpose" is set to a valid purpose for the requested scope(s)
    And the User Consent is currently in "EXPIRED" status
    And the request body property "$.requestConsentText" is set to false
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/RetrieveConsentInfoResponseBody"
    And the response property "$[*].consentId" is present
    And the response property "$[*].creationDate" is present and its value is in the past
    And the response property "$[*].expirationDate" is present and its value is in the past

  ############################ Error Scenarios #############################################

  # Error scenarios for management of input parameter phoneNumber (C02)

  @consent_management_retrieveConsentInfo_C02.01_phone_number_not_schema_compliant
  Scenario: Phone number value does not comply with the schema
    Given the header "Authorization" is set to a valid access token which does not identify a single phone number
    And the request body property "$.phoneNumber" does not comply with the OAS schema at "#/components/schemas/PhoneNumber"
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_C02.02_phone_number_not_found
  Scenario: Phone number not found
    Given the header "Authorization" is set to a valid access token which does not identify a single phone number
    And the request body property "$.phoneNumber" is compliant with the schema but does not identify a valid phone number
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 404
    And the response property "$.status" is 404
    And the response property "$.code" is "IDENTIFIER_NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_C02.03_unnecessary_phone_number
  Scenario: Phone number not to be included when it can be deduced from the access token
    Given the header "Authorization" is set to a valid access token identifying a phone number
    And the request body property "$.phoneNumber" is set to a valid phone number
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 422
    And the response property "$.status" is 422
    And the response property "$.code" is "UNNECESSARY_IDENTIFIER"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_C02.04_missing_phone_number
  Scenario: Phone number not included and cannot be deduced from the access token
    Given the header "Authorization" is set to a valid access token which does not identify a single phone number
    And the request body property "$.phoneNumber" is not included
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 422
    And the response property "$.status" is 422
    And the response property "$.code" is "MISSING_IDENTIFIER"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_C02.05_phone_number_not_supported
  Scenario: Service not available for the phone number
    Given that the service is not available for all phone numbers commercialized by the operator
    And a valid phone number, identified by the token or provided in the request body, for which the service is not applicable
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 422
    And the response property "$.status" is 422
    And the response property "$.code" is "SERVICE_NOT_APPLICABLE"
    And the response property "$.message" contains a user friendly text

  # Syntax Error scenarios

  @consent_management_retrieveConsentInfo_400.01_schema_not_compliant
  Scenario: Invalid Argument. Generic Syntax Exception
    Given the request body is included but is not compliant with the schema at "#/components/schemas/RetrieveConsentInfoRequestBody"
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_400.02_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_400.03_empty_request_body
  # 3-legged scenario only. It happens when request body has at least one required property
  # NOTE: Recommended value for "$.message" (NOT NORMATIVE) is "Missing mandatory parameter(s)"
  Scenario: Empty object as request body
    Given the request body is set to {}
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_400.04_missing_required_property
  Scenario Outline: Error response for missing required property in request body
    Given the request body property "<required_property>" is not included
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | required_property       |
      | $.scopes                |
      | $.purpose               |
      | $.requestConsentText    |

  @consent_management_retrieveConsentInfo_400.05_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_400.06_scopes_empty_array
  Scenario: The scopes field is an empty array
    Given the request body property "$.scopes" is set to []
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_400.07_purpose_invalid_format
  Scenario: The purpose field does not comply with the required format
    Given the request body property "$.purpose" does not comply with the OAS schema at "#/components/schemas/Purpose"
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  # Authentication/Authorization errors

  # Generic 401 errors

  @consent_management_retrieveConsentInfo_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @consent_management_retrieveConsentInfo_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "consent-management:retrieve-info"
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @consent_management_retrieveConsentInfo_403.02_api_client_token_mismatch
  Scenario: Consent info not accessible by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the Consent
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Specific 403 error scenarios

  @consent_management_retrieveConsentInfo_403.03_not_allowed_scopes_purpose
  # e.g. the API Consumer has not onboarded the appropriate API(s) with the API Provider for the declared purpose.
  Scenario: The requested scope(s) and purpose combination is not allowed
    Given a valid phone number identified by the token or provided in the request body
    And the request body properties "$.scopes" and "$.purpose" are set to a combination not allowed for the API Consumer
    When the request "retrieveConsentInfo" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "CONSENT_MANAGEMENT.NOT_ALLOWED_SCOPES_PURPOSE"
    And the response property "$.message" contains a user friendly text
