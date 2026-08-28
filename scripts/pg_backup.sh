#!/bin/sh
#
# Postgresql backup script 
# http://www.bitweaver.org/wiki/pg_backup+PostgreSQL+backup+script
# Adapted 2018.01.24 by Niklaus Giger for use on thinpower (ywesee.com)
# Removed no longer supported option (>= 9.3)  -i, --ignore-version proceed even when server version mismatches
#   
# Author
#  |
#  +-- speedboy (speedboy_420 at hotmail dot com)
#  +-- spiderr (spiderr at bitweaver dot org)
#  +-- flexiondotorg (code at flexion dot org)
#
# Last modified
#  |
#  +-- 16-10-2001
#  +-- 16-12-2007
#  +-- 31-03-2010
#
# Version
#  |
#  +-- 1.1.4
#
# Description
#  |
#  +-- A bourne shell script that automates the backup, vacuum and
#      analyze of databases running on a postgresql server.
#
# Tested on
#  |
#  +-- Postgresql
#  |    |
#  |    +-- 10.1
#  |    +-- 8.4.2
#  |    +-- 8.3.9
#  |    +-- 8.1.9
#  |    +-- 7.1.3
#  |    +-- 7.1.2
#  |    +-- 7.1
#  |    +-- 7.0
#  |
#  +-- Operating systems
#  |    |
#  |    +-- funtoo
#  |    +-- CentOS 5 (RHEL 5)
#  |    +-- Linux Redhat 6.2
#  |    +-- Linux Mandrake 7.2
#  |    +-- FreeBSD 4.3
#  |    +-- Ubuntu 9.04, 9.10 and 10.04 LTS
#  |    +-- Cygwin (omit the column ":" because NT doesn't quite digest it)
#  |
#  +-- Shells:
#       |
#       +-- sh
#       +-- bash
#       +-- ksh
#
# Requirements
#  |
#  +-- grep, awk, sed, echo, bzip2, chmod, touch, mkdir, date, psql,
#      test, expr, dirname, find, tail, du, pg_dump, vacuum_db
#
# Installation
#  |
#  +-- Set the path and shell you wish to use for this script on the
#  |   first line of this file. Keep in mind this script has only been
#  |   tested on the shells above in the "Tested on" section.
#  |
#  +-- Set the configuration variables below in the configuration
#  |   section to appropriate values.
#  |
#  +-- Remove the line at the end of the configuration section so that
#  |   the script will run.
#  |
#  +-- Now save the script and perform the following command:
#  |
#  |   chmod +x ./pg_backup.sh
#  |
#  +-- Now run the configuration test:
#  |
#  |   ./pg_backup.sh configtest
#  |
#  |   This will test the configuration details.
#  |
#  +-- Once you have done that add similiar entries given as examples
#      below to the crontab (`crontab -e`) without the the _first_ #
#      characters.
#
#      # Run a backup of the remote database host 'foodb', likely on a private network
#      00 03 * * * export PGHOST=foodb; export PGBACKUPDIR=/bak/backups ; nice /server/postgres/pg_backup.sh b 2  >> /var/log/pgsql/pg_backup.log 2>&1
#      # Run a backup of the local database host 'foodb' to a custom backup directory
#      00 04 * * * export PGBACKUPDIR=/bak/backups ; nice /usr/bin/pg_backup b 2  >> /var/log/pgsql/pg_backup.log 2>&1
#
# Restoration
#  |
#  +-- Restoration can be performed by using psql or pg_restore.
#  |   Here are two examples:
#  |
#  |   a) If the backup is plain text:
#  |
#  |   Firstly bunzip2 your backup file (if it was bzip2ped).
#  |
#  |   nunzip2 backup_file.bz2
#  |   psql -U postgres database < backup_file
#  |
#  |   b) If the backup is not plain text:
#  |
#  |   Firstly bunzip2 your backup file (if it was bzip2ed).
#  |
#  |   bunzip2 backup_file
#  |   pg_restore -d database -F {c|t} backup_file
#  |
#  |   Note: {c|t} is the format the database was backed up as.
#  |
#  |   pg_restore -d database -F t backup_file_tar
#  |
#  +-- Refer to the following url for more pg_restore help:
#
#      http://www.postgresql.org/idocs/index.php?app-pgrestore.html
#
# To Do List
#              1. db_connectivity() is BROKEN, if the script can not create a
#                 connection to postmaster it should die and write to the logfile
#                 that it could not connect.
#              2. make configtest check for every required binary
#
########################################################################
#                          Start configuration                         #
########################################################################
#
##################
# Authentication #
##################
#
# Postgresql hostname to connect to.
if [ $PGHOST ]; then
        PARAM_PGHOST="-h $PGHOST"
else
        PGHOST="localhost"
fi
export PGPORT='5433'
# Postgresql username to perform backups under.
if [ -z $PGUSER ]; then
        PGUSER="postgres"
fi
 
# Postgresql password for the Postgresql username (if required).
#
# Steht bewusst nicht im Repository. Gesucht wird, in dieser Reihenfolge:
#
#   1. $PGPASSWORD aus der Umgebung.
#   2. /etc/oddb/pg_backup.conf - eine Datei mit einer einzigen Zeile
#      PGPASSWORD='...', root gehoerend und chmod 600.
#   3. gar nichts. Dann macht libpq den Rest ueber ~/.pgpass oder ueber
#      peer-Authentifizierung, und pg_dump sagt laut Bescheid, wenn es so
#      nicht geht - der Exit-Status erreicht seit August 2026 die cron-Mail.
#
# Warum ausserhalb von /var/www: dieses Skript laeuft als root. Eine Datei,
# die der Anwendungsbenutzer schreiben kann und root ausfuehrt, waere ein
# Weg von einer kompromittierten Anwendung zu root - genau der Grund, aus
# dem bin/oddb_cron nicht root gehoert.
#
# Die installierte Fassung unter /usr/local/sbin/pg_backup.sh traegt den
# Wert bis auf weiteres direkt in dieser Zeile. Wer diese Fassung dorthin
# kopiert, legt vorher /etc/oddb/pg_backup.conf an - sonst schlaegt das
# naechtliche Backup fehl.
if [ -z "$PGPASSWORD" ] && [ -r /etc/oddb/pg_backup.conf ]; then
        . /etc/oddb/pg_backup.conf
fi
postgresql_password="$PGPASSWORD"

##################
# Locations      #
##################
#
# Location to place backups.
if [ -z $PGBACKUPDIR ]; then
        PGBACKUPDIR="/var/backups/db/postgresql"
fi
# ensure that we always use english
LANG=C
subdir=`date +%B-%Y`

# Location to place the pg_backup.sh logfile.
if [ -z $PGLOGDIR ]; then
        PGLOGDIR="/var/log/pg_backup"
fi
 
# Location of the psql binaries.
if [ -z $PGBINDIR ]; then
        PGBINDIR="/usr/lib/postgresql/10/bin"
fi
 
##################
# Permissions    #
##################
#
# Permissions for the backup location.
permissions_backup_dir="0755"
 
# Permissions for the backup files.
permissions_backup_file="0644"
 
# Permissions for the backup logfile.
permissions_backup_log="0644"
 
##################
# Other options  #
##################
#
# Databases to exclude from the backup process (separated by a space)
        exclusions="template"
 
        # Backup format
        #  |
        #  +-- p = plain text : psql database < backup_file
        #  +-- t = tar        : pg_restore -F t -d database backup_file
        #  +-- c = custom     : pg_restore -F c -d database backup_file
        #
        backup_format="p"
 
        # Backup large objects
        backup_large_objects="yes"
 
        # bzip2 the backups
        backup_bzip2="yes"
 
        # Date format for the backup
        #  |
        #  +-- %d-%m-%Y       = DD-MM-YYYY
        #  +-- %Y-%m-%d       = YYYY-MM-DD
        #  +-- %A-%b-%Y       = Tuesday-Sep-2001
        #  +-- %A-%Y-%d-%m-%Y = Tuesday-2001-18-09-2001
        #  |
        #  +-- For more date formats type:
        #
        #      date --help
        #
        backup_date_format="%Y-%m-%d"
 
        # You must comment out the line below before using this script
        #echo "You must set all values in the configuration section in this file then run ./pg_backup.sh configtest before using this script" && exit 1
        ########################################################################
        #                          End configuration                           #
        ########################################################################
        #
        #################
        # Variables     #
        #################
        #
        version="1.1.4"
        current_time=`date +%H:%M`
        date_info=`date +$backup_date_format`
        PGPASSWORD="$postgresql_password"
        PATH="$PATH:/bin:/usr/bin"
 
        # Export the variables
        export PGUSER PGPASSWORD PATH
 
        #################
        # Checking      #
        #################
        #
        # Check the backup format
        
        if [ "$backup_format" = "p" ]; then
                backup_type="Plain text SQL"
                backup_args="-F $backup_format"
 
        elif [ "$backup_format" = "t" ]; then
                backup_type="Tar"
                if [ "$backup_large_objects" = "yes" ]; then
                        backup_args="-b -F $backup_format"
                else
                        backup_args="-F $backup_format"
                fi
        elif [ "$backup_format" = "c" ]; then
                backup_type="Custom"
                if [ "$backup_large_objects" = "yes" ]; then
                        backup_args="-b -F $backup_format"
                else
                        backup_args="-F $backup_format"
                fi
        else
                backup_format="c"
                backup_args="-F $backup_format"
                backup_type="Custom"
        fi
 
        #################
        # Functions     #
        #################
        #
        # Obtain a list of available databases with reference to the user
        # defined exclusions
db_connectivity() {
        tmp=`echo "($exclusions)" | sed 's/\ /\|/g'`
        if [ "$exclusions" = "" ]; then
                databases=`$PGBINDIR/psql $PARAM_PGHOST -U $PGUSER -q -c "SELECT datname FROM pg_database WHERE datistemplate = false" template1 | sed -n 4,/\eof/p | grep -v rows\) | grep -v : | awk {'print $1'} || echo "Database connection could not be established at $timeinfo" >> $PGLOGDIR`
        else
                databases=`$PGBINDIR/psql $PARAM_PGHOST -U $PGUSER -q -c "SELECT datname FROM pg_database WHERE datistemplate = false" template1 | sed -n 4,/\eof/p | grep -v rows\) | grep -v : | grep -Ev $tmp | awk {'print $1'} || echo "Database connection could not be established at $timeinfo" >> $PGLOGDIR`
        fi
}
 
# Setup the permissions according to the Permissions section
set_permissions() {
        # Make the backup directories and secure them.
        mkdir -m $permissions_backup_dir -p "$PGBACKUPDIR/$subdir"
 
        # Touch the log file
        touch "$PGLOGDIR"
 
        # Make the backup tree
        chmod -f $permissions_backup_log "$PGLOGDIR"
        chmod -f $permissions_backup_dir "$PGBACKUPDIR"
        chmod -f $permissions_backup_dir "$PGBACKUPDIR/$subdir"
#       chmod -f $permissions_backup_dir "$PGBACKUPDIR/$subdir/$date_info"
}

# get the destination file for a database
get_destination () {
  local destination="$PGBACKUPDIR/$subdir/$date_info/$current_time-postgresql_database-$1-backup"
  mkdir -m $permissions_backup_dir -p "`dirname $destination`"
  echo $destination
}

# Run backup
run_b() {
        for i in $databases; do
                start_time=`date '+%s'`
                timeinfo=`date '+%T %x'`
                destination=$(get_destination $i)
 
                "$PGBINDIR/pg_dump" $backup_args $PARAM_PGHOST $i > "$destination"
                if [ "$backup_bzip2" = "yes" ]; then
                        bzip2 "$destination"
                        chmod $permissions_backup_file "$destination.bz2"
                else
                        chmod $permissions_backup_file "$destination"
                fi
                finish_time=`date '+%s'`
                duration=`expr $finish_time - $start_time`
                echo "Backup complete (duration $duration seconds) at $timeinfo for schedule $current_time on database: $i, format: $backup_type" >> $PGLOGDIR
        done
        exit 1
}
 
# Run backup and vacuum
run_bv() {
        for i in $databases; do
                start_time=`date '+%s'`
                timeinfo=`date '+%T %x'`
                destination=$(get_destination $i)

                "$PGBINDIR/vacuumdb" $PARAM_PGHOST -U $PGUSER $i >/dev/null 2>&1
                "$PGBINDIR/pg_dump" $backup_args $PARAM_PGHOST $i > "$destination"
                if [ "$backup_bzip2" = "yes" ]; then
                        bzip2 "$destination"
                        chmod $permissions_backup_file "$destination.bz2"
                else
                        chmod $permissions_backup_file "$destination"
                fi
                finish_time=`date '+%s'`
                duration=`expr $finish_time - $start_time`
                echo "Backup and Vacuum complete (duration $duration seconds) at $timeinfo for schedule $current_time on database: $i, format: $backup_type" >> $PGLOGDIR
        done
        exit 1
}
 
# Run backup, vacuum and analyze
run_bva() {
        for i in $databases; do
                start_time=`date '+%s'`
                timeinfo=`date '+%T %x'`
                destination=$(get_destination $i)
 
                "$PGBINDIR/vacuumdb" -z $PARAM_PGHOST -U $PGUSER $i >/dev/null 2>&1
                "$PGBINDIR/pg_dump" $backup_args $PARAM_PGHOST $i > "$destination"
                if [ "$backup_bzip2" = "yes" ]; then
                        bzip2 "$destination"
                        chmod $permissions_backup_file "$destination.bz2"
                else
                        chmod $permissions_backup_file "$destination"
                fi
                finish_time=`date '+%s'`
                duration=`expr $finish_time - $start_time`
                echo "Backup, Vacuum and Analyze complete (duration $duration seconds) at $timeinfo for schedule $current_time on database: $i, format: $backup_type" >> $PGLOGDIR
        done
        exit 1
}
 
# Run vacuum
run_v() {
        for i in $databases; do
                start_time=`date '+%s'`
                timeinfo=`date '+%T %x'`
 
                "$PGBINDIR/vacuumdb" $PARAM_PGHOST -U $PGUSER $i >/dev/null 2>&1
                finish_time=`date '+%s'`
                duration=`expr $finish_time - $start_time`
                echo "Vacuum complete (duration $duration seconds) at $timeinfo for schedule $current_time on database: $i " >> $PGLOGDIR
        done
        exit 1
}
 
# Run vacuum and analyze
run_va() {
        for i in $databases; do
                start_time=`date '+%s'`
                timeinfo=`date '+%T %x'`
 
                "$PGBINDIR/vacuumdb" -z $PARAM_PGHOST -U $PGUSER $i >/dev/null 2>&1
                finish_time=`date '+%s'`
                duration=`expr $finish_time - $start_time`
                echo "Vacuum and Analyze complete (duration $duration seconds) at $timeinfo for schedule $current_time on database: $i " >> $PGLOGDIR
        done
        exit 1
}
 
# Print information regarding available backups
print_info() {
        echo "Postgresql backup script version $version"
        echo ""
        echo "Available backups:"
        echo ""
        if [ ! -d $PGBACKUPDIR ] ; then
                echo "There are currently no available backups"
                echo ""
                exit 0
        else
        for i in `find "$PGBACKUPDIR" -type d -maxdepth 2`; do
                echo "$i `du -h \"$i\" | tail -n 1 | awk {'print $1'}`"
                #for j in `ls "$PGBACKUPDIR/$i"`; do
                #       echo "    $j `du -h \"$PGBACKUPDIR/$i/$j\" | tail -n 1 | awk {'print $1'}`"
                #done
        done
        echo ""
        fi
        exit 1
}
 
# Print configuration test
print_configtest() {
        echo "Postgresql backup script version $version"
        echo ""
        echo "Configuration test..."
        echo ""
 
        # Check database connectivity information
        echo -n "Database hostname                    : "
        echo "$PGHOST"
        echo -n "Database username                    : "
        echo "$PGUSER"
        echo -n "Database connectivity                : "
        $PGBINDIR/psql $PARAM_PGHOST -U $PGUSER -q -c "select now()" template1 > /dev/null 2>&1 && echo "Yes" || echo "Connection could not be established..."
 
        # Backup information
        echo ""
        echo "Backup information:"
        echo ""
        echo -n "Backup format                        : "
        echo $backup_type
 
        echo -n "Backup large objects                 : "
        echo $backup_large_objects
        echo -n "bzip2 backups                         : "
        echo $backup_bzip2
        echo -n "Backup date format                   : $date_info"
        echo ""
 
        # File locations
        echo -n "Backup directory                     : "
        echo "$PGBACKUPDIR"
        echo -n "Backup logfile                       : "
        echo "$PGLOGDIR"
        echo -n "Postgresql binaries                  : "
        echo "$PGBINDIR"
 
        # Backup file permissions
 
        echo -n "Backup directory permissions         : "
        echo "$permissions_backup_dir"
        echo -n "Backup file permissions              : "
        echo "$permissions_backup_file"
        echo -n "Backup log permissions               : "
        echo "$permissions_backup_log"
 
        # Databases that will be backed up
        echo -n "Databases that will be backed up     : "
        echo ""
        for i in $databases; do
                echo "                                       $i"
        done
 
        # Databases that will not be backed up
        echo -n "Databases that will not be backed up :"
        echo ""
        if [ "$exclusions" = "" ]; then
                echo "                                       none"
        else
                for i in $exclusions; do
                        echo "                                       $i"
                done
                echo ""
        fi
 
        # Check if the backups location is writable
        echo "Checking permissions:"
        echo ""
        echo -n "Write access                         : $PGBACKUPDIR: "
        # Needed to create/write to the dump location"
        test -w "$PGBACKUPDIR" && echo "Yes" || echo "No"
 
        # Check if the logfile location is writable
        echo -n "Write access                         : $PGLOGDIR: "
        # Needed to create/write to this scripts logfile"
        if [ ! -x $PGLOGDIR ] ; then
                test -w `dirname "$PGLOGDIR"` && echo "Yes" || echo "No"
        else
                test -w "$PGLOGDIR" && echo "Yes" || echo "No"
        fi
 
        # Check if the binaries are executable
        echo -n "Execute access                       : $PGBINDIR/psql: "
        test -x $PGBINDIR/psql && echo "Yes" || echo "No"
 
        echo -n "Execute access                       : $PGBINDIR/pg_dump: "
        test -x $PGBINDIR/pg_dump && echo "Yes" || echo "No"
 
        echo -n "Execute access                       : $PGBINDIR/vacuumdb: "
        test -x $PGBINDIR/vacuumdb && echo "Yes" || echo "No"
 
        echo ""
        exit 1
}
 
# Print help
print_help() {
        echo "Postgresql backup script version $version"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  b,          Backup ALL databases"
        echo "  bv,         Backup and Vacuum ALL databases"
        echo "  bva,        Backup, Vacuum and Analyze ALL databases"
        echo "  v,          Vacuum ALL databases"
        echo "  va,         Vacuum and Analyze ALL databases"
        echo "  info,       Information regarding all available backups"
        echo "  configtest, Configuration test"
        echo "  help,       This message"
        echo ""
        echo "Report bugs to <speedboy_420 at hotmail dot com >."
        exit 1
}
 
case "$1" in
        # Run backup
        b)
                db_connectivity
                set_permissions
                run_b
                exit 1
                ;;
        # Run backup and vacuum
        bv)
                db_connectivity
                set_permissions
                run_bv
                exit 1
                ;;
 
        # Run backup, vacuum and analyze
        bva)
                db_connectivity
                set_permissions
                run_bva
                exit 1
                ;;
 
        # Run vacuum
        v)
                db_connectivity
                set_permissions
                run_v
                exit 1
                ;;
 
        # Run vacuum and analyze
        va)
                db_connectivity
                set_permissions
                run_va
                exit 1
                ;;
 
        # Print info
        info)
                set_permissions
                print_info
                exit 1
                ;;
 
        # Print configtest
        configtest)
                db_connectivity
                set_permissions
                print_configtest
                exit 1
                ;;
 
        # Default
        *)
                print_help
                exit 1
                ;;
esac
