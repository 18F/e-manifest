# The e-Manifest App for EPA

[View the live application »](https://e-manifest.18f.gov)

[![Build Status](https://travis-ci.org/18F/e-manifest.svg?branch=master)](https://travis-ci.org/18F/e-manifest)
[![Code
Climate](https://codeclimate.com/github/18F/e-manifest/badges/gpa.svg)](https://codeclimate.com/github/18F/e-manifest)

## Application architecture

This is a Rails application with a Postgres database. The app contains both API
endpoints and web views. The API is a JSON REST API. The web app and the API
use the same database.

Elasticsearch is used to search for manifest records. Elasticsearch offloads
read-access from the database and provides full-text search that can be painful
to apply directly to a database

Redis is being used for Sidekiq job processing. The Redis + Sidekiq solution
offloads the database/Elasticsearch syncing to an async process.

## Developer onboarding

Here are some tips and resources for getting started on this project. Note that
not all of these resources are available to people outside of the EPA / 18F for
security reasons.

* Join the `#c-epa-emanifest` and `#e-manifest-partners` channels in the 18F
  Slack organization.
* Ask in Slack for the Vendor Onboarding document for background on the problem space.
* Read the [project
  brief](https://docs.google.com/document/d/1v_rRaV5euxmBdH8D_Huo37kN3Yu76sNn2TXVJJB4v40/edit).
* Make sure you've been added to the [Trello
  board](https://trello.com/b/0geMlbgF/epa-emanifest).
* Set up the app using the instructions in [CONTRIBUTING.md](CONTRIBUTING.md).

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
