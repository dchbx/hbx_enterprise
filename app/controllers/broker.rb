require 'nokogiri'

class HbxEnterprise::App

  post '/brokers/legacy_xml' do

    # file_path = " " # dir_path where broker xml that need to be generated for NFP.
    # carrier_br_file_path = " " # dir_path where broker xml that need to be generated for carrier's.

    @cv_hash = Parsers::Xml::Cv::IndividualParser.parse(request.body.read).to_hash
    file_path = "/Users/CitadelFirm/Downloads/broker-xmls-aug24/10527-cvs/broker.xml"

    broker_xml = render "brokers/legacy_broker", :locals =>{ :individual=> @cv_hash }
    File.open(file_path, 'a') { |file| file.write(broker_xml); }

    doc = Nokogiri::XML(broker_xml)

    doc.xpath("//cv:broker_payment_accounts", {:cv => 'urn:dchbx:brokerv1'}).each do |node|
      # removing broker_payment_accounts, broker ACH info should not be include in carrier's broker xml.
      node.remove
    end

    File.open(carrier_br_file_path, 'a') { |file| file.write(doc.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::NO_DECLARATION, :indent => 2)); }
    return
  end
end