#!/usr/bin/env ruby

# fuzzy_date.rb
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


###############################################################################
# FuzzyDate represents MusicBrainz "partial dates." (In fact, this may end up
# getting renamed PartialDate just to match MusicBrainz's terminology.)
#
# FuzzyDate works more or less like Date; in fact, it delegates any undefined
# method calls to Date. The chief difference is that a FuzzyDate can represent
# a specific date, or a month within a year, or just a year. An accessor
# for the date's precision is also provided.

class FuzzyDate < DelegateClass(Date)

    # New instance of FuzzyDate. The month and day may be omitted, or just
    # the day may be omitted.
    #
    # @param [Integer] year
    # @param [Integer, optional] month
    # @param [Integer, optional] day

    def initialize(year, month, day)
        if month.nil?
            @date_precision = :y
        else
            if day.nil?
                @date_precision = :m
            else
                @date_precision = :d
            end
        end
        @date_obj = Date.new(year, month||1, day||1)
        super(@date_obj)
    end

    # Returns a symbol indicating how much of the date is defined.
    #
    # @example
    #     FuzzyDate.new(1967,9,13).precision
    #     => :d
    #     FuzzyDate.new(1967,9).precision
    #     => :m
    #     FuzzyDate.new(1967).precision
    #     => :y
    #
    # @return [Symbol] +:d+, +:m+, or +:y+
    def precision
        @date_precision
    end

    # Returns a string representation of the date like Date does, except it
    # will leave off the day or the month as appropriate.
    #
    # @example
    #     FuzzyDate.new(1967,9).to_s
    #     => "1967-09"
    #
    # @return [String]
    def to_s
        case @date_precision
        when :y
            super.gsub(/-.*$/,'')
        when :m
            super.gsub(/-\d+$/,'')
        else
            super
        end
    end

    # @return [Integer, NilClass] Month (1-12), if the month is part of the
    #   date; nil otherwise.
    def mon
        if @date_precision == :y
            nil
        else
            super
        end
    end

    # @return [Integer, NilClass] Day (of the month), if the day is part of
    #   the date; nil otherwise.
    def day
        case @date_precision
        when :y, :m
            nil
        else
            super
        end
    end
        
end
