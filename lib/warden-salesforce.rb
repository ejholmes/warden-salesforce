require 'warden'
require 'oauth2'
require 'yajl'
begin
  require 'databasedotcom'
rescue LoadError
end

module Warden
  module Salesforce
    class SalesforceMisconfiguredError < StandardError; end
  end
end

require 'warden-salesforce/version'
require 'warden-salesforce/user'
require 'warden-salesforce/strategy'
