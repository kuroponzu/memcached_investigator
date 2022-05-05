# frozen_string_literal: true

RSpec.describe MemcachedInvestigator do
  it "has a version number" do
    expect(MemcachedInvestigator::VERSION).not_to be nil
  end

  it "stats test" do
    expect{MemcachedInvestigator::Client.new.stats}.to output.to_stdout
  end
end
