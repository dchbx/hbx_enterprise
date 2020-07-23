require 'csv'

class RepubCv

  def self.run
    conn = Bunny.new(ExchangeInformation.amqp_uri, :heartbeat => 5)
    conn.start
    ch = conn.create_channel
    ch.confirm_select
    dir_glob = Dir.glob(File.join(File.dirname(__FILE__), "policy_cvs", "*.xml"))
    f_name_list = dir_glob.map { |dg| dg }
    pb = ProgressBar.create(
      :title => "Publishing ",
      :total => f_name_list.length,
      :format => "%t %a %e |%B| %P%%",
      :output => $stderr
    )
    CSV.open("policy_run_results.csv", "w") do |csv|
      csv << ["policy_id", "errors"]
      f_name_list.each do |f|
        data = File.read(f)
        cv = data.gsub("active_year", "plan_year")
        qr_uri = "urn:dc0:terms:v1:qualifying_life_event#initial_enrollment"
        request_props = {
          :routing_key => "enrollment.create",
          :headers => {
            :qualifying_reason_uri => qr_uri
          }
        }

        begin
          di, prop, payload = Amqp::Requestor.new(conn).request(request_props, cv, 180)
          return_code = prop.headers["return_status"]
          if "200" != return_code
            puts f.to_s
            puts payload.to_s
            STDOUT.flush
            puts "==========="
            error_body = JSON.load(payload)
            err_string = ""
            err_string << flatten_to_list("", error_body).join("\n")
            csv << [File.basename(f).gsub(/\.xml\Z/, ""), err_string]
          else
            pb.log(f.to_s)
          end
        rescue => e
          puts f
          raise e
        end
        pb.increment
      end
      pb.finish
    end
  end

  def self.flatten_to_list(context, error_hash)
    if error_hash.kind_of?(Hash)
      result_array = []
      error_hash.each_pair do |k, v|
        result_array = result_array + flatten_to_list(context + "#{k.to_s} ", v)
      end
      result_array
    elsif error_hash.kind_of?(Array)
      result_array = []
      error_hash.each do |v|
        result_array = result_array + flatten_to_list(context, v)
      end
      result_array
    else
      [context + error_hash.to_s]
    end
  end
end

RepubCv.run
