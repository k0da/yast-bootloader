#! /usr/bin/env rspec --format doc

require_relative "./test_helper"

require "bootloader/stage1"

Yast.import "BootStorage"
Yast.import "Storage"

describe Bootloader::Stage1 do
  before do
    # simple mock getting disks from partition as it need initialized libstorage
    allow(Yast::BootStorage).to receive(:can_boot_from_partition).and_return(true)
    allow(subject).to receive(:gpt_boot_disk?).and_return(true)
    allow(Yast::Storage).to receive(:GetDiskPartition) do |partition|
      if partition == "/dev/system/root"
        disk = "/dev/system"
        number = "system"
      else
        number = partition[/(\d+)$/, 1]
        disk = partition[0..-(number.size + 1)]
      end
      { "disk" => disk, "nr" => number }
    end
  end

  describe "#propose" do
    it "returns symbol with selected location" do
      target_map_stub("storage_mdraid.rb")
      allow(Yast::BootStorage).to receive(:possible_locations_for_stage1)
        .and_return(["/dev/sda", "/dev/sda1"])
      allow(Yast::BootStorage).to receive(:BootPartitionDevice)
        .and_return("/dev/md1")
      expect(subject.propose).to be_a(Symbol)
    end
  end
end
