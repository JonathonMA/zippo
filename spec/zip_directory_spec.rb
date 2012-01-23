require 'spec_helper'

require 'zippo/zip_file'

module Zippo
  describe ZipDirectory do
    subject { File.open(file) { |io| ZipDirectory.new io } }
    context "when reading a simple file" do
      let(:file) { test_file "test.zip" }
      pending { should have(1).entries }
    end
    context "when reading a larger zip" do
      let(:file) { test_file "multi.zip" }
      pending { should have(2).entries }
    end
  end
end
