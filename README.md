# The e-Manifest App for EPA

Visit [18F Consulting](https://pages.18f.gov/consulting/projects/epa/e-manifest/) for details about this project, or check out our [Trello board](https://trello.com/b/0geMlbgF/epa-emanifest) to see what we're working on right now.

This is a Ruby/Sinatra/Angular app, with a Jekyll static site in the `_static` directory. The Jekyll site will be generated in the `public/` directory, which Sinatra routes to automatically.

Don't edit the `public/` folder directly! Jekyll will overwrite everything when building the site.

[View the live application »](https://e-manifest.18f.gov)

## Running Locally

0. Copy the secret.rb.template to secret.rb. See below CROMERR Signing
1. Install Ruby
2. Install Bundler (`gem install bundler`)
3. Install Postgres and make sure postgres/bin is on your $PATH.
4. Start postgres if it isn't automatically running: `postgres -D /usr/local/var/postgres`
5. Run `bundle install` to grab the required gems.
4. Use `rake db:create:all` to create the databases.
5. User `rake db:migrate` to transform the database structure to what is
   needed by the app. For test you will need to preface with env
variables to indicate the environment: `RACK_ENV=test rake db:migrate`
6. Run `rake serve`. This will build the Jekyll site and start the Sinatra server. If you have set a postgres username and password, try this: `DATABASE_URL=postgres://<postgres user>:<password>@localhost/e-manifest rake serve` or configure the DATABASE_URL environment variable as you see fit. Otherwise the app will just use the config/database.yml.
7. Go to `localhost:9292` and enjoy!

## Rake Tasks

- To build the static site, run `rake build`.
- To build and serve the app, run `rake serve`.
- To deploy to 18F's cloud, run `rake deploy`.

To add analytics support needed for production, prepend `JEKYLL_ENV=production` to any of the above commands.

## Running Tests
Server tests are in rspec. Just run `rspec`.

Client tests use karma/mocha/chai:

- [Install node](https://nodejs.org/en/download/stable/)
- `npm install`
- `npm test`


## CROMERR Signing

In order to access the development CDX system for CROMERR signing of a manifest, one needs a system account set up with rights to sign on behalf of authenticated users.

The username and password should be placed in a `secret.rb` file located in the root with the following form:

	$cdx_username = "put username here"
	$cdx_password = "put password here"

In other words, `cp secret.rb.template secret.rb` and edit the file.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
