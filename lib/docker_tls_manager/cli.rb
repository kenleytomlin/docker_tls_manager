require 'thor'
require 'lib/docker_tls_manager/ca'

module DockerTlsManager
  class CLI < Thor

    desc "init", "Initialises a certificate authority"
    def init
      puts "ca generated"
    end

    desc "generate domain", "Generate certificates for the domain"
    def generate(domain)
      puts "files generated for #{domain} and output to ~/.docker/#{domain}/"
    end

    desc "env domain", "Output export statements for docker client"
    def env(domain)
      puts "export DOCKER_CERT_PATH=~/.docker/#{domain}/"
      puts "export DOCKER_TLS_VERIFY=1"
      puts "export DOCKER_HOST=#{domain}"
    end
  end
end
