ENV["SINATRA_ENV"] ||= "development"
require 'bundler/setup'

Bundler.require(:default, ENV['SINATRA_ENV'])
ActiveRecord::Base.logger = Logger.new(STDOUT)

configure :development do
  db_config = YAML.load_file('config/database.yml')
  ActiveRecord::Base.establish_connection(db_config['development'])
end

require_all 'app'
