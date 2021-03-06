# author: Christian Berendt <berendt@b1-systems.de>

require 'yaml'
CONFIG = YAML.load(File.open(File.join(File.dirname(__FILE__), "configuration.yaml"), File::RDONLY).read)

VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # solves issue 1673 (https://github.com/mitchellh/vagrant/issues/1673)
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.define "devstack" do |devstack|

    devstack.vm.box = CONFIG['box']
    devstack.vm.hostname = CONFIG['hostname']

    devstack.vm.network :public_network, bridge: 'en0:'
    
    devstack.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "16384"]
      vb.customize ["modifyvm", :id, "--cpus", "8"]
    end

    devstack.vm.provision :shell, :path => "files/bootstrap.sh"

    devstack.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "site.pp"
      puppet.facter = {
        "devstack_password"     => CONFIG['password'],
        "devstack_hostname"     => CONFIG['hostname'],
        "git_name"              => CONFIG['name'],
        "gitreview_username"    => CONFIG['username'],
        "git_email"             => CONFIG['email'],
        "enable_ssh"            => CONFIG['enable_ssh'],
        "enable_git"            => CONFIG['enable_git'],
        "remote_address"        => CONFIG['remote_address'],
        "run_stack"             => CONFIG['run_stack'],
        "venv"                  => CONFIG['venv'],
        "more_network_services" => CONFIG['more_network_services'],
        "more_images"           => CONFIG['more_images'],
        "use_heat"              => CONFIG['use_heat'],
        "use_ceilometer"        => CONFIG['use_ceilometer'],
        "use_ldap"              => CONFIG['use_ldap'],
        "use_swift"             => CONFIG['use_swift'],
      }
    end

  end

end
