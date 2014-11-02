require "spec_helper"

require "zippo/central_directory_entries_unpacker"

module Zippo
  describe CentralDirectoryEntriesUnpacker do
    subject { CentralDirectoryEntriesUnpacker.new(io, size, offset).unpack }

    context "when it's a simple file" do
      let(:io) { File.open(test_file "test.zip") }
      let(:offset) { 112 }
      let(:size) { 79 }

      specify { subject.size.should eq 1 }
      specify { subject.first.name.should eq "test.file" }
    end

    context "when it's a complex file" do
      let(:io) { File.open(test_file "multi.zip") }
      let(:offset) { 242 }
      let(:size) { 158 }

      specify { subject.size.should eq 2 }
      specify { subject[0].name.should eq "test.file" }
      specify { subject[1].name.should eq "other.test" }
    end

  end
end
