require "spec_helper"

require "zippo/central_directory_parser"

module Zippo
  describe CentralDirectoryParser do
    let(:io) { File.open(file) }
    let(:parser) { CentralDirectoryParser.new(io) }
    after(:each) { io.close }

    context "when parsing a simple file" do
      let(:file) { test_file "test.zip" }
      it "should parse the Central Directory entries" do
        pending "need eocdr locator"
        parser.parse_entries.should have(1).entry
      end

      specify { parser.end_of_cd_record_position.should eq 0xbf }
    end

    context "when parsing a file with a comment" do
      let(:file) { test_file "comment.zip" }
      specify { parser.end_of_cd_record_position.should eq 0xbf }
    end

    context "when parsing a file that is not a zip" do
      let(:file) { test_file "not_a.zip" }
      specify { lambda {parser.end_of_cd_record_position}.should raise_error }
    end
  end
end
