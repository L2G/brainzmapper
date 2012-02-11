# release_group.rb
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
# CREATE TABLE release_group (
#     id                  SERIAL,
#     gid                 UUID NOT NULL,
#     name                INTEGER NOT NULL, -- references release_name.id
#     artist_credit       INTEGER NOT NULL, -- references artist_credit.id
#     type                INTEGER, -- references release_group_type.id
#     comment             VARCHAR(255),
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

#
class ReleaseGroup
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
    # @return [Integer, nil]
    # @todo There will be a +#type+ method for this (returning {ReleaseType}).
    property :type_id, Integer, :field => 'type'

    # @attribute
    # @return [ReleaseGroupType, nil]
    # TODO
    #belongs_to :type, :model => 'ReleaseGroupType'

    # @attribute
    # @return [String, nil]
    property :comment, String, :length => 0..255

    # @attribute
    # @return [Integer]
    property :edits_pending, Integer, :default => 0

    # @attribute
    #
    # This property is automatically changed whenever the record is updated.
    # It does not need to be set except to force a particular timestamp.
    #
    # @return [DateTime] Date and time of last update 

    property :updated_at, DateTime, :field => 'last_updated'

    # @attribute
    has 0..n, :releases, :model => 'Release'

    def to_s
        if self.comment.nil?
            return self.name.to_s
        else
            return "#{self.name} (#{self.comment})"
        end
    end

end

