require "cocaine"

module DockerTlsManager
  class CA
    attr_reader :out_directory
    attr_reader :private_key_name
    attr_reader :cert_name
    attr_reader :days
    attr_reader :country
    attr_reader :pass

    def initialize(opts)
      raise ArgumentError.new "opts must contain pass" unless opts[:pass]
      @out_directory = opts[:out_directory] ||= File.join(ENV['HOME'],'/.docker/ca')
      @private_key_name = opts[:private_key_name] ||= "ca-key.pem"
      @cert_name = opts[:cert_name] ||= "ca.pem"
      @days = opts[:days] ||= 365
      @country = opts[:country] ||= "US"
      @pass = opts[:pass]
    end

    def generate(force = false)
      if File.exist?(@out_directory) and force == false
        raise StandardError.new "CA already exists at path #{@out_directory}"
      else
        begin
          Dir.rmdir @out_directory unless force == false
          Dir.mkdir @out_directory
          key_line = Cocaine::CommandLine.new("openssl","genrsa -aes256 -out :out 4096")
          key_line.command(out: File.join(@out_directory,@private_key_name))
          key_line.run

          cert_line = Cocaine::CommandLine.new("openssl","req -new -x509 -days :days -key :key -sha256 -out :out")
          cert_line.command({ days: @days, key: File.join(@out_directory,@private_key_name), out: File.join(@out_directory,@cert_name) })
          cert_line.run
        rescue
          puts "Error creating the CA"
        end
      end
    end
  end
end
