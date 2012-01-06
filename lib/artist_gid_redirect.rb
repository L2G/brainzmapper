#!/usr/bin/env ruby

# artist_gid_redirect.rb
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
# CREATE TABLE artist_gid_redirect
# (
#     gid                 UUID NOT NULL, -- PK
#     new_id              INTEGER NOT NULL, -- references artist.id
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

#
class ArtistGidRedirect
    include DataMapper::Resource

    property :gid, UUID, :key => true

    property :new_id, Integer, :required => true
    belongs_to :new_artist, :model => 'Artist', :child_key => [:new_id]

    property :created, DateTime, :default => Time.now
end
