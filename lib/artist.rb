#!/usr/bin/env ruby

# artist.rb
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
# CREATE TABLE artist (
#     id                  SERIAL,
#     gid                 UUID NOT NULL,
#     name                INTEGER NOT NULL, -- references artist_name.id
#     sort_name           INTEGER NOT NULL, -- references artist_name.id
#     begin_date_year     SMALLINT,
#     begin_date_month    SMALLINT,
#     begin_date_day      SMALLINT,
#     end_date_year       SMALLINT,
#     end_date_month      SMALLINT,
#     end_date_day        SMALLINT,
#     type                INTEGER, -- references artist_type.id
#     country             INTEGER, -- references country.id
#     gender              INTEGER, -- references gender.id
#     comment             VARCHAR(255),
#     ipi_code            VARCHAR(11),
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

# The model holding information about an artist, whether an individual or a
# group (band, orchestra, etc.).
#
# @see http://musicbrainz.org/doc/Style/Artist
class Artist
    include DataMapper::Resource

    # @attribute [r]
    # @return [Integer]
    property :id, Serial

    # @attribute [r]
    # The global (universally unique) ID for this artist. This is the ID
    # used in MusicBrainz URLs for artist pages.
    # @return [UUID]
    property :gid, UUID

    # @deprecated
    # @attribute
    # @return [Integer]
    # @see #name
    property :name_id, Integer, :field => 'name', :required => true

    # @attribute
    # The object representing the primary name of this artist.  Following
    # MusicBrainz guidelines, this is the name used in the artist's native
    # language.
    # @return [ArtistName]
    belongs_to :name, :model => 'ArtistName'

    # @deprecated
    # @attribute
    # @return [Integer]
    # @see #sort_name
    property :sort_name_id, Integer, :field => 'sort_name', :required => true

    # @attribute
    # An ArtistName object representing the name used for sorting this artist
    # in a list. For example, groups with names starting with "The" are
    # normally sorted with the second word first ("Lonely Island, The"), and
    # people's names are normally sorted by surname first ("Samberg, Andy").
    #
    # Unlike the primary name, this is usually romanized if the native name
    # is not in Latin script.
    #
    # @return [ArtistName] Name used for sorting.
    #
    # @see http://musicbrainz.org/doc/Style/Artist/Sortname
    belongs_to :sort_name, :model => 'ArtistName'

    property :begin_date_year, Integer
    property :begin_date_month, Integer
    property :begin_date_day, Integer

    property :end_date_year, Integer
    property :end_date_month, Integer
    property :end_date_day, Integer

    property :artist_type_id, Integer, :field => 'type'
    belongs_to :artist_type

    property :country_id, Integer, :field => 'country'
    belongs_to :country

    property :gender_id, Integer, :field => 'gender'
    belongs_to :gender

    property :comment, String, :length => 255
    property :ipi_code, String, :length => 11
    property :updated_at, DateTime, :field => 'last_updated'

    has 0..n, :aliases, :model => 'ArtistAlias'
    has 0..1, :annotation, :through => :artist_annotation
    has 0..1, :meta, :model => 'ArtistMeta'
    has 0..n, :tags, :through => :artist_tag

    def begin_date
        y, m, d = begin_date_year, begin_date_month, begin_date_day
        unless y.nil?
            FuzzyDate.new(y, m, d)
        else
            nil
        end
    end

    def end_date
        y, m, d = end_date_year, end_date_month, end_date_day
        unless y.nil?
            FuzzyDate.new(y, m, d)
        else
            nil
        end
    end

    def rating
        meta.rating
    end

    def rating=(new_rating)
        meta.rating = new_rating
    end

    def rating_count
        meta.rating_count
    end

    def rating_count=(new_count)
        meta.rating_count = new_count
    end
end
