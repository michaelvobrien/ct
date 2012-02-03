## Overview

A proof-of-concept tool for writing ruby scripts to manage a Mac OS X system.

## Examples

### Run a Recipe

    $ ct recipe_file
    $ ct recipe_file --noop
    $ ct recipe_file -n

### Package

    package 'name'
    
### File

    redis_config_path = File.join(data_path, 'redis.conf')
    file '/usr/local/etc/redis.conf', File.read(redis_config_path)

### Script

    should_init_mysql_db = (not File.directory? '/usr/local/var/mysql')
    script 'initialize mysql database', should_init_mysql_db, <<-EOS
      unset TMPDIR
      mysql_install_db --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
    EOS

## Print Helpers

    $ cat ct | grep "^def [a-z].*"
