# e-Manifest API Examples | US EPA

Code examples of using the e-Manifest API.

Using the e-Manifest API consists of two major steps: uploading and signing manifests.

The production base URL is **https://e-manifest.18f.gov/api/v0**

Notation note: path variables are expressed as `:variable_name`. The colon is not part of the URI.

## <a name="submit-manifest"></a>Submit a manifest

```bash
curl -i -X POST -H 'Content-Type: application/json' \
  --data @manifest.json \
  https://e-manifest.18f.gov/api/v0/manifests
```

*Note* that `manifest.json` must include a Manifest Tracking Number, from Line 4 of form 8700-22.
If a manifest with an identical Manifest Tracking Number already exists, the `POST` will be rejected
with an error message.

An example `manifest.json` file looks like:

```json
<%= render 'examples/manifest.json' %>
```

The response from that POST will include no body content, but the `Location` header will contain
the URL of the submitted manifest, which will include the unique e-Manifest identifier. A successful
submission should return a 201 status.

```http
Status: 201
Location: https://e-manifest.18f.gov/api/v0/manifests/de305d54-75b4-431b-adb2-eb6b9e546014
```

## <a name="validate-manifest"></a>Validate a manifest

Before you submit a manifest, you may validate its content and structure.

```bash
curl -i -X POST -H 'Content-Type: application/json' \
  --data @manifest.json \
  https://e-manifest.18f.gov/api/v0/manifests/validate
```

If there is a validation error, the response status code will be 422 and the response body
will be a JSON string containing any validation errors.

If the manifest is valid, the response status code will be 200.

## <a name="fetch-manifest"></a>Fetch a manifest

To retrieve a previously submitted e-Manifest, you need the e-Manifest ID from
the [Submit a manifest example](#submit-manifest).

```bash
curl -i -X GET https://e-manifest.18f.gov/api/v0/manifest/de305d54-75b4-431b-adb2-eb6b9e546014
```

If you do not know the e-Manifest ID, but you do have the Manifest Tracking Number from Line 4 of form 8700-22,
you can fetch the e-Manifest object with the Manifest Tracking Number.

```bash
curl -i -X GET https://e-manifest.18f.gov/api/v0/manifest/987654321abc
```

The response for both endpoints looks the same:

```json
<%= render 'examples/manifest_response.json' %>
```

## <a name="update-manifest"></a>Update manifest

You may update a previously submitted e-Manifest.

If the manifest has previously been signed, updating it does not change what has been previously signed
(see [Sign a manifest example](#sign-manifest)). You must re-sign the updated e-Manifest.

The update request uses the HTTP `PATCH` method. See [JSON Patch](http://tools.ietf.org/html/rfc6902) and
[JSON Pointer](http://tools.ietf.org/html/rfc6901) for specification details.

Just as in the [Fetch a manifest example](#fetch-manifest), you may use either the e-Manifest ID or the
Manifest Tracking Number.

**TODO do we support changing the manifest tracking number internal to the document as part of a PATCH?**

```bash
curl -i -X PATCH -H 'Content-Type: application/json-patch+json' \
  --data @manifest-patch.json \
  https://e-manifest.18f.gov/api/v0/manifests/de305d54-75b4-431b-adb2-eb6b9e546014
```

or

```bash
curl -i -X PATCH -H 'Content-Type: application/json-patch+json' \
  --data @manifest-patch.json \
  https://e-manifest.18f.gov/api/v0/manifests/987654321abc
```

An example `manifest-patch.json` file looks like:

```json
<%= render 'examples/manifest_patch.json' %>
```

The response format is the same as in the [Fetch a manifest example](#fetch-manifest).

## <a name="search-manifest"></a>Search for manifests

The e-Manifest API supports full-text search of all e-Manifests. You can search with simple terms, or
by specifying specific fields within which your terms should match. Wildcards, booleans and phrase search
are all supported. See the [full query string syntax documentation]
(https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax) for more details.

Example of looking for a manifest by Manifest Tracking Number `987654321abc`:

```bash
curl -i -X GET \
  'https://e-manifest.18f.gov/api/v0/manifests/search?q=content.generator.manifest_tracking_number:987654321abc'
```

You can page through results with the `size` and `from` URL query parameters, and sort results by any field.

```bash
curl -i -X GET \
  'https://e-manifest.18f.gov/api/v0/manifests/search?q=abc123&from=0&size=10&sort[]=id:desc'
```

The search response format looks like:

```json
<%= render 'examples/manifest_search.json' %>
```

## <a name="authenticate-user"></a>Authenticate User

You must authenticate with the CDX CROMERR service for signing a manifest. Values in the response are needed to sign the manifest.

```bash
curl -i -X POST -H 'Content-Type: application/json' \
  --data @auth-creds.json \
  https://e-manifest.18f.gov/api/v0/tokens
```

An example `auth-creds.json` file looks like:

```json
<%= render 'examples/auth_creds.json' %>
```

The authentication response looks like:

```json
<%= render 'examples/auth_response.json' %>
```

You will use the authentication response to [Sign your manifest](#sign-manifest).

## <a name="sign-manifest"></a>Sign manifest

To sign a manifest you must first [Authenticate](#authenticate-user).

You can sign a manifest with either the e-Manifest ID or the Manifest Tracking Number:

```bash
curl -i -X POST -H 'Content-Type: application/json' \
  --data @sign-manifest.json \
  https://e-manifest.18f.gov/api/v0/manifests/de305d54-75b4-431b-adb2-eb6b9e546014/signature
```

where `sign-manifest.json` looks like:

```json
<%= render 'examples/sign_manifest.json' %>
```

## <a name="management-codes"></a>Management method codes

Fetch the list of valid hazardous waste report management method codes like this:

```bash
curl -i -X GET https://e-manifest.18f.gov/api/v0/method_codes
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

