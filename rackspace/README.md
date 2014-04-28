First install the `vagrant-rackspace` plugin. Sources are available at https://github.com/mitchellh/vagrant-rackspace.

```
vagrant plugin install vagrant-rackspace
```

Then add a an empty box providing Rackspace boxes


```
vagrant box add rackspace https://github.com/mitchellh/vagrant-rackspace/raw/master/dummy.box
```

After copying `configuration.yaml.sample` to `configuration.yaml`  and editing `configuration.yaml` you can spin up your instance with `vagrant box up --provider=rackspace`


![B1 Systems Logo](http://b1-systems.de/typo3temp/GB/8efb9aa347.png)

Powered by [B1 Systems](http://www.b1-systems.de).
