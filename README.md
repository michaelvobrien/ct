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

    file "/usr/local/etc/redis", File.read(redis_conf)

### Script

    mysql_db_path = "/usr/local/var/mysql"
    not_initialized = (not File.directory?(mysql_db_path))
    script "initialize mysql database", not_initialized, <<-EOS
      unset TMPDIR
      mysql_install_db --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
    EOS

## Print Helpers

    $ cat ct | grep "^def [a-z].*"
