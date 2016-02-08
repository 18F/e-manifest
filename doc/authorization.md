# e-Manifest Authentication and Authorization

## Overview

The [CDX development environment](https://devngn.epacdxnode.net/) provides User authentication and authorization 
services. The e-Manifest application delegates all storage and management to CDX,
and communicates with the CDX SOAP API via the `CDX::*` model classes.
For efficiency, the e-Manifest application caches some CDX data locally
in Redis and Postgres.

## UserAuthenticator and UserSession

Authentication is performed by the `UserAuthenticator` class, and the results
are managed via the `UserSession` class. UserSession stores minimal 
PII (personally identifiable information) such as name and user id
in Redis so that the data is automatically expired.

Two separate authentication steps are possible for a given e-Manifest
transaction: (1) to simply authenticate for UI and/or API use,
and (2) to sign a manifest. Though the steps are distinct, they may
share a single UserSession object.

## UserProfileBuilder and UserProfileSyncer

Authorization is performed via the [Pundit gem](https://github.com/elabs/pundit).
CDX User, Organization and Role profile information is cached locally in Postgres
via the `UserProfileBuilder` and `UserProfileSyncer` classes. Postgres is used
to persist authorization profiles beyond the short lifespan of a `UserSession`
because authorization roles must be included in the Elasticsearch indices which
may be re-built asynchronously to any given user session.
