# e-Manifest API Examples | US EPA

Code examples of using the e-Manifest API.

Using the e-Manifest API consists of two major steps: uploading and signing manifests.

The production base URL is **https://e-manifest.cld.epa.gov/api/v0**

Notation note: path variables are expressed as `:variable_name`. The colon is not part of the URI.

On this page you may learn about how to:
* [Register for a Test Account] (#register-for-a-test-account)
* [Get an API Key] (#get-an-api-key)
* [Validate a manifest](#validate-a-manifest)
* [Generate an Authentication Token](#generate-an-authorization-token)
* [Submit a manifest](#submit-a-manifest)
* [Fetch a manifest](#fetch-a-manifest)
* [Update a manifest](#update-a-manifest)
* [Search for manifests](#search-for-manifests)
* [Generate a Signature Authorization Token](#generate-a-signature-authorization-token)
* [Sign a manifest](#sign-a-manifest)
* [Management method codes](#management-method-codes)

## Register for a Test Account
In order to obtain a test account from EPA's Central Data Exchange (CDX):
Visit: https://test.epacdx.net and click the green “Register with CDX” button
1) After reading and accepting the “Terms and Conditions” you may select the “program service” “e-Manifest: Hazardous Waste Electronic Manifest System” from the list of available program services
2) Next select your role; either State Data Download or TSDF Certifier (select if you want to submit manifests).  Click the green “Request Role Access” to proceed
3) Fill out your user and organization information and click the green “Submit Request for Access” button.  Please note, if you wish to sign manifests you must use your correct information.  For example, if your name is Jane Smith, you need to enter Jane Smith as your 	name.
4) You will be navigated to a confirm screen wait for an email titled “Core Registration Email Verification Request (TEST)” from helpdesk@epacdx.net to complete the process.  Once you receive the email click the link to the complete the process and confirm your address.
5) After logging into CDX from the page the link navigates you to with the username and password you just created, you will either be taken:
 	State Data Download users are taken to their CDX home page Skip to step 7
	TSDF Certifier users are taken to page to verify their identity.  Proceed to step 6
6) TSDF Certifier’s only: Your next steps in order to sign manifests only take a few minutes
   i) Verify your identity, this is done through LexisNexis. If you did not provide correct information in step 3 or do not pass the identify proofing step, you will need to mail a paper version of the electronic signature agreement in order to receive access to the system. Please allow at least a week for the mail to get to them  We can not accept scans.
   ii) After your identity has been verified you will be able set up your knowledge based questions to sign manifests 
   iii) After setting up your knowledge based questions, you may either use them to electronically sign your electronic signature agreement or mail a paper version of the electronic signature agreement to EPA per the instructions on that form. Please allow at least a week for the mail to get to them  We can not accept scans.
7) All users: Once you have completed these steps email emanifest@epa.gov with your user name and role.  In the event you needed to mail a paper version of the  electronic signature agreement please include any tracking information.  


## Get an API Key
If you are a developer from a TSDF and you'd like to request an API key so you can use the e-Manifest APIs, please check your organization's policies on implementing e-manifest.  Some companies may use unique API keys for each facility, others may use one API key for an entire company.  If you have questions please email emanifest@epa.gov.

Of you need a API key, go to api.data.gov.  Click the "Get an API key" link.  Fill out the simple form, and please put "EPA's e-Manifest" under the optional field "How will you use this API key". With in a few seconds, you should recieve an email with your new API key and you're ready to go!
## Validate a manifest

Before you submit a manifest, you may validate its content and structure.

```bash
curl -i -X POST -H 'Content-Type: application/json' \
  --data @manifest.json \
  https://e-manifest.cld.epa.gov/api/v0/manifests/validate
```

If there is a validation error, the response status code will be 422 and the response body
will be a JSON string containing any validation errors.

If the manifest is valid, the response status code will be 200.

## Generate an Authorization Token

Before you can create or modify any manifests, or search for any non-public manifests, you must
create an Authorization Token.

```bash
curl -i -X POST -H 'Content-Type: application/json' \
  --data @auth-creds.json \
  'https://e-manifest.cld.epa.gov/api/v0/tokens?authenticate=1'
```

An example `auth-creds.json` file looks like:

```json
<%= render 'examples/auth_creds.json' %>
```

The authentication response looks like:

```json
<%= render 'examples/authentication_response.json' %>
```

You will use the *token* value as the `Authorization` HTTP header value in all other API requests.

## Submit a manifest

```bash
curl -i -X POST -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer your-auth-token' \
  --data @manifest.json \
  https://e-manifest.cld.epa.gov/api/v0/manifests
```

*Note* that `manifest.json` must include a Manifest Tracking Number, from Line 4 of form 8700-22.
If a manifest with an identical Manifest Tracking Number already exists, the `POST` will be rejected
with an error message.

An example `manifest.json` file looks like:

```json
<%= render 'examples/manifest.json' %>
```

The response from that POST will include a JSON-encoded body with the tracking number as a `message`
and the URI of the e-Manifest as a `location`, which will include the unique e-Manifest identifier. A successful
submission should return a 201 status.

```json
{
  "message": "Manifest 987654321ABC submitted successfully.",
  "location": "https://e-manifest.cld.epa.gov/api/v0/manifests/de305d54-75b4-431b-adb2-eb6b9e546014"
}
```

## Fetch a manifest

To retrieve a previously submitted e-Manifest, you need the e-Manifest ID from
the [Submit a manifest example](#submit-a-manifest).

```bash
curl -i -X GET -H 'Authorization: Bearer your-auth-token' \
  https://e-manifest.cld.epa.gov/api/v0/manifest/de305d54-75b4-431b-adb2-eb6b9e546014
```

If you do not know the e-Manifest ID, but you do have the Manifest Tracking Number from Line 4 of form 8700-22,
you can fetch the e-Manifest object with the Manifest Tracking Number.

```bash
curl -i -X GET -H 'Authorization: Bearer your-auth-token' \
   https://e-manifest.cld.epa.gov/api/v0/manifest/987654321abc
```

The response for both endpoints looks the same:

```json
<%= render 'examples/manifest_response.json' %>
```

## Update a manifest

You may update a previously submitted e-Manifest.

If the manifest has previously been signed, updating it does not change what has been previously signed
(see [Sign a manifest example](#sign-a-manifest)). You must re-sign the updated e-Manifest.

The update request uses the HTTP `PATCH` method. See [JSON Patch](http://tools.ietf.org/html/rfc6902) and
[JSON Pointer](http://tools.ietf.org/html/rfc6901) for specification details.

Just as in the [Fetch a manifest example](#fetch-a-manifest), you may use either the e-Manifest ID or the
Manifest Tracking Number.

```bash
curl -i -X PATCH -H 'Content-Type: application/json-patch+json' \
  -H 'Authorization: Bearer your-auth-token' \
  --data @manifest-patch.json \
  https://e-manifest.cld.epa.gov/api/v0/manifests/de305d54-75b4-431b-adb2-eb6b9e546014
```

or

```bash
curl -i -X PATCH -H 'Content-Type: application/json-patch+json' \
  -H 'Authorization: Bearer your-auth-token' \
  --data @manifest-patch.json \
  https://e-manifest.cld.epa.gov/api/v0/manifests/987654321abc
```

An example `manifest-patch.json` file looks like:

```json
<%= render 'examples/manifest_patch.json' %>
```

The response format is the same as in the [Fetch a manifest example](#fetch-a-manifest).

## Search for manifests

The e-Manifest API supports full-text search of all e-Manifests. You can search with simple terms, or
by specifying specific fields within which your terms should match. Wildcards, booleans and phrase search
are all supported. See the [full query string syntax documentation]
(https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax) for more details.

Example of looking for a manifest by Manifest Tracking Number `987654321abc`:

```bash
curl -i -X GET -H 'Authorization: Bearer your-auth-token' \
  'https://e-manifest.cld.epa.gov/api/v0/manifests/search?q=content.generator.manifest_tracking_number:987654321abc'
```

You can page through results with the `size` and `from` URL query parameters, and sort results by any field.

```bash
curl -i -X GET -H 'Authorization: Bearer your-auth-token' \
  'https://e-manifest.cld.epa.gov/api/v0/manifests/search?q=abc123&from=0&size=10&sort[]=id:desc'
```

The search response format looks like:

```json
<%= render 'examples/manifest_search.json' %>
```

## Generate a Signature Authorization Token

You must re-authenticate with the CDX CROMERR service for signing a manifest. Values in the response are needed to sign the manifest.

```bash
curl -i -X POST -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer your-auth-token' \
  --data @auth-creds.json \
  https://e-manifest.cld.epa.gov/api/v0/tokens
```

An example `auth-creds.json` file looks like:

```json
<%= render 'examples/auth_creds.json' %>
```

The authorization response looks like:

```json
<%= render 'examples/auth_response.json' %>
```

You will use the authorization response to [Sign your manifest](#sign-a-manifest).

## Sign a manifest

To sign a manifest you must first [Generate an Authorization Token](#generate-an-authorization-token)

You can sign a manifest with either the e-Manifest ID or the Manifest Tracking Number:

```bash
curl -i -X POST -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer your-auth-token' \
  --data @sign-manifest.json \
  https://e-manifest.cld.epa.gov/api/v0/manifests/de305d54-75b4-431b-adb2-eb6b9e546014/signature
```

where `sign-manifest.json` looks like:

```json
<%= render 'examples/sign_manifest.json' %>
```

## Management method codes

Fetch the list of valid hazardous waste report management method codes like this:

```bash
curl -i -X GET https://e-manifest.cld.epa.gov/api/v0/method_codes
```

The response will look like:

```json
[
  {
    "code": "H010",
    "category": "Reclamation and Recovery",
    "description": "Metals recovery including retorting, smelting, chemical, etc."
  },
  // more methods here
]
```
