module Proxies
  class EmployerDigestUploadRequest
    require 'net/http' 

    def invoke(payload, timeout = 15)
      request(payload)
    end

    def api_key
      ExchangeInformation.b2b_integration_api_key
    end

    def endpoint
      ExchangeInformation.employer_xml_post_url
    end

    def request(payload, timeout = 15)
      uri = URI.parse(endpoint)
      req = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' =>'application/xml', 'X-API-Key' => api_key})
      req.body = payload
      requestor = Net::HTTP.new(uri.host, uri.port)
      use_ssl = (uri.scheme == "https")
      requestor.use_ssl = use_ssl
      if use_ssl
        requestor.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      requestor.open_timeout = 3
      requestor.read_timeout = timeout
      response = nil
      begin
        response = requestor.request(req)
      rescue Net::ReadTimeout => rt
        return [503, nil]
      rescue Net::OpenTimeout => ot
        return [503, nil]
      rescue Net::HTTPError => he
        return [500, he] 
      rescue StandardError => se
        return [500, se]
      end
      if is_ok_response?(response)
        return [200, response.body]
      end
      [response.code.to_i, response.body]
    end

    def is_ok_response?(response)
      r_code = response.code.to_i
      (r_code > 199) && (r_code < 300)
    end

  end
end
