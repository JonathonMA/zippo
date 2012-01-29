require "spec_helper"

require "zippo/zip_file"
require "zippo/uncompressors"

module Zippo
  describe ZipFile do
    # XXX unit test for open
    describe ".open" do
      let(:zip) { ZipFile.open(file, mode) }
      let(:file) { test_file "test.zip" }
      context "when in read mode" do
        let(:mode) { "r" }
        it "should allow reading of zip members" do
          zip['test.file'].should be_a ZipMember
          zip['test.file'].read.should eq "The quick brown fox jumps over the lazy dog.\n"
        end
      end
      context "when in write mode" do
        let(:mode) { "w" }
        it "should not allow reading of zip members that haven't been written" do
          zip['test.file'].should be_nil
        end
        it "should allow the insertion of a new ZipMember" do
          zip['new.file'] = "foo"
        end
      end
      context "when in update mode" do
        let(:mode) { "rw" }
        it "should read the zip file" do
          zip.directory.should_not be_empty
        end
      end
    end
  end
end
