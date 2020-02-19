require "./systemd"

module Wsman
  module External
    class Solr
      def initialize(@config : Wsman::ConfigManager)
        @systemd = Wsman::External::Systemd.new(@config)
      end

      def create_or_update_container(sorl_version, dcompose)
        if dcompose_changed?(sorl_version, dcompose)
          cores_path = File.join(@config.solr_data_path, @config.solr_version_name(sorl_version), "cores")
          Dir.mkdir_p(cores_path)
          File.chown(cores_path, uid: "8983", gid: "8983")
          save_dcompose(sorl_version, dcompose)
          @systemd.solr_instance_enable(@config.solr_version_name(sorl_version))
          @systemd.solr_instance_start(@config.solr_version_name(sorl_version))
        end
      end

      def create_core(solr_version, core)
        #TODO
      end

      def dcompose_changed?(sorl_version, dcompose)
        dc_file = dcompose_file(sorl_version)
        if File.exists?(dc_file)
          current_dc = File.read(dc_file)
          dcompose != current_dc
        else
          true
        end
      end

      def save_dcompose(sorl_version, dcompose)
        File.write(dcompose_file(sorl_version), dcompose)
      end

      def dcompose_file(sorl_version)
        File.join(@config.solr_data_path, @config.solr_version_name(sorl_version), @config.docker_compose_filename)
      end
    end
  end
end
