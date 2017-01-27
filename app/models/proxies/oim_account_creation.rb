module Proxies
  class OimAccountCreation < ::Proxies::SoapRequestBuilder
    require 'faraday'
    ACCOUNT_NS = "http://xmlns.oracle.com/dcas/esb/useridentitymanage/service/xsd/v1"

    def request(data, timeout = 5)
      response = create_body(data)
      code = response.has_key?("code") ? response["code"] : "200"
      case code.to_s
      when "200" # when success
        ["201", response]
      else # when error
        [code, response]
      end
    end

    def endpoint
      ExchangeInformation.account_creation_url
    end

    INDIVIDUAL_ROLE_URI = "urn:dclink:terms:v1:create_update_user_role#Individual"
    BROKER_ROLE_URI = "urn:dclink:terms:v1:create_update_user_role#Broker"
    GENERAL_AGENT_ROLE_URI = "urn:dclink:terms:v1:create_update_user_role#GeneralAgent"
    EMPLOYER_ROLE_URI = "urn:dclink:terms:v1:create_update_user_role#Employer"
    EMPLOYEE_ROLE_URI = "urn:dclink:terms:v1:create_update_user_role#Employee"
    ASSISTER_ROLE_URI = "urn:dclink:terms:v1:create_update_user_role#Assister"
    CAC_ROLE_URI = "urn:dclink:terms:v1:create_update_user_role#CAC"

    USER_ROLE_MAPPING = {
      "broker" => BROKER_ROLE_URI,
      "general_agent" => GENERAL_AGENT_ROLE_URI,
      "individual" => INDIVIDUAL_ROLE_URI,
      "employer" => EMPLOYER_ROLE_URI,
      "employee" => EMPLOYEE_ROLE_URI,
      "assister" => ASSISTER_ROLE_URI,
      "cac" => CAC_ROLE_URI
    }

    def create_body(r_data)
      data = r_data.stringify_keys
      first_name = data["first_name"]
      last_name = data["last_name"]
      email = data["email"]
      password = data["password"]
      system_flag = data["system_flag"]
      account_role = data["account_role"]
      user_name = data["username"]
      user_name ||= data["email"]
      account_role_key = account_role.blank? ? "individual" : account_role
      # user_role = USER_ROLE_MAPPING.fetch(account_role_key, INDIVIDUAL_ROLE_URI)
      system_flag_value = system_flag.blank? ? "1" : system_flag

      request_data = {
        mail: email.present? ? email.downcase : "",
        givenName: first_name,
        sn: last_name,
        userName: user_name,
        password: password,
        userType: account_role_key.downcase,
        statusFlag: system_flag
      }

      make_forge_rock_create_request(request_data)
    end

    def make_forge_rock_create_request(data)
      config = YAML.load_file("#{Rails.root}/config/forgerock.yml")

      headers = {
        'Content-Type' => 'application/json',
        'X-OpenIDM-Username' => config["forgerock"]["username"],
        'X-OpenIDM-Password' => config["forgerock"]["password"],
      }

      response = Faraday.post do |request|
        request.url @config['forgerock']['url']
        request.headers = headers
        request.body = data.to_json
      end

      response.body
    end

    LOOKUP_RESPONSE_NS = "http://xmlns.oracle.com/dcas/esb/useridentitymanage/service/xsd/v1"

  end
end