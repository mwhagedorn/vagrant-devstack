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

    devstack.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
    devstack.vm.network "forwarded_port", guest: 6080, host: 8081, host_ip: "127.0.0.1"

    devstack.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "16384"]
      vb.customize ["modifyvm", :id, "--cpus", "8"]
    end

    devstack.vm.provision :shell, :path => "files/bootstrap.sh"

    devstack.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "site.pp"
      puppet.facter = {
        "devstack_password"  => CONFIG['password'],
        "devstack_hostname"  => CONFIG['hostname'],
        "git_name"           => CONFIG['name'],
        "gitreview_username" => CONFIG['username'],
        "git_email"          => CONFIG['email'],
        "enable_ssh"         => CONFIG['enable_ssh'],
        "run_stack"          => CONFIG['run_stack'],
        "venv"               => CONFIG['venv'],
      }
    end

  end

end
