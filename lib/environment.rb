require 'ostruct'

module Childcarepro
  
  class << self
    def configuration
      @configuration ||= Childcarepro::Configuration.new
    end
    
    def configure
      yield configuration
      target_env = ENV['EXPORT_ENV'] ? ENV['EXPORT_ENV'].to_sym : :default
      @environment = configuration.environments[target_env]
    end

    def environment
      @environment
    end
  end
  
  class Configuration
    def environments
      @environments ||= {}
    end

    def add_env(sym)
      yield (environments[sym] = Childcarepro::Environment.new)
    end
  end
  
  class Environment < OpenStruct
    
    def instance(sym)
      db = OpenStruct.new
      yield db if block_given?
      instances[sym] = {adapter: "mysql2", 
                        host: db.host || self.db_host || self.host, 
                        port: 3306, 
                        username: db.username || self.db_username, 
                        password: db.password || self.db_password, 
                        database: db.database || sym.to_s }
    end
   
    def instances
      @instances ||= {}
    end
    
    def db_config
      instances[current_instance]
    end
    
    def current_instance
      @instance_key ||= ENV['EXPORT_ENV']? ENV['EXPORT_ENV'].to_sym : instances.first[0]
    end
  end
end