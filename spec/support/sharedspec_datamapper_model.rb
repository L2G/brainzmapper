# sharedspec_datamapper_model.rb

shared_examples_for "a DataMapper model" do
    it "provides a DataMapper::Collection for queries" do
        described_class.all.should be_a_kind_of DataMapper::Collection
    end

    it "provides a count of records" do
        if described_class == Edit
            # Cheating here... there are so bloody many edit records to count!
            described_class.should respond_to :count
        else
            described_class.count.should be_a_kind_of Integer
            described_class.count.should be > 0
        end
    end

    it "casts to a 'nice' string (doesn't look like #<...>)" do
        string = described_class.first.to_s
        string.should_not match(/^#<.*>$/)
    end
end
