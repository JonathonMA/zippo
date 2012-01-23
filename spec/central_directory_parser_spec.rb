require "spec_helper"

require "zippo/central_directory_parser"

module Zippo
  describe CentralDirectoryParser do
    let(:file) { test_file "test.zip" }
    let(:io) { File.open(file) }
    let(:parser) { CentralDirectoryParser.new(io) }
    after(:each) { io.close }

    it "should parse the Central Directory entries" do
      parser.parse_entries.should have(1).entry
    end
  end
end
