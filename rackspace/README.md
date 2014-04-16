First install the `vagrant-rackspace` plugin. Sources are available at https://github.com/mitchellh/vagrant-rackspace.

```
vagrant plugin install vagrant-rackspace
```

Then add a an empty box providing Rackspace boxes


```
vagrant box add rackspace https://github.com/mitchellh/vagrant-rackspace/raw/master/dummy.box

```

After copying `config.yaml.sample` to `config.yaml`  and editing `config.yaml` you can spin up your instance with `vagrant box up --provider=rackspace`
