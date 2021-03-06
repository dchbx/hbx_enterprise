module Parsers
  module Xml
    module Cv
      class OrganizationParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'organization'
        namespace 'cv'

        element :id, String, tag: "id/cv:id"
        element :name, String, tag: "name"
        element :dba, String, tag: "dba"
        element :fein, String, tag: 'fein'
        has_many :office_locations, Parsers::Xml::Cv::OfficeLocationParser, tag: 'office_location', :namespace => 'cv'
        has_one :employer_profile, Parsers::Xml::Cv::EmployerProfileParser,  tag: 'employer_profile'
        has_many :contacts, Parsers::Xml::Cv::PersonParser, tag: "contact"

        def to_hash
          response = {
              id: id,
              name: name,
              dba:dba,
              fein:fein,
              office_locations: office_locations.map(&:to_hash),
              employer_profile: employer_profile.to_hash
          }
          response[:contacts] = contacts.map(&:to_hash) if contacts
          response
        end
      end
    end
  end
end