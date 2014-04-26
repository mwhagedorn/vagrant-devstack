#!/usr/bin/python

# author: Christian Berendt <berendt@b1-systems.de>

import os
import semantic_version
import vagrantcloud
import yaml

with open(os.path.join(
        os.path.dirname(os.path.realpath(__file__)),
        'configuration.yaml')
    ) as configuration_file:
    configuration = yaml.load(configuration_file)

client = vagrantcloud.Client(
    configuration.get('vagrantcloud_username'),
    configuration.get('vagrantcloud_access_key')
)

box = client.get_box('berendt/devstack-ubuntu-14.04-amd64')

if len(box.versions) > 1:
    oldest = box.versions.itervalues().next()
    oldest.revoke()
    oldest.delete()

# add the new version
latest = box.versions.keys()[-1]
latest.patch = latest.patch + 1
version = box.add_version(str(latest))
version.description = "![B1 Systems Logo](https://b1-systems.de/typo3temp/GB/8efb9aa347.png)\n\nPowered by [B1 Systems](http://www.b1-systems.de)."
version.update()

# add the virtualbox provider with the new url
provider = version.add_provider("virtualbox")
provider.hosted = 'false'
provider.original_url = "http://share.cabtec.net/vagrant/devstack-ubuntu-14.04-amd64-{}.box".format(str(latest))
provider.update()

# release the new version
version.release()
