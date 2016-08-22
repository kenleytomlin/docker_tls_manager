Feature: DockerTLSManager
  In order to configure the users environment
  As a CLI
  I want to set environment variables

  Scenario:
    When I run `docker_tls_manager env example.com`
    Then the exit status should be 0
    And the output should contain "export DOCKER_TLS_VERIFY=1"
    And the output should contain "export DOCKER_CERT_PATH=~/.docker/example.com/"
    And the output should contain "export DOCKER_HOST=example.com"
