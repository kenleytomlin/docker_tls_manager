Feature: DockerTLSManager
  In order to manage docker tls certificates for different domains
  As a CLI
  I want to generate certificates

  Scenario:
    When I run `docker_tls_manager generate example.com`
    Then the exit status should be 0
    And the output should contain "files generated for example.com and output to ~/.docker/example.com/"

