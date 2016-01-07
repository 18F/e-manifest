## Getting Started

### Running the app locally

0. Copy the secret.rb.template to secret.rb. See below CROMERR Signing
0. Install Ruby
0. Install Bundler (`gem install bundler`)
0. Install Postgres and make sure postgres/bin is on your $PATH.
0. Start postgres if it isn't automatically running: `postgres -D /usr/local/var/postgres`
0. Run `bundle install` to grab the required gems.
0. Use `rake db:create:all` to create the databases.
0. User `rake db:migrate` to transform the database structure to what is
   needed by the app. For test you will need to preface with env variables 
   to indicate the environment: `RACK_ENV=test rake db:migrate`
0. Place environment-specific variables in a `.env.`*environmentname* file. The default is `.env`.
   Test-specific variables can go in `.env.test`. If you have set a postgres username and password,
   use the `DATABASE_URL` environment variable to configure it. See `.env.example` for an example.
   Default database configuration is stored in `config/database.yml`.
0. Run `rake serve`. This will build the Jekyll site and start the Sinatra server.
0. Go to `localhost:9292` and enjoy!

### Development practices

* Everything that's in the "Current" column in
  [Trello](https://trello.com/b/0geMlbgF/epa-emanifest) is fair game.
* When you start work on a task, move it to "Work In Progress" and self-assign.
* Create a branch off of master for each feature and open a pull request when
  development on that feature is ready to be reviewed.
* Once it's ready for review, move the card to "Ready for Review" in Trello
* Assign pull requests you are reviewing to yourself so others know that you are
  reviewing.
* A pull request must receive a thumbs up from at least one person other than
  the author before it can be merged.
* The pull request reviewer merges the pull request when it is ready.
* The merger should also push the updated master branch to production.
* When a feature is reviewed/merged and pushed to production (our only integration
  server) where the client/product owner can verify, move the card to
  "pending acceptance"

### Rake Tasks

- To build the static site, run `rake build`.
- To build and serve the app, run `rake serve`.
- To deploy to 18F's cloud, run `rake deploy`.

To add analytics support needed for production, prepend `JEKYLL_ENV=production` to any of the above commands.

### Running Tests
Server tests are in rspec. Just run `rspec`.

Client tests use karma/mocha/chai:

- [Install node](https://nodejs.org/en/download/stable/)
- `npm install`
- `npm test`

## CROMERR Signing

We submit and sign manifest data to another API known as CDX.

The signing process generally goes under the pseudo-trade name of CROMERR (or
CROMERR-compliant), so you’ll hear both terms in regards to the third party API
we use.

In order to access the development CDX system for CROMERR signing of a manifest,
one needs a system account set up with rights to sign on behalf of authenticated
users. The account credentials are available from the e-Manifest development
team.

The username and password should be placed in a `secret.rb` file located in the root with the following form:

    $cdx_username = "put username here"
    $cdx_password = "put password here"

In other words, `cp secret.rb.template secret.rb` and edit the file with the
supplied API keys.

In addition to these API keys, you will need the username, password, and
security question answers in order to sign in via the web UI. These can also be
obtained via team members.

## Public domain

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
