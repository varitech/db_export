require 'environment'

Childcarepro.configure do |config|
  
  config.add_env :default do |e|
    e.host = "localhost"
    e.port = 8080
    e.db_username = "childcarepro"
    e.db_password = "reverse"

    e.instance :childcarepro 
    e.instance :childcarepro3 
  end
  
  config.add_env :staging_54 do |e|
    e.host = '192.168.0.22'
    e.db_host = '192.168.0.8'
    e.db_username = 'ccpuser' 
    e.db_password = 'ccppwd'

    e.instance(:childcarepro_my) { |db| db.database = "childcarepro_my" }
    e.instance :childcarepro1
    e.instance :childcarepro2
    e.instance :childcarepro3
    # e.instance(:childcareproCI) { |db| db.database = 'childcarepro_ci' }
  end
  
  config.add_env :staging_52 do |e|
    e.host = '192.168.0.21'
    e.db_host = '192.168.0.7'
    e.db_username = 'ccpuser' 
    e.db_password = 'ccppwd'
    
    e.instance(:childcarepro_my) { |db| db.database = 'childcarepro_my' }
    e.instance :childcarepro1 
    e.instance :childcarepro2
    e.instance :childcarepro3 
    # e.instance(:childcareproCI) { |db| db.database = 'childcarepro_ci' }
  end

  config.add_env :local_xp do |e|
    e.host = 'local_xp:8080'
    e.db_host = 'local_xp'
    e.db_username = 'ccpuser'
    e.db_password = 'ccppwd'

    e.instance :childcarepro
  end
  
end