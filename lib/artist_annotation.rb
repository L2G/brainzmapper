#!/usr/bin/env ruby

# artist_annotation.rb
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
# CREATE TABLE artist_annotation
# (
#     artist              INTEGER NOT NULL, -- PK, references artist.id
#     annotation          INTEGER NOT NULL -- PK, references annotation.id
# );

#
class ArtistAnnotation
    include DataMapper::Resource

    property :artist_id, Integer, :field => 'artist', :key => true
    property :annotation_id, Integer, :field => 'annotation', :key => true

    belongs_to :artist
    belongs_to :annotation 
end

##############################################################################
# Alias for ArtistAnnotation, needed as a shim for DataMapper (until a better
# way is found).
class AnnotationArtist < ArtistAnnotation; end
