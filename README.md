# i2p-mail-fwd
Forwards email from I2P to your clearnet email. Encrypts it all so your clearnet email provider can't snoop on anything.

## Installing
* Make sure you have ruby 3.2.2 installed (use a ruby manager such as rvm or rbenv)
* Make sure you have gpg installed
* Clone the repo
* Run `bundle install`
* Copy `config/config.yaml.example` to `config/config.yaml` and fill out the values
* Run `bundle exec whenever --update-crontab`
