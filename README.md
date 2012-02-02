## Overview

A simple tool for writing ruby scripts to manage your Mac OS X system.

## Examples

### Run a Recipe

    $ ct recipe_file
    $ ct recipe_file --noop
    $ ct recipe_file -n

### Package

    package "name"
    
### File

    redis_conf_path = File.join(current_path, "redis.conf")
    file "/usr/local/etc/redis", File.read(redis_conf_path)

### Script

    MYSQL_DB_PATH = "/usr/local/var/mysql"
    unless File.directory?(MYSQL_DB_PATH)
      script "initialize mysql database", true, <<-EOS
        unset TMPDIR
        mysql_install_db --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
      EOS
    end

## Print Helpers

    $ cat ct | grep "^def [a-z].*"
