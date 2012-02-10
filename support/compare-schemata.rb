#!/usr/bin/env ruby

require 'diff/lcs/array'
require 'prettyprint'

$:.unshift 'lib'
require 'brainzmapper'

#-----------
# Constants
#-----------

# Column width for printed diff (2 columns + 3 chars)
COL_WIDTH = 80

# Name of Postgres database user (both databases)
DB_USER = 'musicbrainz_rw'

# Name/path to pg_dump binary
PG_DUMP_BIN = 'pg_dump'

# Name of database with the official MusicBrainz data to compare with
SUBJECT_DB_NAME = 'musicbrainz_db'

# Name of database to use for setting up a trial version
TRIAL_DB_NAME = 'chsiuswwyhnjfkds'

#---------------
# Local methods
#---------------

# Call out to pg_dump to dump a database's schema
def dump_schema(db_name)
    lines = nil
    IO.popen("#{PG_DUMP_BIN} #{db_name} -U #{DB_USER} -s") do |io|
        lines = io.readlines
    end
    return lines
end

# Print a side-by-side diff
def print_sdiff(left_array, right_array)
    width = COL_WIDTH
    sdiff = left_array.sdiff(right_array)
    sdiff.each do |change|
        old = change.old_element || ''
        new = change.new_element || ''
        action = change.action.tr('-+=', '<> ')
        printf("%-#{width}s %s %-#{width}s\n", old.chomp[0...width], action,
               new.chomp[0...width])
    end
end

# Use DataMapper.auto_migrate! to set up the trial DB
def set_up_trial_db
    BrainzMapper.setup(:default,
        "postgres://#{DB_USER}@localhost/#{TRIAL_DB_NAME}" +
        "?search_path=musicbrainz"
    )
    DataMapper.auto_migrate!
end

###############################################################################
# MAIN
###############################################################################

set_up_trial_db
print_sdiff(dump_schema(SUBJECT_DB_NAME), dump_schema(TRIAL_DB_NAME))
