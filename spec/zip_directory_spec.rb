require 'spec_helper'

require 'zippo/zip_file'

module Zippo
  describe ZipDirectory do
    context "when opening a file" do
      let(:io) { File.open(file, "rb:ASCII-8BIT") }
      after(:each) { io.close }
      subject { ZipDirectory.new io }
      context "when reading a simple file" do
        let(:file) { test_file "test.zip" }
        it { should have(1).entries }
        specify { subject["test.file"].should_not be_nil }
        it { should_not be_empty }
      end
      context "when reading a larger zip" do
        let(:file) { test_file "multi.zip" }
        it { should have(2).entries }
        specify { subject["test.file"].should_not be_nil }
        specify { subject["other.test"].should_not be_nil }
      end
    end
    context "when inserting" do
      let(:io) { StringIO.new "" }
      it "should allow the insertion of new members" do
        subject["new.file"] = "file data"
        subject["new.file"].read.should eq "file data"
        subject["new.file"].write_to io, 0
        io.string.should eq "file data"
      end
      it "should allow the insertion of IO objects" do
        in_working_directory do
          File.write "xyzzy.txt", "plugh"
          file = File.open "xyzzy.txt"
          subject.insert "woo.txt", file
          subject["woo.txt"].read.should eq "plugh"
          subject["woo.txt"].write_to io, 0
          file.close
          io.string.should eq "plugh"
        end
      end
      it "should allow insertion of file contents" do
        in_working_directory do
          File.write "xyzzy.txt", "plugh"
          subject.insert "woo.txt", "xyzzy.txt"
          subject["woo.txt"].read.should eq "plugh"
          subject["woo.txt"].write_to io, 0
          io.string.should eq "plugh"
        end
      end
      it "should allow the insertion of ZipMember contents" do
        zip = Zippo::ZipFile.open test_file "test.zip"
        subject.insert "hmm.txt", zip['test.file']
        subject["hmm.txt"].read.should eq "The quick brown fox jumps over the lazy dog.\n"
        subject["hmm.txt"].write_to io, 0
        zip.close
        io.string.should eq "The quick brown fox jumps over the lazy dog.\n"
        -> { subject["hmm.txt"].read }.should raise_error # after closing original zip
      end
    end
  end
end
