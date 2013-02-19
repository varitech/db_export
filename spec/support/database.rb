require 'database_cleaner'
require 'active_record'
require 'logger'

connection = {
  adapter: 'mysql2',
  database: 'childcarepro',
  user: 'ubuntu',
  password: 'reverse'
}

ActiveRecord::Base.establish_connection(connection)
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.start

require 'ccp_dbmodel'
