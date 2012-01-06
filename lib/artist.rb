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

#
class Artist
    include DataMapper::Resource

    property   :id,  Serial
    property   :gid, UUID

    property   :name_id, Integer, :field => 'name', :required => true
    belongs_to :name, :model => 'ArtistName'

    property   :sort_name_id, Integer, :field => 'sort_name', :required => true
    belongs_to :sort_name, :model => 'ArtistName'

    property   :begin_date_year, Integer
    property   :begin_date_month, Integer
    property   :begin_date_day, Integer

    property   :end_date_year, Integer
    property   :end_date_month, Integer
    property   :end_date_day, Integer

    property   :artist_type_id, Integer, :field => 'type'
    belongs_to :artist_type

    property   :country_id, Integer, :field => 'country'
    belongs_to :country

    property   :gender_id, Integer, :field => 'gender'
    belongs_to :gender

    property   :comment,  String, :length => 255
    property   :ipi_code, String, :length => 11
    property   :updated_at, DateTime, :field => 'last_updated'

    has 0..n,  :aliases,    :model => 'ArtistAlias'
    has 0..1,  :annotation, :through => :artist_annotation
    has 0..1,  :meta,       :model => 'ArtistMeta'
    has 0..n,  :tags,       :through => :artist_tag

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
