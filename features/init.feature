Feature: DockerTLSManager
  In order to create a ca
  As a CLI
  I want to create a certificate authority

  Scenario:
    When I run `docker_tls_manager init`
    Then the exit status should be 0
    And the output should contain "ca generated for example.com and output to ~/.docker/ca"
