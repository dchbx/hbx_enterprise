#This controller will process the incomming enrollment CV
HbxEnterprise::App.controllers :enrollments, map: '/api/v1/enrollment' do

  #if invalid CV
  # Reject
  #else
  # Process
  post '' do
    content_type 'application/xml'
    xml = request.body.read

    enrollment_validator = EnrollmentValidator.new(xml)
    enrollment_validator.check_against_schema

    if enrollment_validator.valid?
      status 202
      body "<response><success>Success. XML accepted.</success></response>"
    else
      halt(422, enrollment_validator.errors.to_xml)
    end
  end
end
