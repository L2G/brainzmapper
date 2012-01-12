# model/link_attribute__spec.rb
require 'spec_helper'

describe LinkAttribute do

    it_behaves_like "a DataMapper model"

    it "refers to a Link" do
        LinkAttribute.first.link.should be_a_kind_of Link
    end

    it "refers to a LinkAttributeType" do
        LinkAttribute.first.attribute_type.should be_a_kind_of LinkAttributeType
    end
end
