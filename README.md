ohai-plugin-passwd_extended
============================

The passwd_extended Ohai plugin expands on the information retrieved by the passwd plugin distribute with Ohai.

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

Apache License 2.0
