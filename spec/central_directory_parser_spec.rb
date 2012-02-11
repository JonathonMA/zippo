require "spec_helper"

require "zippo/central_directory_parser"

module Zippo
  describe CentralDirectoryParser do
    let(:io) { File.open(file, "rb:ASCII-8BIT") }
      let(:file) { test_file "test.zip" }
    let(:parser) { CentralDirectoryParser.new(io) }
    after(:each) { io.close }

    context "when parsing a simple file" do
      let(:file) { test_file "test.zip" }
      it "should parse the End of Central Directory Record" do
        parser.end_of_cd_record.total_records.should eq 1
      end

      specify { parser.end_of_cd_record_position.should eq 0xbf }
      specify { parser.should have(1).cd_file_headers }
    end

    context "when parsing a file with a comment" do
      let(:file) { test_file "comment.zip" }
      specify { parser.end_of_cd_record_position.should eq 0xbf }
      specify { parser.end_of_cd_record.comment.should eq "this is a comment to make things tricky" }
    end

    context "when parsing a multi-entry file" do
      let(:file) { test_file "multi.zip" }
      specify { parser.end_of_cd_record_position.should eq 0x191 }
    end

    context "when parsing a file that is not a zip" do
      let(:file) { test_file "not_a.zip" }
      specify { lambda {parser.end_of_cd_record_position}.should raise_error }
    end

    context "when parsing a zip file larger than the maximum comment size" do
      it "should not barf" do
        in_working_directory do
          Zippo::ZipFile.open("large.zip", "w") do |v|
            v["test.file"] = "a" * 65535
          end
          Zippo::ZipFile.open("large.zip") {|v| v["test.file"].read }.should eq "a" * 65535
        end
      end
    end
  end
end
