#!/usr/bin/env ruby

# artist_alias.rb
# 
# Copyright (c) 2011, 2012 Lawrence Leonard Gilbert
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
# CREATE TABLE artist_alias
# (
#     id                  SERIAL,
#     artist              INTEGER NOT NULL, -- references artist.id
#     name                INTEGER NOT NULL, -- references artist_name.id
#     locale              TEXT,
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

#
class ArtistAlias
    include DataMapper::Resource

    property :id, Serial
    property :artist_id, Integer, :required => true, :field => 'artist'
    property :artist_name_id, Integer, :required => true, :field => 'name'

    belongs_to :artist
    belongs_to :name, :model => 'ArtistName', :child_key => [:artist_name_id]

    property :locale, Text, :lazy => false
    property :edits_pending, Integer, :required => true, :default => 0
    property :updated_at, DateTime, :field => 'last_updated'
end
