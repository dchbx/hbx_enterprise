module Proxies
  class SearchAcedsUsers < ::Proxies::SoapRequestBuilder
    LOOKUP_REQUEST_NS = "http://xmlns.dhs.dc.gov/DCAS/ESB/ACDService/V1"
    
    def request(data, timeout = 5)
      code, body = super(create_body(data), timeout)
      case code.to_s
      when "200"
        [extract_response_code(body), nil]
      else
        puts body
        ["503", nil]
      end
    end

    def endpoint
      ExchangeInformation.aceds_account_search_url
    end

    def create_body(data_hash)
      data = data_hash.stringify_keys
      last_name = data["last_name"]
      first_name = data["first_name"]
      dob = data["dob"]
      gender = data["gender"].first.capitalize if data["gender"].present?
      ssn = data["ssn"]

      builder = Nokogiri::XML::Builder.new do |xml|
        xml["lrn"].ClientInquiryRequest("xmlns:lrn" => LOOKUP_REQUEST_NS) do |xml|
          xml["lrn"].send(:"ACEDS_LAST-NAME-I", last_name)
          xml["lrn"].send(:"ACEDS_FIRST-NAME-I", first_name)
          xml["lrn"].send(:"ACEDS_DATE-OF-BIRTH-I", dob)
          xml["lrn"].send(:"ACEDS_SEX-I", gender)
          xml["lrn"].send(:"ACEDS_SSN-I", ssn)
        end
      end
      
      builder.to_xml
    end

    def extract_response_code(body)
      xml = Nokogiri::XML(body)
      response_code = xml.at_xpath("//lrn:ACEDS_CONDITION-DESC", :lrn => LOOKUP_REQUEST_NS)
      return "503" if response_code.blank?
      case response_code
      when /REFER TO WORKER/
        "404"
      when /EXACT MATCH/
        "302"
      else
        "503"
      end
    end
  end
end
