require 'spec_helper'

describe Listeners::AcedsAccountLookupListener do
  let(:queue) { double }
  let(:channel) { double(:acknowledge => nil) }
  let(:event_exchange) { double }
  let(:payload) { double }
  let(:delivery_info) { double(:delivery_tag => "") }
  let(:properties) { double(:reply_to => "hbx_enterprise.aceds_account_lookup") }
  let(:expected_payload) { "" }
  let(:event_name) { "" }
  let(:event_parser) { double }
  let(:timestamp) { double }
  let(:parsed_event) { double(:event_type => event_type, :event_uri => event_uri, :routing_key => routing_key) }

  before :each do
    allow(event_parser).to receive(:parse).with(payload).and_return(parsed_event)
  end

  subject { Listeners::AcedsAccountLookupListener.new(channel, queue) }

  describe "lookup aceds account" do
    let(:event_type) { "ACEDS-ACCOUNT-LOOKUP" }
    let(:event_uri) { "urn:openhbx:requests:v1:hbx_enterprise#aceds_account_lookup" }
    let(:routing_key) { "hbx_enterprise.aceds_account_lookup" }
    let(:headers) { {:return_status=>"503"} }
    let(:expected_properties) { { :routing_key => routing_key, :headers => headers } }

    before :each do
      allow_any_instance_of(URI::Generic).to receive(:request_uri).and_return(event_uri)
      allow(channel).to receive(:default_exchange).and_return(event_exchange)
      allow(properties).to receive(:headers).and_return(headers)
    end

    it "should broadcast the event" do
      expect(event_exchange).to receive(:publish).with(expected_payload, expected_properties)
      subject.on_message(delivery_info, properties, payload)
    end
  end
end
