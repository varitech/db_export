require 'active_record'
require 'ccp_dbmodel'

module Childcarepro::DbExport
      class DatabaseEnumerator
        def initialize(instances)
          @instances=instances
        end
        
        def each_instance
          @instances.each do |name, connection|
            puts connection
            conn=ActiveRecord::Base.establish_connection(connection)
            yield
            conn.disconnect!
          end
        end
      end
end