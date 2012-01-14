# release_meta.rb
# 
# Copyright (c) 2012 Lawrence Leonard Gilbert
#
# The SQL code (incorporated for documentation purposes) comes from the
# MusicBrainz Server project, copyright of the MetaBrainz Foundation and
# others.  See the AUTHORS file for details.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 675 Mass
# Ave, Cambridge, MA 02139, USA.

##############################################################################
# CREATE TYPE cover_art_presence AS ENUM ('absent', 'present', 'darkened');
# 
# CREATE TABLE release_meta
# (
#     id                  INTEGER NOT NULL, -- PK, references release.id CASCADE
#     date_added          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
#     info_url            VARCHAR(255),
#     amazon_asin         VARCHAR(10),
#     amazon_store        VARCHAR(20),
#     cover_art_presence  cover_art_presence NOT NULL DEFAULT 'absent'
# );

#
class ReleaseMeta
    include DataMapper::Resource

    # @attribute
    # @return [Integer]
    property :id, Serial, :key => true

    # @attribute
    # @return [DateTime]
    property :created_at, DateTime, :field => 'date_added'

    # @attribute
    # @return [URI]
    property :info_url, URI, :length => 0..255

    # @attribute
    # @return [String]
    property :amazon_asin, String, :length => 0..10

    # @attribute
    # @return [String]
    property :amazon_store, String, :length => 0..20

    # Don't know what to do about cover_art_presence yet...
    # Doesn't look like DataMapper can handle an SQL enum?

end
