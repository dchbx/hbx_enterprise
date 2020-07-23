require 'spec_helper'

describe Parsers::Xml::Cv::EmployerRequestParser do
  context "employer_request xml" do

    let(:xml) { File.read(Padrino.root + "/spec/data/parsers/census_employee/employer_request.xml") }
    let(:subject) { Parsers::Xml::Cv::EmployerRequestParser.new }

    it 'should return the elements as a hash' do
      subject.parse(xml)
      expect(subject.to_hash).to include(:header, :request)
      expect(subject.to_hash[:request][:parameters][:ssn]).to eq('111111111')
      expect(subject.to_hash[:request][:parameters][:dob]).to eq('19900101')
    end
  end
end
