## OhaiPasswdExtended
#
# This is a module of functions to be used in the PasswdExtended Ohai
# plugin.
#
module OhaiPasswdExtended
  module_function

  # Returns the date portion (in string form) parses date out of string
  #
  # Args:
  #   * output - string that comes from lastlog/lastlogin commands
  def find_date(output)
    begin
      str = output.split(" ")
    rescue
      # The split command above, outside this begin/rescue block, fails on
      # FreeBSD for an unknown reason. wrapping the split() command above
      # with begin/rescue on FreeBSD makes it work. It won't need rescue.
      # The command will work as obviously intended inside begin/rescue.
      # So you shouldn't get here.
      str = "WTF"
    end

    days = %w{Sun Mon Tue Wed Thu Fri Sat}
    if days.include?(str[3])
      day_index = 3
    else
      day_index = 2
    end

    if str[1] =~ /Never|fread/
      datestr = "Never"
    elsif days.include?(str[day_index])
      datestr = str[day_index..-1].join(" ")
    else
      datestr = "Unknown"
    end

    datestr
  end
end

if defined?(Ohai)
  Ohai.plugin(:PasswdExtended) do
    provides "etc/passwd_extended"
    depends "etc"
    include OhaiPasswdExtended

    def fix_encoding(str)
      if str.respond_to?(:force_encoding)
        str.force_encoding(Encoding.default_external)
      end
      str
    end

    collect_data do
      etc["passwd_extended"] = Mash.new unless etc["passwd_extended"]
      Etc.passwd do |entry|
        # Looping through users, start with some variable setup
        entry_name = fix_encoding(entry.name)
        entry_homedir = fix_encoding(entry.dir)
        unless etc["passwd_extended"][entry_name]
          etc["passwd_extended"][entry_name] = Mash.new
        end

        # Find last login time
        last_login_cmd = "/usr/bin/lastlog -u #{entry_name}"
        last_login = shell_out(last_login_cmd)
        if last_login.exitstatus == 0
          output = last_login.stdout.split(/\r?\n/).last
          etc["passwd_extended"][entry_name]["lastlogin"] = find_date(output)
        end

        # Find out if user has SSH key
        if File.exist?(entry_homedir + "/.ssh/authorized_keys")
          etc["passwd_extended"][entry_name]["sshkey_login"] = true
        else
          etc["passwd_extended"][entry_name]["sshkey_login"] = false
        end

        # Find out if user has crontab
        if File.exist?("/var/spool/cron/crontabs/#{entry_name}")
          etc["passwd_extended"][entry_name]["user_crontab"] = true
        else
          etc["passwd_extended"][entry_name]["user_crontab"] = false
        end

        # Figure out account lock status
        pw_status_cmd = "/usr/bin/passwd -S #{entry_name}"
        pw_status = shell_out(pw_status_cmd)
        if pw_status.exitstatus == 0
          output = pw_status.stdout.split(" ")
          case output[1]
          when "L"
            etc["passwd_extended"][entry_name]["pw_login"] = "Locked"
          when "NP"
            etc["passwd_extended"][entry_name]["pw_login"] = "No Password"
          when "P"
            etc["passwd_extended"][entry_name]["pw_login"] = "Normal"
          end
        end
      end
    end

    collect_data(:freebsd) do
      etc["passwd_extended"] = Mash.new unless etc["passwd_extended"]
      Etc.passwd do |entry|
        # Looping through users, start with some variable setup
        entry_name = fix_encoding(entry.name)
        entry_homedir = fix_encoding(entry.dir)
        unless etc["passwd_extended"][entry_name]
          etc["passwd_extended"][entry_name] = Mash.new
        end

        # Find last login time
        last_login_cmd = "/usr/sbin/lastlogin #{entry_name}"
        last_login = shell_out(last_login_cmd)
        if last_login.exitstatus == 0
          output = last_login.stdout.split(/\r?\n/).last
          etc["passwd_extended"][entry_name]["lastlogin"] = find_date(output)
        end

        # Find out if user has SSH key
        if File.exist?(entry_homedir + "/.ssh/authorized_keys")
          etc["passwd_extended"][entry_name]["sshkey_login"] = true
        else
          etc["passwd_extended"][entry_name]["sshkey_login"] = false
        end

        # Find out if user has crontab
        if File.exist?("/var/cron/tabs/#{entry_name}")
          etc["passwd_extended"][entry_name]["user_crontab"] = true
        else
          etc["passwd_extended"][entry_name]["user_crontab"] = false
        end

        # Figure out account lock status
        pw_status_cmd = "/usr/bin/getent passwd #{entry_name}"
        pw_status = shell_out(pw_status_cmd)
        if pw_status.exitstatus == 0
          output = pw_status.stdout.split(":")[1]
          case output
          when /\*LOCKED\*/
            etc["passwd_extended"][entry_name]["pw_login"] = "Locked"
          when "*"
            etc["passwd_extended"][entry_name]["pw_login"] = "No Password"
          else
            etc["passwd_extended"][entry_name]["pw_login"] = "Normal"
          end
        end
      end
    end
  end
end
