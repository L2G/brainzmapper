#!/usr/bin/env ruby

# artist_tag.rb
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
# CREATE TABLE artist_tag
# (
#     artist              INTEGER NOT NULL, -- PK, references artist.id
#     tag                 INTEGER NOT NULL, -- PK, references tag.id
#     count               INTEGER NOT NULL,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

#
class ArtistTag
    include DataMapper::Resource

    property :artist_id, Integer, :field => 'artist', :key => true
    belongs_to :artist

    property :tag_id, Integer, :field => 'tag', :key => true
    belongs_to :tag

    property :artist_tag_count, Integer, :field => 'count',
             :required => true

    property :updated_at, DateTime, :field => 'last_updated'
end
