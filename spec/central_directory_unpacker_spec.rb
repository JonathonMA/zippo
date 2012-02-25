require "spec_helper"

require "zippo/end_cd_record"

module Zippo
  describe "EndCdRecord::Unpacker" do
    subject { EndCdRecord::Unpacker.new(str).unpack }

    context "when it's a simple file" do
      let(:str) { File.binread(test_file("test.zip"))[-22..-1] }

      specify { subject.comment.should eq "" }
      specify { subject.total_records.should eq 1 }
      specify { subject.cd_offset.should eq 112 }
    end

    context "when it's a multi entry file" do
      let(:str) { File.binread(test_file("multi.zip"))[-22..-1] }

      specify { subject.total_records.should eq 2 }
    end

    context "when there is a comment" do
      let(:str) { File.binread(test_file("comment.zip"))[-61..-1] }

      specify { subject.total_records.should eq 1 }
      specify { subject.comment.should eq "this is a comment to make things tricky" }
    end

  end
end
