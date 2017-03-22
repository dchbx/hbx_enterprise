require 'securerandom'

module Proxies
  class PaymentProcessorEnrollmentDropRequest
    XML_NSES = {
      :proc => "http://dchealthlink.com/vocabularies/1/process"
    }

    def request(data)
      begin
        f_path = resolve_path(data)
        upload_file(data, f_path)
        ["200", nil]
      rescue Exception => e
        $stderr.puts e.message
        $stderr.puts e.inspect
        $stderr.puts e.backtrace.join("\n")
        ["503", {
          :error_message => e.message,
          :error => e.inspect,
          :stacktrace => e.backtrace.join("\n")
        }.to_json]
      end
    end

    def base_path
      ExchangeInformation.pp_sftp_enrollment_path
    end

    def host
      ExchangeInformation.pp_sftp_host
    end

    def username
      ExchangeInformation.pp_sftp_username
    end

    def password
      ExchangeInformation.pp_sftp_password
    end

    def resolve_path(payload)
      the_xml = Nokogiri::XML(payload)
      change_type = the_xml.xpath("//proc:operation/proc:type", XML_NSES).first.text
      file_path = ""
      generated_id = SecureRandom.uuid.gsub("-", "")
      case change_type
      when "add"
        file_path = "adds"
      when "cancel"
        file_path = "cancels"
      when "terminate"
        file_path = "terms"
      else
        file_path = "changes"
      end
      "#{base_path}/#{file_path}/#{generated_id}_#{change_type}.xml"
    end

    def upload_file(f_data, f_path)
      Net::SSH.start(host, username, :password => password) do |ssh|
        sftp = ssh.sftp.connect!
        sftp.upload!(StringIO.new(f_data), f_path)
        begin
          sftp.close_channel
        rescue IOError
        end
      end
    end
  end
end
