#!/bin/bash -ex

# Script to install and setup postgreSQL

echo "Creating variables to be used during installation process"

# $packages array of required dependencies
packages=('gcc' 'tar' 'gzip' 'libreadline5' 'make' 'zlib1g' 'zlib1g-dev' 'flex' 'bison' 'perl' 'tcl' 'gettext' 'odbc-postgresql' 'libreadline6-dev')

# $root_dir is the install directory for PostgreSQL
root_dir='/postgres'

# $doc_dir is the root directory for various types of read-only data files
doc_dir='/postgres/data'

# $git_repo is the location of the PosgreSQL git repository
git_repo='git://git.postgresql.org/git/postgresql.git'

# $psql_user is the system user for running PostgreSQL
sys_user='postgres'

# $helloscript is the sql script for creating the PSQL user and creating a database.
createscript='~/postgreSQL/create.sql'

# $log_file is the log file for this installation.
logfile='psqlinstall-log'

# Package Installation

# Ensures the server is up to date before proceeding.
echo "Updating server..."
sudo apt-get update -y >> $logfile

# for-loop to install packages
echo "Installing PostgreSQL dependencies"
sudo apt install ${packages[@]} -y >> $logfile


# Create required directories

echo "Creating folders $doc_dir..."
sudo mkdir -p $doc_dir >> $logfile


# Create system user

echo "Creating system user '$psql_user'"
sudo adduser --system $psql_user >> $logfile


# Clone PSQL repo from github

echo "Cloning repo..."
git clone $git_repo >> $logfile


# Install and configure PSQL
echo "Configuring PostgreSQL..."
~/postgresql/configure --prefix=$root_dir --datarootdir=$doc_dir >> $logfile

echo "Making PostgreSQL..."
make >> $logfile

echo "installing PostgreSQL..."
sudo make install >> $logfile

echo "Giving system user '$psql_user' control over the $doc_dir folder"
sudo chown postgres $doc_dir >> $logfile

# Create database cluster using initdb
echo "Running initdb..."
sudo -u postgres $root_dir/bin/initdb -D $doc_dir/db >> $logfile


# Start PSQL
echo "Starting PostgreSQL"
sudo -u postgres $root_dir/bin/pg_ctl -D $doc_dir/db -l $doc_dir/logfilePSQL start >> $logfile


# Setup postgreSQL to start at launch and add enviroment variable to /etc/profile
echo "Set PostgreSQL to launch on startup"
sudo sed -i '$isudo -u postgres /postgres/bin/pg_ctl -D /postgres/data/db -l /postgres/data/logfilePSQL start' /etc/rc.local >> $logfile

echo "Writing PostgreSQL environment variables to /etc/profile"
cat << EOL | sudo tee -a /etc/profile
# PostgreSQL Environment Variables
LD_LIBRARY_PATH=/postgres/lib
export LD_LIBRARY_PATH
PATH=/postgres/bin:$PATH
export PATH
EOL


# create.sql script is ran

echo "Wait for PostgreSQL to finish starting up..."
sleep 5

echo "Running script..."
$root_dir/bin/psql -U postgres -f $createscript


# Query database

echo "Querying the newly created table in the newly created database..."
/postgres/bin/psql -c 'select * from welcome;' -U skay postgres_db;
