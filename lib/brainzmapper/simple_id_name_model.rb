# simple_id_name_model.rb
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


# @abstract
#
# SimpleIdNameModel is here for models to include when all they need to
# implement are a resource ID and a string for a name. (Or maybe another
# proeprty or two.)
#
# It provides these properties:
#
# id::   resource ID used as parent ID in other tables
# name:: string 1-255 characters long
#
# It also provides minimalized +inspect+ and +to_s+ methods. Here are examples
# from {Country}.
#
# @example
#    Country[7].inspect
#    => "#<Country 8:Antarctica>"
#    Country[7].to_s
#    => "Antarctica"
#
module SimpleIdNameModel
    protected
    def self.included(heir)
        heir.class_eval do
            include DataMapper::Resource

            # @attribute [r]
            # @return [Integer]
            property :id, DataMapper::Property::Serial

            # @attribute [rw]
            # @return [String]
            property :name, String, :length => 255, :required => true

            def inspect
                "#<#{self.class} #{id}:#{name}>"
            end

            def to_s
                name
            end
        end
    end
end


