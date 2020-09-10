# How to use Cerner's Test Server for the R4 Subscriptions Backport

Base server URL:  
https://fhir-open.stagingcerner.com/beta/r4/dacc6494-e336-45ad-8729-b789ff8663c6/

Subscription resource:  
https://fhir-open.stagingcerner.com/beta/r4/dacc6494-e336-45ad-8729-b789ff8663c6/Subscription

Make sure to request json format for show/search using either:
* ?_format=json
* Accept: application/fhir+json


## Backport Topic Canonical Operation

GET https://fhir-open.stagingcerner.com/beta/r4/dacc6494-e336-45ad-8729-b789ff8663c6/Subscription/$topic-list

Lists supported Topics

```json
{
  "resourceType": "Parameters",
  "parameter": [
    {
      "name": "subscription-topic-canonical",
      "valueCanonical": "http://argonautproject.org/subscription-ig/SubscriptionTopic/admission"
    },
    {
      "name": "subscription-topic-canonical",
      "valueCanonical": "http://fhir.cerner.com/SubscriptionTopic/labs"
    }
  ]
}
```

## Show

GET https://fhir-open.stagingcerner.com/beta/r4/dacc6494-e336-45ad-8729-b789ff8663c6/Subscription/<id\>

Example:
* https://fhir-open.stagingcerner.com/beta/r4/dacc6494-e336-45ad-8729-b789ff8663c6/Subscription/d6340e59-1ec9-4b12-8979-eaba2def73da


## Create

POST https://fhir-open.stagingcerner.com/beta/r4/dacc6494-e336-45ad-8729-b789ff8663c6/Subscription  
Content-Type: application/fhir+json

Example Body:
```json
{
  "resourceType": "Subscription",
  "extension": [
    {
      "valueCanonical": "http://argonautproject.org/subscription-ig/SubscriptionTopic/admission",
      "url": "http://hl7.org/fhir/us/subscriptions-backport/StructureDefinition/backport-topic-canonical"
    }
  ],
  "status": "requested",
  "contact": [
    {
      "system": "phone",
      "value": "ext 4123",
      "use": "work"
    }
  ],
  "end": "2020-09-10T13:54:59.692Z",
  "reason": "Monitor Patient Admissions for specific patient",
  "criteria": "Encounter?patient=1316024",
  "channel": {
    "extension": [
      {
        "valueUnsignedInt": 60,
        "url": "http://hl7.org/fhir/us/subscriptions-backport/StructureDefinition/backport-heartbeat-period"
      }
    ],
    "type": "rest-hook",
    "endpoint": "https://addmission-tracker-example.com/on-admission",
    "payload": "application/fhir+json",
    "_payload": {
      "extension": [
        {
          "valueCode": "id-only",
          "url": "http://hl7.org/fhir/us/subscriptions-backport/StructureDefinition/backport-payload-content"
        }
      ]
    },
    "header": [
      "Authorization: Bearer some-secret-token"
    ]
  }
}
```

## Update

PUT https://fhir-open.stagingcerner.com/beta/r4/dacc6494-e336-45ad-8729-b789ff8663c6/Subscription/<id\>  
Content-Type: application/fhir+json  
If-Match: W/"<version_id\>"

Determine If-Match version by reading the Subscription and examining meta.versionId

Example Body (update status from requested to active):
```json
{
  "resourceType": "Subscription",
  "extension": [
    {
      "valueCanonical": "http://argonautproject.org/subscription-ig/SubscriptionTopic/admission",
      "url": "http://hl7.org/fhir/us/subscriptions-backport/StructureDefinition/backport-topic-canonical"
    }
  ],
  "status": "active",
  "contact": [
    {
      "system": "phone",
      "value": "ext 4123",
      "use": "work"
    }
  ],
  "end": "2020-09-10T13:54:59.692Z",
  "reason": "Monitor Patient Admissions for specific patient",
  "criteria": "Encounter?patient=1316024",
  "channel": {
    "extension": [
      {
        "valueUnsignedInt": 60,
        "url": "http://hl7.org/fhir/us/subscriptions-backport/StructureDefinition/backport-heartbeat-period"
      }
    ],
    "type": "rest-hook",
    "endpoint": "https://addmission-tracker-example.com/on-admission",
    "payload": "application/fhir+json",
    "_payload": {
      "extension": [
        {
          "valueCode": "id-only",
          "url": "http://hl7.org/fhir/us/subscriptions-backport/StructureDefinition/backport-payload-content"
        }
      ]
    },
    "header": [
      "Authorization: Bearer some-secret-token"
    ]
  }
}
```

## Triggering Notifications

See [notifications](notifications.md) documentation.

## Example Subscription Data

[example_subscriptions.txt](example_subscriptions.txt)
