class HbxEnterprise::App
  post '/employers/legacy_xml' do

    @cv_hash = Parsers::Xml::Cv::OrganizationParser.parse(request.body.read).to_hash

    @plan_year = plan_year_for_year(@cv_hash[:employer_profile][:plan_years], '2015', '01', '08')
    #@plan_year = latest_plan_year(@cv_hash[:employer_profile][:plan_years])

    if @plan_year.nil?
      puts "Plan Year is nil FEIN #{@cv_hash[:fein]}"
      return
    end

    @carriers = @plan_year[:elected_plans].map do |plan| plan[:carrier][:name] end.uniq

    dir_path = "/Users/CitadelFirm/Downloads/cvs-aug22/8038/"

    @carriers.each do |carrier|
      @carrier = carrier
      group_xml = render "employers/legacy_employer"
      File.open(dir_path + @carrier + ".xml", 'a') { |file| file.write(group_xml) }
    end
  end
end