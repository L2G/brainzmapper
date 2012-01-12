# model/link__spec.rb
require 'spec_helper'

describe Link do

    it_behaves_like "a DataMapper model"

    it "can have an optional number of LinkAttributes" do
        # There is a slight chance of this test failing incorrectly because
        # attribute_count is actually a column in the database table
        0.upto(3) do |n|
            link_attrs = Link.first(:attribute_count => n).link_attributes
            link_attrs.size.should be n
        end
    end

end
