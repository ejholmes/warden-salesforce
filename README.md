warden-salesforce
=============

A [warden](http://github.com/hassox/warden) strategy that provides oauth authentication to salesforce.
If you have the databasedotcom gem included in your Gemfile, you'll also get a
`Databasedotcom::Client` instance materialized for you automatically at
`env['warden'].user.client`.

To test it out on localhost set your callback url to 'http://localhost:9292/auth/salesforce/callback'

There's an example app in [spec/app.rb](/ejholmes/warden-salesforce/blob/master/spec/app.rb).

The Extension in Action
=======================
    % gem install bundler
    % bundle install
    % SALESFORCE_CLIENT_ID="<from SF>" SALESFORCE_CLIENT_SECRET="<from GH>" bundle exec rackup -p9393 -E none
