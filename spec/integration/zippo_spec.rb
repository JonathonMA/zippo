require 'spec_helper'

require 'zippo/zip_file'

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
        File.should_receive(:open).with(file).and_return(io)
        s = Zippo::ZipFile.open(file) { |v| v['test.file'].read }
        s.should eq member_data
        io.should be_closed
      end
    end
  end
end
