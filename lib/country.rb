#!/usr/bin/env ruby

# country.rb
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
# CREATE TABLE country (
#     id                  SERIAL,
#     iso_code            VARCHAR(2) NOT NULL,
#     name                VARCHAR(255) NOT NULL
# );

# Information about countries of the world.
# 
# This has the properties implemented in {SimpleIdNameModel} (+id+, +name+,
# +inspect+, and +to_s+) as well as the additional property below.
#
class Country
    include SimpleIdNameModel

    # @attribute
    # A two-letter code for this country. These are "alpha-2" codes defined by 
    # ISO 3166-1, hence the name.
    #
    # @see
    #   http://www.iso.org/iso/country_codes/iso-3166-1_decoding_table.htm
    #   ISO 3166-1 decoding table
    #
    # @return
    #   [String] ISO code

    property :iso_code, String, :length => 2,   :required => true
end
