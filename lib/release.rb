# release.rb
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
# CREATE TABLE release (
#     id                  SERIAL,
#     gid                 UUID NOT NULL,
#     name                INTEGER NOT NULL, -- references release_name.id
#     artist_credit       INTEGER NOT NULL, -- references artist_credit.id
#     release_group       INTEGER NOT NULL, -- references release_group.id
#     status              INTEGER, -- references release_status.id
#     packaging           INTEGER, -- references release_packaging.id
#     country             INTEGER, -- references country.id
#     language            INTEGER, -- references language.id
#     script              INTEGER, -- references script.id
#     date_year           SMALLINT,
#     date_month          SMALLINT,
#     date_day            SMALLINT,
#     barcode             VARCHAR(255),
#     comment             VARCHAR(255),
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     quality             SMALLINT NOT NULL DEFAULT -1,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

# This model describes a release (album, single, EP, etc.) made on a given
# date, on a given medium, in a given country.

class Release
    include DataMapper::Resource

    # @attribute
    # @return [Integer]
    property :id, Serial

    # @attribute
    # @return [UUID]
    property :gid, UUID, :required => true

    # @attribute
    # @deprecated Use {#name}.
    # @return [Integer]
    property :name_id, Integer, :field => 'name', :required => true

    # @attribute
    # Name of the release.
    # @return [ReleaseName] convertible to string with +to_s+
    belongs_to :name, :model => 'ReleaseName'

    # @attribute
    # @deprecated Use {#artist_credit}.
    # @return [Integer]
    property :artist_credit_id, Integer, :field => 'artist_credit',
                :required => true

    # @attribute
    # @return [ArtistCredit]
    belongs_to :artist_credit

    # @attribute
    # @return [Integer]
    property :release_group_id, Integer, :field => 'release_group',
                :required => true

    # @attribute
    # @return [ReleaseGroup]
    # @macro parent_unimplemented
    belongs_to :release_group

    # @attribute
    # @return [Integer, nil]
    property :status_id, Integer, :field => 'status'

    # @attribute
    # @return [ReleaseStatus, nil]
    # @macro parent_unimplemented
    belongs_to :status, :model => 'ReleaseStatus'

    # @attribute
    # @return [Integer, nil]
    property :packaging_id, Integer, :field => 'packaging'

    # @attribute
    # @return [ReleasePackaging, nil]
    # @macro parent_unimplemented
    belongs_to :packaging, :model => 'ReleasePackaging'

    # @attribute
    # @deprecated Use {#country}.
    # @return [Integer, nil]
    property :country_id, Integer, :field => 'country'

    # @attribute
    # @return [Country, nil]
    belongs_to :country

    # @attribute
    # @deprecated Use {#language}.
    # @return [Integer, nil]
    property :language_id, Integer, :field => 'language'

    # @attribute
    # @return [Language, nil]
    belongs_to :language

    # @attribute
    # @return [Integer, nil]
    property :script_id, Integer, :field => 'script'

    # @attribute
    # @return [Script, nil]
    # @macro parent_unimplemented
    belongs_to :script

    # @attribute
    # @return [Integer, nil]
    # @note This will be superseded by a #date method (returning {FuzzyDate}).
    property :date_year, Integer

    # @attribute
    # @return [Integer, nil]
    # @note This will be superseded by a #date method (returning {FuzzyDate}).
    property :date_month, Integer

    # @attribute
    # @return [Integer, nil]
    # @note This will be superseded by a #date method (returning {FuzzyDate}).
    property :date_day, Integer

    # @attribute
    # @return [String, nil]
    property :barcode, String, :length => 0..255

    # @attribute
    # @return [String, nil]
    property :comment, String, :length => 0..255

    # @attribute
    # @return [Integer]
    property :edits_pending, Integer, :default => 0

    # @attribute
    # @return [Integer]
    property :quality, Integer, :default => -1

    # @attribute
    # @return [DateTime]
    property :updated_at, DateTime, :field => 'last_updated'
end

