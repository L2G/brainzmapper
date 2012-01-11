# cdtoc.rb
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
# CREATE TABLE cdtoc
# (
#     id                  SERIAL,
#     discid              CHAR(28) NOT NULL,
#     freedb_id           CHAR(8) NOT NULL,
#     track_count         INTEGER NOT NULL,
#     leadout_offset      INTEGER NOT NULL,
#     track_offset        INTEGER[] NOT NULL,
#     degraded            BOOLEAN NOT NULL DEFAULT FALSE,
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

#
class CDTOC
    include DataMapper::Resource

    # @attribute
    # @return [Integer]
    property :id, Serial

    # @attribute
    # @return [String]
    property :discid, String, :length => 28, :required => true

    # @attribute
    # @return [String]
    property :freedb_id, String, :length => 8, :required => true

    # @attribute
    # @return [String]
    property :track_count, Integer, :required => true

    # @attribute
    # @return [Integer]
    property :leadout_offset, Integer, :required => true

    # @todo Still to be implemented. Need to write a custom marshaller?
    # @return [Array<Integer>]
    def track_offset; end

    #property :track_offset, Array, :required => true

    # @attribute
    # @return [Boolean]
    property :degraded, Boolean, :required => true, :default => false

    # @attribute
    # @return [DateTime]
    property :created_at, DateTime, :field => 'created'
end

