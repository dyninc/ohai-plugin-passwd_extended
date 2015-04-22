ohai-plugin-passwd_extended
============================

The passwd_extended Ohai plugin expands on the information retrieved by the passwd plugin distribute with Ohai.

Installation via Chef recipe
-----------------------------

* Put the passwd_extended.rb file from lib/ into your cookbook's files tree.
* Put the following code in your recipe.

```
include_recipe "ohai::default"

cookbook_file "#{node['ohai']['plugin_path']}/passwd_extended.rb" do
  source "passwd_extended.rb"
  action :create
  notifies :reload, "ohai[reload_set_attributes]", :immediately
end
```

Usage
------

via ohai command

```
$ ohai -d /path/to/plugin_dir | jq .passwd_extended
```

```json
{
  "root": {
    "lastlogin": "Wed Feb 4 14:35:19 -0500 2015",
    "pw_login": "Locked",
    "sshkey_login"=>false,
    "user_crontab"=>false
  }
}
```

via Ohai module in your scripts

```ruby
require 'ohai'
Ohai::Config[:plugin_path] << '/path/to/plugin_dir'
oh = Ohai::System.new
oh.all_plugins
oh["etc"]["passwd_extended"]
oh["etc"]["passwd_extended"]["USERNAME"]["lastlogin"]  #= Never, or a date
oh["etc"]["passwd_extended"]["USERNAME"]["pw_login"]  #= Locked or Normal or No Password
oh["etc"]["passwd_extended"]["USERNAME"]["sshkey_login"]  #= true or false
oh["etc"]["passwd_extended"]["USERNAME"]["user_crontab"]  #= true or false
```

via Chef

```ruby
# (client|solo).rb
Ohai::Config[:plugin_path] << '/path/to/plugins'
```

```ruby
# in cookbook
node["etc"]["passwd-extended"]
```

Author
======

Neil Schelly <nschelly@dyn.com>

License
=======

Copyright:: 2015, Dyn Inc

Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations
under the License.
