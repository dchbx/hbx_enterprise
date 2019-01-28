HbxEnterprise::App.helpers do
  def hyphen_separated_date(date)
    original_date = Date.strptime(date, "%Y%m%d")
    original_date.strftime("%Y-%m-%d")
  end

  def primary_office_location(office_locations)
    office_locations.detect do |office_location|
      office_location[:primary] == 'true'
    end
  end

  def plan_year_for_year(plan_years, year, day, month)
    plan_years.detect do |plan_year|
      date = Date.strptime(plan_year[:plan_year_start], "%Y%m%d")
      (date.year.to_s == year) && (date.day.to_i == day.to_i) && (date.month.to_i == month.to_i)
    end
  end

  def plan_exchange_id(hios_id, active_year)
    active_year + "" + hios_id.gsub(/[^0-9]/, '')
  end

  def latest_plan_year(plan_years)
    return plan_years.first if plan_years.length == 1
    plan_years.sort_by do |plan_year|
      Date.strptime(plan_year[:plan_year_start], "%Y%m%d")
    end.last
  end
end