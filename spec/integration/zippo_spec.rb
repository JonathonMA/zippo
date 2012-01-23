require 'spec_helper'

require 'zippo/zip_file'

module Zippo
  describe ZipFile do
    let(:file) { test_file "test.zip" }
    let(:member_data) { "The quick brown fox jumps over the lazy dog." }
    let(:zip) { Zippo::ZipFile.open(file) }
    describe "when reading a zip file" do
      after(:each) do
        zip.close
      end
      it "should be able to read a member of the file" do
        data = zip["test.file"].read
        data.should eq "The quick brown fox jumps over the lazy dog."
      end

      it "should work like File.open" do
        pending
        Zippo.open(file) do |v|
          v['test.file'].read
        end.should eq "The quick brown fox jumps over the lazy dog."
      end
    end
  end
end
