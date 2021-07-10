require 'json'

module Listeners
  class AcedsAccountLookupListener < Amqp::Client
    def on_message(delivery_info, properties, payload)
      reply_to = properties.reply_to
      headers = (properties.headers || {})
      code, body = Proxies::SearchAcedsUsers.new.request(headers.stringify_keys)
      send_response(reply_to, code.to_s)
      channel.acknowledge(delivery_info.delivery_tag, false)
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.aceds_account_lookup"
    end

    def send_response(reply_to, status)
      response_properties = {
        :routing_key => reply_to,
        :headers => {
          :return_status => status
        }
      }
      channel.default_exchange.publish("", response_properties)
    end

    def self.run
      conn = Bunny.new(ExchangeInformation.amqp_uri, :heartbeat => 15)
      conn.start
      ch = conn.create_channel
      ch.prefetch(1)
      q = ch.queue(queue_name, :durable => true)

      self.new(ch, q).subscribe(:block => true, :manual_ack => true)
      conn.close
    end
  end
end
