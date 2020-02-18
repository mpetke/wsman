require "crinja"

module Wsman
  module Model
    @[Crinja::Attributes]
    class SolrCoreConfig
      include Crinja::Object::Auto
      getter corename, confname, solr_version
      def initialize(@corename : String, @confname : String, @solr_version : String)
      end
    end
  end
end
