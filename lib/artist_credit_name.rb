#!/usr/bin/env ruby

# artist_credit_name.rb
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
# CREATE TABLE artist_credit_name (
#     artist_credit       INTEGER NOT NULL, -- PK, references artist_credit.id CASCADE
#     position            SMALLINT NOT NULL, -- PK
#     artist              INTEGER NOT NULL, -- references artist.id CASCADE
#     name                INTEGER NOT NULL, -- references artist_name.id
#     join_phrase         TEXT
# );

#
class ArtistCreditName
    include DataMapper::Resource

    property :artist_credit_id, Integer, :field => 'artist_credit',
                 :key => true
    belongs_to :artist_credit

    property :position, Integer, :key => true

    property :artist_id, Integer, :field => 'artist', :required => true
    belongs_to :artist

    property :artist_name_id, Integer, :field => 'name'
    belongs_to :artist_name

    property :join_phrase, Text, :lazy => false
end
