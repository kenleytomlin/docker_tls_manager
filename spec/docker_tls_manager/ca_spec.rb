require 'spec_helper'

describe DockerTlsManager::CA do
  describe "initialize" do
    context "when all the custom options are supplied" do
      it "returns a DockerTlsManager::CA instance" do
        opts = {
          out_directory: "spec/fixtures/ca",
          private_key_name: "my-ca-key.pem",
          cert_name: "my-ca.pem",
          days: 10,
          country: "KR",
          pass: "abcd"
        }
        expect(described_class.new(opts)).to be_a DockerTlsManager::CA
      end
    end

    context "when all the required options are supplied" do
      it "uses the defaults" do
        ca = described_class.new pass: "password"

        expect(ca).to be_a DockerTlsManager::CA
        expect(ca.out_directory).to eql "#{ENV['HOME']}/.docker/ca"
        expect(ca.private_key_name).to eql "ca-key.pem"
        expect(ca.cert_name).to eql "ca.pem"
        expect(ca.days).to eql 365
        expect(ca.country).to eql "US"
        expect(ca.pass).to eql "password"
      end
    end

    context "when the pass is not supplied" do
      it "raises an error" do
        expect {
          described_class.new no_pass: "abc"
        }.to raise_error ArgumentError, "opts must contain pass"
      end
    end
  end

  describe "generate" do
    let(:opts) { { pass: "abcd" } }
    let(:fake_cocaine) { instance_double(Cocaine::CommandLine).as_null_object }

    before :each do
      allow(Cocaine::CommandLine).to receive(:new).and_return fake_cocaine
      allow(Dir).to receive(:mkdir).and_return 0
      allow(Dir).to receive(:rmdir).and_return 0
      allow(File).to receive(:exist?).and_return false
    end

    context "when OpenSSL is available" do

      it "creates the directory if it doesn't exist" do
        ca = described_class.new opts
        expect(Dir).to receive(:mkdir).with ca.out_directory

        ca.generate
      end

      it "calls cocaine instance with the correct arguments" do
        ca = described_class.new opts
        expect(fake_cocaine).to receive(:command).with({ out: "#{ca.out_directory}/#{ca.private_key_name}" })
        expect(fake_cocaine).to receive(:command).with({ out: "#{ca.out_directory}/#{ca.cert_name}", key: "#{ca.out_directory}/#{ca.private_key_name}", days: ca.days })

        ca.generate
      end

      it "calls cocaine.run" do
        ca = described_class.new opts
        expect(fake_cocaine).to receive(:run).twice

        ca.generate
      end
    end

    context "when the ca-key and cert exist and force is false" do
      it "raises an error" do
        ca = described_class.new opts
        allow(File).to receive(:exist?).and_return true
        expect {
          ca.generate
        }.to raise_error StandardError, "CA already exists at path #{ca.out_directory}"
      end
    end

    context "when the ca-key and cert exist and force is true" do
      it "calls Dir.rmdir and creates a new ca" do
        ca = described_class.new opts
        allow(File).to receive(:exist?).and_return true
        expect(Dir).to receive(:rmdir).with(ca.out_directory)

        ca.generate(true)
      end
    end
  end
end
