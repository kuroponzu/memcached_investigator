# frozen_string_literal: true

RSpec.describe MemcachedInvestigator do
  let(:client) { MemcachedInvestigator::Client.new }
  let(:stdout_ok) {"OK"}
  let(:stdout_not_found) {"NOT_FOUND"}
  let(:stdout_deleted) {"DELETED"}

  it "has a version number" do
    expect(MemcachedInvestigator::VERSION).not_to be nil
  end

  context "stats command" do
    describe "execute stats" do
      it "" do
        expect{client.stats}.to output.to_stdout
      end
    end
  end

  context "STORAGE_COMMAND" do
    let(:stdout_stored) {"STORED"}
    let(:stdout_not_stored) {"NOT_STORED"}

    describe "execute set command" do
      let(:key) {"test-set-key"}
      let(:value) {"test-add-value"}
      it "" do
        expect(client.set(key: key, value: value)).to eq(stdout_stored)
        expect(client.get(key: key)).to include(value)
      end
    end

    describe "execute add command" do
      let(:key) {"test-add-key"}
      let(:value) {"test-add-value"}

      before do
        client.delete(key: key)
      end

      it "" do
        expect(client.add(key: key, value: value)).to eq(stdout_stored)
        expect(client.add(key: key, value: value)).to eq(stdout_not_stored)
        expect(client.get(key: key)).to include(value)
      end
    end

    describe "execute replace command" do
      let(:key) {"test-replace-key"}
      let(:value) {"test-replace-value"}
      let(:replaced_value) {"test-replace-value"}

      before do
        client.set(key: key, value: value)
      end

      it "" do
        expect(client.replace(key: key, value: replaced_value)).to eq(stdout_stored)
        expect(client.get(key: key)).to include(replaced_value)
      end
    end

    describe "execute append command" do
      let(:key) {"test-append-key"}
      let(:value) {"test-append-value"}
      let(:append_value) {"append"}

      before do
        client.set(key: key, value: value)
      end

      it "" do
        expect(client.append(key: key, value: append_value)).to eq(stdout_stored)
        expect(client.get(key: key)).to include("#{value}#{append_value}")
      end
    end
  end

  describe "execute flush_all" do
    let(:key) {"test-flush_all-key"}
    let(:value) {"test-flush_all-value"}
    let(:key_2) {"test-flush_all-key-2"}
    let(:value_2) {"test-flush_all-value-2"}

    before do
      client.set(key: key, value: value)
      client.set(key: key_2, value: value_2)
    end

    it "" do
      expect(client.flush_all).to eq(stdout_ok)
      expect(client.get(key: key)).not_to include(value)
      expect(client.get(key: key)).not_to include(value_2)
    end
  end

  describe "execute delete" do
    let(:key) {"test-delete-key"}
    let(:value) {"test-delete-value"}

    before do
      client.set(key: key, value: value)
    end

    it "" do
      expect(client.delete(key: key)).to eq(stdout_deleted)
      expect(client.get(key: key)).not_to include(value)
      expect(client.delete(key: key)).to eq(stdout_not_found)
    end
  end

  describe "execute metadump_all" do
    it "" do
      expect{client.metadump_all}.to output.to_stdout
    end
  end

  describe "excute import" do
    let(:csv_file) {"spec/import.csv"}

    context "success" do
      let(:key1) {"test-import-key1"}
      let(:value1) {"test-import-value1"}
      let(:key2) {"test-import-key2"}
      let(:value2) {"test-import-value2"}
      let(:key3) {"test-import-key3"}
      let(:value3) {"test-import-value3"}

      before do
        client.delete(key: key1)
        client.delete(key: key2)
        client.delete(key: key3)
        client.import(csv_file: csv_file)
      end

      it "" do
        expect(client.get(key: key1)).to include(value1)
        expect(client.get(key: key2)).to include(value2)
        expect(client.get(key: key3)).to include(value3)
      end
    end

    context "fail" do
      let(:csv_file) {"dummy_import.csv"}

      it "not found csv" do
        expect{client.import(csv_file: csv_file)}.to raise_error(described_class::FileNotFoundError,"File is not found #{csv_file}")
      end
    end
  end

  describe "excute export_metadump_all" do
    let(:key) {"test-export_metadump_all-key"}
    let(:value) {"test-export_metadump_all-value"}

    before do
      client.flush_all
      client.set(key: key, value: value)
    end

    after do
      File.delete("metadump.csv")
    end

    it "" do
      client.export_metadump_all
      table = CSV.table("metadump.csv")
      expect(table.headers).to eq %i(key exp la cas fetch cls size)
      expect(table.first[:key]).to eq key
    end
  end

  describe "excute delete_never_expires_data" do
    let(:key1) {"test-delete_never_expires_data-key1"}
    let(:value1) {"test-delete_never_expires_data-value1"}
    let(:exp) {0}
    let(:key2) {"test-delete_never_expires_data-key2"}
    let(:value2) {"test-delete_never_expires_data-value2"}


    before do
      client.set(key: key1, value: value1, expire: exp)
      client.set(key: key2, value: value2)
    end

    it "" do
      client.delete_never_expires_data
      expect(client.get(key: key1)).not_to include(value1)
      expect(client.get(key: key2)).to include(value2)
    end
  end
end
