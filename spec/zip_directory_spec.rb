require 'spec_helper'

require 'zippo/zip_file'

module Zippo
  describe ZipDirectory do
    let(:io) { File.open(file) }
    after(:each) { io.close }
    subject { ZipDirectory.new io }
    context "when reading a simple file" do
      let(:file) { test_file "test.zip" }
      it { should have(1).entries }
      specify { subject["test.file"].should_not be_nil }
    end
    context "when reading a larger zip" do
      let(:file) { test_file "multi.zip" }
      it { should have(2).entries }
      specify { subject["test.file"].should_not be_nil }
      specify { subject["other.test"].should_not be_nil }
    end
  end
end
