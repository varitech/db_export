require 'active_record'
require 'ccp_dbmodel'

module Childcarepro::DbExport
      class DatabaseEnumerator
        def initialize(instances)
          @instances=instances
        end
        
        def each_instance
          @instances.each do |name, connection|
            puts name
            ActiveRecord::Base.establish_connection(connection)
            yield
          end
        end
      end
end