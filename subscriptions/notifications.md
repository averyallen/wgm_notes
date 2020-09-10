## Notify

POST https://fhir-open.stagingcerner.com/beta/dacc6494-e336-45ad-8729-b789ff8663c6/Subscription/notify

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
