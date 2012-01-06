#!/usr/bin/env ruby

# edit.rb
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
# CREATE TABLE edit
# (
#     id                  SERIAL,
#     editor              INTEGER NOT NULL, -- references editor.id
#     type                SMALLINT NOT NULL,
#     status              SMALLINT NOT NULL,
#     data                TEXT NOT NULL,
#     yes_votes            INTEGER NOT NULL DEFAULT 0,
#     no_votes             INTEGER NOT NULL DEFAULT 0,
#     autoedit            SMALLINT NOT NULL DEFAULT 0,
#     open_time            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
#     close_time           TIMESTAMP WITH TIME ZONE,
#     expire_time          TIMESTAMP WITH TIME ZONE NOT NULL,
#     language            INTEGER, -- references language
#     quality             SMALLINT NOT NULL DEFAULT 1
# );

#
class Edit
    include DataMapper::Resource

    property   :id, Serial

    property   :editor_id, Integer, :field => 'editor', :required => true
    belongs_to :editor

    # See lib/MusicBrainz/Server/Constants.pm ($EDIT_*) for edit types
    property   :type,        Integer, :required => true
    property   :status,      Enum,    :required => true,
                 :flags => [:open, :applied, :failed_vote, :failed_dep,
                            :error, :failed_prereq, :no_votes,
                            :to_be_deleted, :deleted]
    property   :data,        Json,    :required => true
    property   :yes_votes,   Integer, :required => true, :default => 0
    property   :no_votes,    Integer, :required => true, :default => 0
    property   :autoedit,    Integer, :required => true, :default => 0
    property   :open_time,   DateTime, :default => Time.now
    property   :close_time,  DateTime
    property   :expire_time, DateTime, :required => true

    property   :language_id, Integer, :field => 'language'
    belongs_to :language

    property   :quality, Integer, :required => true, :default => 1
end
