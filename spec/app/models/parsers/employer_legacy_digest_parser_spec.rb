require "spec_helper"

describe LegacyEmployerXmlAdapter do

  let(:xml) {File.read("spec/data/parsers/employer_legacy_digest_transformer_test_data.xml")}
  let(:subject) {LegacyEmployerXmlAdapter.new(xml)}

  it 'should ignore the mid year employer event and parse the carrier name' do
      subject.create_output do |result|
        c_name, xml_io = result
        expect(c_name).to eq("CareFirst")
      end
  end
end