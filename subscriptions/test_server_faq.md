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
  "topic": {
    "reference": "SubscriptionTopic/admission"
  },
  "contact": [
    {
      "system": "phone",
      "value": "ext 4123",
      "use": "work"
    }
  ],
  "end": "2020-05-13T16:18:29.426Z",
  "reason": "Monitor Patient Admissions for specific patient",
  "filterBy": [
    {
      "searchParamName": "patient",
      "searchModifier": "=",
      "value": "Patient/1316024"
    }
  ],
  "channelType": {
    "code": "rest-hook",
    "display": "Rest Hook",
    "system": "http://terminology.hl7.org/CodeSystem/subscription-channel-type"
  },
  "endpoint": "https://addmission-tracker-example.com/on-admission",
  "header": [
    "Authorization: Bearer some-secret-token"
   ],
  "heartbeatPeriod": 60,
  "contentType": "application/fhir+json",
  "content": "id-only"
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
  "topic": {
    "reference": "SubscriptionTopic/admission"
  },
  "contact": [
    {
      "system": "phone",
      "value": "ext 4123",
      "use": "work"
    }
  ],
  "end": "2020-05-13T16:18:29.426Z",
  "reason": "Monitor Patient Admissions for specific patient",
  "filterBy": [
    {
      "searchParamName": "patient",
      "searchModifier": "=",
      "value": "Patient/1316024"
    }
  ],
  "channelType": {
    "code": "rest-hook",
    "display": "Rest Hook",
    "system": "http://terminology.hl7.org/CodeSystem/subscription-channel-type"
  },
  "endpoint": "https://addmission-tracker-example.com/on-admission",
  "header": [
    "Authorization: Bearer some-secret-token"
   ],
  "heartbeatPeriod": 60,
  "contentType": "application/fhir+json",
  "content": "id-only"
}
```

## Notify

POST https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Subscription/notify

Body that triggers admission event for Patient 1316024 and Encounter 1221233:
```
EVN|A04|1
PID|123|1316024|1221233
```

Body that triggers lab event for Patient 1316024 and Observation 213443:
```
EVN|R01|1
PID|123|1316024|213443
```

Cerner's test server has the capability to notify only rest-hook Subscriptions (i.e. no websocket/email/message). Notifications are not currently supported through resource creation. Instead, notifications are triggered through the /notify endpoint.

The notify endpoint expects a body including either an [A04](https://hl7-definition.caristix.com/v2/HL7v2.3/TriggerEvents/ADT_A04) or [R01](https://hl7-definition.caristix.com/v2/HL7v2.3/TriggerEvents/ORU_R01) HL7 V2 message as seen in the body examples above. 

Subscriptions with status `active`, channelType with code `rest-hook`, and filterBy criteria that match the POST body will be triggered. By altering the filterBy field of a subscription, consumers can control how specific the criteria for receiving an event notification is.

When Cerner's test server sends notifications to the registered Subscription.endpoint, if a trailing slash is not present one will be added. For example, if your subscription's channel.endpoint is `http://test.com` a notification will be sent to `http://test.com/`.

You will receive a 200 OK response after all qualifying subscriptions are notified of the event.

## Example Subscription Data

[example_subscriptions.txt](example_subscriptions.txt)
