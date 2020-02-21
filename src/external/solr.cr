require "./systemd"

module Wsman
  module External
    class Solr
      def initialize(@config : Wsman::ConfigManager)
        @systemd = Wsman::External::Systemd.new(@config)
      end

      def create_or_update_container(solr_version, dcompose)
        if dcompose_changed?(solr_version, dcompose)
          cores_path = cores_path_by_version(solr_version)
          Dir.mkdir_p(cores_path)
          File.chown(cores_path, uid: 8983, gid: 8983)
          save_dcompose(solr_version, dcompose)
          @systemd.solr_instance_enable(@config.solr_version_name(solr_version))
          @systemd.solr_instance_start(@config.solr_version_name(solr_version))
        end
      end

      def create_core(solr_version, corename, solr_core_config_zip)
        core_path = cores_path_by_version(solr_version)
        core_conf_path = File.join(core_path, corename, "conf")
        Dir.mkdir_p(core_conf_path)
        Wsman::Util.cmd("unzip", ["-o", solr_core_config_zip, "-d", core_conf_path])
        File.write(File.join(core_conf_path, "..", "core.properties"), "name=#{corename}")
        Dir["#{core_path}/**/*"].each do |path|
          File.chown(path, uid: 8983, gid: 8983)
        end
        @systemd.solr_instance_restart(@config.solr_version_name(solr_version))
      end

      def dcompose_changed?(solr_version, dcompose)
        dc_file = dcompose_file(solr_version)
        if File.exists?(dc_file)
          current_dc = File.read(dc_file)
          dcompose != current_dc
        else
          true
        end
      end

      def save_dcompose(solr_version, dcompose)
        File.write(dcompose_file(solr_version), dcompose)
      end

      def dcompose_file(solr_version)
        File.join(@config.solr_data_path, @config.solr_version_name(solr_version), @config.docker_compose_filename)
      end

      def cores_path_by_version(solr_version)
        File.join(@config.solr_data_path, @config.solr_version_name(solr_version), "cores")
      end

      def delete_core()
        #TODO
      end

      def delete_solr_instance()
        #TODO
      end
    end
  end
end
