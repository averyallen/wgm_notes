# How to use Cerner's Test Server for Carequality

Base server URL:  
https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/

Token URL:  
https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Authorization/token

FHIR resource URL:  
https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Patient/1316024  
https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Patient?name=peters

Make sure to request JSON format for FHIR resource requests using either:
* ?_format=json
* Accept: application/fhir+json

## Create and sign client assertion JWT

Out of band, work with Sequoia Project tech support to receive a reference code and an authorization code that can be exchanged for an X.509 certificate and corresponding private key.

Use the certificate and private key to create and sign the client assertion JWT. I wrote a ruby script to sign client assertion JWTs: [generate_client_assertion_jwt.rb](generate_client_assertion_jwt.rb)

## Register your client id with Cerner

Your client id should be the FQDN that your Carequality certificate and private key were issued for. Contact Max Philips and we will register your client id with Cerner manually. We'll need the client id itself and a description of the client.

## Use client assertion JWT to interact with token URL

Issue a POST request to the server's token URL, passing:
* scope: system/Patient.read
* grant_type: client_credentials
* client_assertion_type: urn:ietf:params:oauth:client-assertion-type:jwt-bearer
* client_assertion: your client assertion JWT

### cURL command

```bash
curl -X POST \
  https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Authorization/token \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'scope=system%2FPatient.read&grant_type=client_credentials&client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer&client_assertion=<client assertion JWT>'
```

### Postman collection

[wgm_sept_2019_carequality.postman_collection.json](wgm_sept_2019_carequality.postman_collection.json)

Request: Exchange client assertion for access token

Note that this Postman request runs a Test step to set a Postman environment variable named dispensedJWT to the value of the access token retrieved from the server. Make sure you run this collection within the Postman environment of your choice to take advantage of this.

## Use access token to interact with FHIR resource

Issue a GET request to either of the server's FHIR resource URLs for Patient resources. Cerner's FHIR server requires that consumers request an Accept type of JSON.

### cURL command

```bash
curl -X GET \
  'https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Patient?_id=1316024' \
  -H 'Accept: application/fhir+json' \
  -H 'Authorization: Bearer <access token received from previous step>' \
```

### Postman collection

[wgm_sept_2019_carequality.postman_collection.json](wgm_sept_2019_carequality.postman_collection.json)

Request: Exchange access token for FHIR data (read), or Exchange access token for FHIR data (search)

Note that these Postman requests expect a Postman environment variable named dispensedJWT to be available in your Postman environment.
