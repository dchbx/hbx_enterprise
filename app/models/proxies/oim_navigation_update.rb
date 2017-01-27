module Proxies
  class OimNavigationUpdate < ::Proxies::SoapRequestBuilder
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


    def create_body(r_data)
      data = r_data.stringify_keys
      user_name = data["legacy_username"]
      email = data["email"]
      system_flag = data["flag"]

      request_data = []
      input_hash = {"userName"=> user_name , "statusFlag"=> system_flag, "mail" => data["email"]  }

      input_hash.each do |key, value|
        request_data <<  {operation: "replace", field: key, value: value}
      end

      make_forge_rock_update_request(request_data, user_name)
    end

    def make_forge_rock_update_request(data, user_name)
      query_params = {
        "_action" => "patch",
        "_queryId" => "for-userName",
        "uid" => user_name,
      }

      headers = {
        'Content-Type' => 'application/json',
        'X-OpenIDM-Username' => config["forgerock"]["username"],
        'X-OpenIDM-Password' => config["forgerock"]["password"]
      }

      response = Faraday.post do |request|
        request.url config['forgerock']['url']
        request.headers = headers
        request.params = query_params
        request.body = data.to_json
      end

      response.body
    end

    LOOKUP_RESPONSE_NS = "http://xmlns.oracle.com/dcas/esb/useridentitymanage/service/xsd/v1"

  end
end