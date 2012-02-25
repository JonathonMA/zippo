# Encoding: BINARY
require 'spec_helper'

require 'zippo'

module Zippo
  describe ZipFile do
    let(:file) { test_file "test.zip" }
    let(:member_data) { "The quick brown fox jumps over the lazy dog.\n" }
    let(:zip) { Zippo::ZipFile.open(file) }
    describe "when reading a zip file" do
      after(:each) do
        zip.close
      end
      it "should be able to read a member of the file" do
        data = zip["test.file"].read
        data.should eq member_data
      end

      it "should read a compressed file" do
        zip = Zippo::ZipFile.open(test_file("deflate.zip"))
        zip["weasels.txt"].read.should eq "Methinks it is like a weasel.\n" * 10
      end

      it "should work like File.open" do
        io = File.open(file)
        File.should_receive(:open).with(file, 'r:ASCII-8BIT').and_return(io)
        s = Zippo.open(file) { |v| v['test.file'].read }
        s.should eq member_data
        io.should be_closed
      end

      it "should create zip files" do
        in_working_directory do
          File.write "xyzzy.txt", "plugh"
          Zippo.open("new.zip", "w") {|v| v['xyzzy.txt'] = "plugh" }
          Pathname.new("new.zip").should exist
          Zippo.open("new.zip") {|v| v['xyzzy.txt'].read }.should eq "plugh"
        end
      end

      it "should update in place with mode rw" do
        in_working_directory do
          Zippo.open("out.zip", "w")  { |v| v['foo1'] = "data1" }
          Zippo.open("out.zip", "rw") { |v| v['foo2'] = "data2" }
          IO.write "/tmp/bar.zip", IO.read("out.zip")
          Zippo.open("out.zip") do |v|
            v['foo1'].read.should eq "data1"
            v['foo2'].read.should eq "data2"
          end
        end
      end
    end
  end
end
