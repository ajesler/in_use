# InUse

An API for managing the in use status of a `thing`.

### Development

`brew cask install ngrok`
`brew install httpie`

### Troubleshooting

When installing on a server with 512 mb of memory or less, you may need to install nokogiri manually if bundle install fails with a `Killed` error.

Something like `GEM_HOME=/home/deploy/apps/in_use/shared/bundle/ruby/2.3.0/ gem install nokogiri -v 1.8.0` should work, then run capistrano deploy as ususal.

`cap production deploy:initial` is not failing after the nokogiri native extensions build is killed.

`https://api.slack.com/apps to manage your apps, not `https://<slack-team-name>.slack.com/apps/manage`.
