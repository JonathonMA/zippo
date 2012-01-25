require "spec_helper"

require "zippo/central_directory_entries_unpacker"

module Zippo
  describe CentralDirectoryEntriesUnpacker do
    subject { CentralDirectoryEntriesUnpacker.new(str).unpack }

    context "when it's a simple file" do
      let(:str) { File.binread(test_file("test.zip"))[-101..-23] }

      specify { subject.should have(1).items }
      specify { subject.first.name.should eq "test.file" }
    end

    context "when it's a complex file" do
      let(:str) { File.binread(test_file("multi.zip"))[-181..-23] }

      specify { subject.should have(2).items }
      specify { subject[0].name.should eq "test.file" }
      specify { subject[1].name.should eq "other.test" }
    end

  end
end
