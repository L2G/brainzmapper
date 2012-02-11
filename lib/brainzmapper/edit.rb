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

    # A multi-line, human-readable string with all of the attributes of
    # the edit.
    # @todo The type should show a name, not a number, of course. And the
    # timestamps in the edit data could be more human-readable.
    # @return [String] Human-readable description of the edit
    def to_s
        unless Hash.respond_to?(:to_yaml)
            require 'yaml'
        end

        now = DateTime.now
        string = "Edit \##{self.id}\n" +
                 "Type: #{self.type}\n" +
                 "Opened: #{self.open_time}\n"

        if self.expire_time > now
            string += "Expires: #{self.expire_time}\n"
        else
            string += "Expired: #{self.expire_time}\n"
        end

        unless self.close_time.nil?
            if self.close_time > now
                string += "Closes: #{self.close_time}\n"
            else
                string += "Closed: #{self.close_time}\n"
            end
        end

        string += "Status: #{self.status}\n"
        if self.autoedit == 1
            string += "Votes: (auto-edit, no votes)\n"
        else
            string += "Votes: #{self.yes_votes} yes, #{self.no_votes} no\n"
        end

        unless self.language.nil?
            string += "Language: #{self.language}\n"
        end
        string += self.data.to_yaml.gsub(/^/,'      ').
                                    gsub(/^.*---/,'Data: ---')
        return string
    end
end
