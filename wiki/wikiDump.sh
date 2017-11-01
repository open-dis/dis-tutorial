#!/bin/bash
#
# dump of mysql database, entered so far, for mediawiki. There's some
# install for that. The password for the main wiki user is "bn_mediawiki"
# and the pw is randomly generated. The values are to be found at 
# apps/mediawiki/htdocs/LocalSettings.php

# ./mysqldump -u bn_mediawiki -p --all-databases
# requires a pointer to where the mysqldump is located.

/Applications/mediawiki-1.29.1-0/mysql/bin/mysqldump -u bn_mediawiki -p4508e7b1c3 --all-databases > wikiDump.sql
