# How to use Cerner's Test Server for Subscriptions

Base server URL:  
https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/

Subscription resource:  
https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription

Make sure to request json format for show/search using either:
* ?_format=json
* Accept: application/fhir+json

## Show

GET https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription/<id\>

Example:
* https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription/1

## Search

GET https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription?<query_parameter\>=<value\>&<query_parameter\>=<value\>...

Parameters:
* contact
  * https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription?contact=ext%204123
* criteria
  * https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription?criteria=Observation%3Fcode%3Dhttp%3A%2F%2Floinc.org%7C1975-2
* _id (multiple values comma separated)
  * https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription?_id=1,2
* payload
  * https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription?payload=application%2Ffhir%2Bjson
* status (multiple values comma separated)
  * https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription?status=requested
* type (multiple values comma separated)
  * https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription?type=rest-hook
* url
  * https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription?url=https%3A%2F%2Fbiliwatch.com%2Fcustomers%2Fmount-auburn-miu%2Fon-result

## Create

POST https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription  
Content-Type: application/fhir+json

Example Body:
```json
{
  "resourceType": "Subscription",
  "status": "requested",
  "contact": [
    {
      "system": "phone",
      "value": "ext 4123"
    }
  ],
  "end": "2021-01-01T00:00:00Z",
  "reason": "Monitor new neonatal function",
  "criteria": "Observation?code=http://loinc.org|1975-2",
  "channel": {
    "type": "rest-hook",
    "endpoint": "https://biliwatch.com/customers/mount-auburn-miu/on-result",
    "payload": "application/fhir+json",
    "header": [
      "Authorization: Bearer secret-token-abc-123"
    ]
  }
}
```

## Update

PUT https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription/<id\>  
Content-Type: application/fhir+json  
If-Match: W/"<version_id\>"

Determine If-Match version by reading the Subscription and examining meta.versionId

Example Body (update status from requested to active):
```json
{
  "resourceType": "Subscription",
  "status": "active",
  "contact": [
    {
      "system": "phone",
      "value": "ext 4123"
    }
  ],
  "end": "2021-01-01T00:00:00Z",
  "reason": "Monitor new neonatal function",
  "criteria": "Observation?code=http://loinc.org|1975-2",
  "channel": {
    "type": "rest-hook",
    "endpoint": "https://biliwatch.com/customers/mount-auburn-miu/on-result",
    "payload": "application/fhir+json",
    "header": [
      "Authorization: Bearer secret-token-abc-123"
    ]
  }
}
```

## Notify

POST https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription/notify

Example body:
```
Observation?code=http://loinc.org|1975-2
```

Cerner's test server has the capability to notify only rest-hook Subscriptions (i.e. no websocket/email/sms/message).

Subscriptions with status `active`, channel.type `rest-hook`, and criteria that matches the POST body will be triggered. So, you could trigger all Observation subscriptions by POSTing `Observation`, or you could trigger only one subscription that you created by POSTing a very specific string that matches only its criteria.

You will receive a 200 OK response when one or more subscriptions were triggered based on your POST body, and a 404 NOT FOUND response when no subscriptions were triggered.

## Example Subscription Data

[example_subscriptions.txt](example_subscriptions.txt)
