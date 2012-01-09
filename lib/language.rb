#!/usr/bin/env ruby

# language.rb
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
# CREATE TABLE language
# (
#     id                  SERIAL,
#     iso_code_3t         CHAR(3) NOT NULL, -- ISO 639-2 (T)
#     iso_code_3b         CHAR(3) NOT NULL, -- ISO 639-2 (B)
#     iso_code_2          CHAR(2), -- ISO 639
#     name                VARCHAR(100) NOT NULL,
#     frequency           INTEGER NOT NULL DEFAULT 0
# );

#
class Language
    include DataMapper::Resource

    property :id,          Serial
    property :iso_code_3t, String,  :length => 3, :required => true
    property :iso_code_3b, String,  :length => 3, :required => true
    property :iso_code_2,  String,  :length => 2
    property :name,        String,  :length => 100, :required => true
    property :frequency,   Integer, :required => true, :default => 0
end
