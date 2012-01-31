require "spec_helper"

require "zippo" #
require "zippo/zip_file_writer"
require "zippo/zip_directory"

module Zippo
  describe ZipFileWriter do
    describe ".write" do
      it "should write the zip file" do
        pending
        in_working_directory do
          directory = ZipDirectory.new
          directory.insert_zip_member "file.ext", "foo"
          writer = ZipFileWriter.new directory, "out.zip"
          writer.write
          Zippo.open("out.zip") { |f| f['file.ext'].read }.should eq "foo"
        end
      end
    end
  end
end
