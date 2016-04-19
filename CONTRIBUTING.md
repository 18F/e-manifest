## Getting Started

### Running the app locally

0. Install Ruby (RVM / Rbenv or another Ruby version manager is ideal for easy version updates)
0. Install Bundler (`gem install bundler`) and foreman (`gem install foreman`)
0. Install Postgres and make sure postgres/bin is on your $PATH.
0. Start Postgres if it isn't automatically running: `postgres -D /usr/local/var/postgres`
0. Install Elasticsearch and make sure it is running.
0. Install Redis and make sure it is running.
0. Install
[PhantomJS](https://github.com/jonleighton/poltergeist#installing-phantomjs)
(used for running Capybara tests with JavaScript turned on)
0. Run `./bin/setup` to initialize the rails application and install the
   necessary dependencies.
0. Edit the environment-specific variables in a `.env`.
   Test-specific variables can go in `.env.test`.
   Default database configuration is stored in `config/database.yml`.
0. Add the CROMERR account credentials (CDX_USERNAME and CDX_PASSWORD) to `.env`.
0. Run `rake secret` and set the output as the value for `SECRET_KEY_BASE` in `.env`.
0. Run `foreman start` to start the Rails application.
0. Go to `http://localhost:5000` and enjoy!

### Development practices

* Everything in the "Current" column in
  [Trello](https://trello.com/b/0geMlbgF/epa-emanifest) is fair game.
* When you start work on a task, move it to "Work In Progress" and self-assign.
* Create a branch off of master for each feature and open a pull request when
  development on that feature is ready to be reviewed.
* Once it's ready for review, move the card to "Ready for Review" in Trello.
* Assign pull requests you are reviewing to yourself so others know that you are
  reviewing.
* A pull request must receive a thumbs up from at least one person other than
  the author before it can be merged.
* We generally require test coverage for all pull requests, but we are not
  dogmatic about it. If something is difficult to test and the reason for why is
  explained, an un-tested pull request may be accepted.
* We write Request specs for API integration tests, feature specs (with
  Capybara) for web integration tests, and RSpec unit tests for new Ruby classes /
  methods. These are all in the `spec` directory of the app.
  Capybara specs are in `spec/features` and request specs are in `spec/requests`.
* The tests are run by the Travis CI service on every pull request and we do not
  merge pull requests with broken tests.
* The pull request reviewer merges the pull request when it is ready.
* The merger should also push the updated master branch to production.
* When a feature is reviewed/merged and pushed to production (our only integration
  server) where the client/product owner can verify, move the card to
  "pending acceptance".

### One-off Tasks

- To add dummy data for developing against, run `rake populate:manifests RANDOMIZE_CREATED_AT=true`.
- To (re)build the Elasticsearch index, run `rake search:index FORCE=y`.
- Run `bundle update` to grab any updated gems.
- To update the database schema, run `rake db:migrate`. For test you will need to preface with env variables to indicate the environment: RACK_ENV=test rake db:migrate

### Running Tests

Server tests are in rspec. Just run `rspec`.

### Load Tests

Load testing requires manually installing some gems.

```bash
% gem install tourbus faraday faraday_middleware excon test-unit
```

See the [tourbus docs](https://github.com/dbrady/tourbus).

A file named `test_cdx_config.yml` is expected at the root of the application. You can obtain a copy of this file,
not stored in git, from a team member.

Running the tests uses the `tourbus` command:

```bash
% tourbus -n 100 -c 3 post_manifest
% tourbus -n 100 -c 3 get_manifest
% tourbus -n 100 -c 3 search_manifest
```

For any HTTP requests that do not require unique data (such as searching or fetching a known manifest)
you can also use the `ab` Apache Bench command.

```bash
% ab -n 100 -c 3 'http://localhost:5000/api/v0/manifests/search?q=generator'
% ab -n 100 -c 3 'http://localhost:5000/api/v0/manifests/someknownUUIDhere'
```

The `ab` tool has better reporting but cannot handle things like POSTing a unique manifest tracking number per request.

### Deploying to cloud.gov

* To deploy to *e-manifest.18f.gov*: `cf target -o epa-emanifest -s prod && script/deploy e-manifest`
* To deploy to *e-manifest-dev.18f.gov*: `cf target -o epa-emanifest -s dev && script/deploy e-manifest-dev`

## CROMERR Signing

We submit and sign manifest data to another API known as [CDX](https://cdx.epa.gov/).

The signing process generally goes under the pseudo-trade name of [CROMERR](https://www.epa.gov/cromerr) (or
CROMERR-compliant), so you’ll hear both terms in regards to the third party API
we use.

You need a system account set up with rights to sign on behalf of authenticated
users to access the development CDX system for CROMERR signing of a manifest. The account credentials are available from the e-Manifest development team.

The username and password env variables should be in the `.env` file
located in the root with the following form:

    CDX_USERNAME = "put username here"
    CDX_PASSWORD = "put password here"

In addition to these API keys, you need the username, password, and security question answers in order to sign in via the web UI. These can also be obtained via team members.

The `CDX_LOG` and `CDX_COLOR` environment variables control the verbosity and style of the CDX
model logging.

See also the [Authentication and Authorization architecture documentation](doc/authorization.md).

## Public domain

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
