require "./systemd"

module Wsman
  module External
    class Solr
      def initialize(@config : Wsman::ConfigManager)
        @systemd = Wsman::External::Systemd.new(@config)
      end

      def create_container(sorl_version, dcompose)
        #TODO
        if dcompose_changed?(dcompose)
          save_dcompose(sorl_version, dcompose)
        end

      end

      def create_core(solr_version, core)
        #TODO
      end

      def dcompose_changed?(dcompose)
        dc_file = File.join(@config.solr_data_path, dcompose_filename)
        if File.exists?(dc_file)
          current_dc = File.read(dc_file)
          dcompose != current_dc
        else
          true
        end
      end

      def save_dcompose(dcompose)
        File.write(File.join(@config.solr_data_path, dcompose_filename), dcompose)
      end

      def dcompose_filename
        "solr-#{@config.solr_version_name(sorl_version)}"
      end


end
