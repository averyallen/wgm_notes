# How to Use Cerner's Connectathon Server with Carequality

## Look Up Server Information in Carequality Directory

You can view all entries in the Carequality directory by issuing this request:  
GET https://connect.carequality.org:443/fhir-stu3/1.0.1/Organization?apikey=YOUR_API_KEY&_format=xml

Cerner's connectathon server is registered in the Carequality directory as Organization `2.16.840.1.113883.3.13.1`.

You can read information about Cerner's connectathon server directly by issuing this request:  
GET https://connect.carequality.org:443/fhir-stu3/1.0.1/Organization/2.16.840.1.113883.3.13.1?apikey=YOUR_API_KEY&_format=xml

The Carequality directory entry for Cerner's connectathon server has a contained Endpoint indicating the base URL for Cerner's connectathon server. Use this base URL to view CapabilityStatement information of the server. Cerner's connectathon server requires that consumers explicitly [request an Accept type](https://fhir.cerner.com/millennium/r4/#media-types).

### A Word on Token URLs

You will notice while viewing the CapabilityStatement for Cerner's connectathon server that there is a `token` OAuth URI and a `carequality-token` OAuth URI.

    ...
    "security": {
      "extension": [
        {
          "url": "http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris",
          "extension": [
            {
              "url": "token",
              "valueUri": "https://authorization.sandboxcerner.com/tenants/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/protocols/oauth2/profiles/smart-v1/token"
            },
            {
              "url": "carequality-token",
              "valueUri": "https://fhir-ehr.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Authorization/token"
            },
            ...
          ]
        }
      ],
      ...

This is necessary due to an implementation quirk of Cerner's connectathon authorization server. While a typical workflow for Carequality would utilize the `token` URL, in actuality you must utilize the `carequality-token` URL when working with Cerner's connectathon server.

## Create and Sign Client Assertion JWT

Out of band, work with Sequoia Project tech support to receive a reference code and an authorization code that can be exchanged for an X.509 certificate and corresponding private key.

Use the certificate and private key to create and sign the client assertion JWT. You can accomplish this in any number of ways. I wrote a [ruby script to sign client assertion JWTs](generate_client_assertion_jwt.rb). This script in particular had some Cerner-specific values hardcoded.

## Register Your Client Id with Cerner

Your client id should be the FQDN that your Carequality certificate and private key were issued for. Contact Max Philips and we will register your client id with Cerner manually. We'll need the client id itself and a description of the client.

## Use Client Assertion JWT to Interact with Token URL

Issue a POST request to Cerner's connectathon server's token URL, passing a request body with the following:
* scope: system/Patient.read
* grant_type: client_credentials
* client_assertion_type: urn:ietf:params:oauth:client-assertion-type:jwt-bearer
* client_assertion: your client assertion JWT

### Example - cURL Command

```bash
curl -X POST \
  https://fhir-ehr.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Authorization/token \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'scope=system%2FPatient.read&grant_type=client_credentials&client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer&client_assertion=<client assertion JWT>'
```

### Example - Postman Collection

[virtual_connectathon_dec_2019_carequality.postman_collection.json](virtual_connectathon_dec_2019_carequality.postman_collection.json)

Request: "Exchange client assertion for access token"

*Note that this Postman request runs a Test step to set a Postman environment variable named `dispensedJWT` to the value of the access token retrieved from the server. Make sure to run this collection within the Postman environment of your choice to take advantage of this.*

## Use Access Token to Interact With FHIR Resources

Utilize GET requests to access Cerner's connectathon server's read or search-type interactions for Patient resources.

### Example - cURL Command

```bash
curl -X GET \
  'https://fhir-ehr.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Patient/1316024' \
  -H 'Accept: application/fhir+json' \
  -H 'Authorization: Bearer <access token received from previous step>' \
```

```bash
curl -X GET \
  'https://fhir-ehr.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Patient?name=peters' \
  -H 'Accept: application/fhir+json' \
  -H 'Authorization: Bearer <access token received from previous step>' \
```

### Example - Postman Collection

[virtual_connectathon_dec_2019_carequality.postman_collection.json](virtual_connectathon_dec_2019_carequality.postman_collection.json)

Request: "Exchange access token for FHIR data (read)", or "Exchange access token for FHIR data (search)"

*Note that these Postman requests expect a Postman environment variable named `dispensedJWT` to be available in your Postman environment.*
