#VerifyingCareBenefitNew - Native Salesforce Health Cloud App

This project is a native Salesforce Health Cloud application that enables **electronic Care Benefit Verification** by integrating with an external benefits verification API. It supports Care Representatives in managing, verifying, and tracking patient insurance coverage details.

##Features

- Create `CareBenefitVerifyRequest` records from Salesforce using Health Cloud objects
- Send structured patient, insurance, provider, and service data to an **external API**
- Receive and process **benefit verification results**
- Automatically create `CoverageBenefit` records linked to original verification requests
- Uses **Named Credentials** for secure authentication
- Built entirely using native Salesforce technologies (Apex, Flows, REST API)

---

## Project Structure

```

VerifyingCareBenefitNew/
└── healthcare/
├── force-app/
│   └── main/
│       └── default/
│           ├── classes/
│           ├── objects/
│           ├── lwc/
│           ├── permissionsets/
│           └── ...
├── config/
│   └── project-scratch-def.json
├── README.md

````

---

## Setup & Deployment

### 1. Clone Repository
```bash
git clone https://github.com/tpkasturi/VerifyingCareBenefitNew.git
cd VerifyingCareBenefitNew/healthcare
````

### 2. Authenticate to Dev Hub

```bash
sfdx auth:web:login --setdefaultdevhubusername --setalias DevHub
```

### 3. Create Scratch Org

```bash
sfdx force:org:create -f config/project-scratch-def.json -a CareBenefitApp -s -d 30
```

### 4. Push Source

```bash
sfdx force:source:push
```

### 5. Assign Permission Set

```bash
sfdx force:user:permset:assign -n CareBenefitUser
```

### 6. Open Org

```bash
sfdx force:org:open
```

---

##  API Integration

### Named Credential Setup

| Field                         | Value                                                                                                                                    |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Label                         | InfinitusAPI                                                                                                                             |
| Name                          | InfinitusAPI                                                                                                                             |
| URL                           | [https://infinitusmockbvendpoint-rji9z4.5sc6y6-2.usa-e2.cloudhub.io](https://infinitusmockbvendpoint-rji9z4.5sc6y6-2.usa-e2.cloudhub.io) |
| External Credential           | InfinitusCredential                                                                                                                      |
| Generate Authorization Header | ✅                                                                                                                                        |

### Apex Callout Example

```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:InfinitusAPI/benefit-verification-request');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');
req.setBody(JSON.serialize(payload));

Http http = new Http();
HttpResponse res = http.send(req);
```

---

## Sample Payloads

### Request Payload

```json
{
  "patient": {
    "firstName": "John",
    "lastName": "Doe",
    "dob": "1985-12-31",
    "gender": "M"
  },
  "insurance": {
    "providerName": "ABC Insurance",
    "policyNumber": "123456",
    "groupNumber": "78910",
    "subscriberId": "S1234"
  },
  "provider": {
    "npi": "1234567890",
    "firstName": "Dr. Smith",
    "lastName": "Smith"
  },
  "service": {
    "type": "surgery",
    "dateTo": "2025-07-16",
    "dateFrom": "E11.9"
  }
}
```

### Expected Response

```json
{
  "status": "Acknowledged",
  "statusReason": "Care Benefit Verification Request successfully sent to Benefits Verification Provider."
}
```

---

### Manual Verification

* Use Workbench/Postman to hit REST endpoint:

```
POST /services/apexrest/care-benefit-verification-results
```

---

## Security

* Named Credentials for secure callouts
* Platform Encryption enabled for sensitive fields
* Authenticated REST endpoints
* No hardcoded secrets or credentials

---

##  Resources

* [Salesforce Health Cloud Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.health_cloud.meta/health_cloud/)
* [Salesforce Named Credentials](https://help.salesforce.com/s/articleView?id=sf.named_credentials_about.htm)

---


