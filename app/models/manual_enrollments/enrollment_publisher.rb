module ManualEnrollments
  class EnrollmentPublisher

    def initialize
      conn = Bunny.new('amqp://guest:guest@10.83.85.128:5672')
      conn.start

      @ch = conn.create_channel
      @requestor = Amqp::Requestor.new(conn)
    end

    def publish(payload)
      properties = {
        :routing_key => 'enrollment.create',
        :headers => {
          qualifying_reason_uri: 'urn:dc0:terms:v1:qualifying_life_event#open_enrollment'
        }}
      @requestor.request(properties, payload)
    end
  end
end