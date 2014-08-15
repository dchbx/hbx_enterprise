module PeopleHelper

	def person_members(person = @person)
		person.members
	end

	def policy_market(policy)
		policy.employer.blank? ? "Individual" : policy.employer.name
	end

	def policy_sponsor(policy)
		policy_market(policy) == "Individual" ? "Individual" : raw(link_to truncate(policy_market(policy), length: 35), employer_path(policy.employer))
	end

	def policy_status(policy)
		status = policy.aasm_state.capitalize
		# raw(<span class="label label-warning">status</span>) if ["Canceled", "Terminated"].include?(status)
	end

	def format_date(date_value)
		date_value.strftime("%m-%d-%Y") if date_value.respond_to?(:strftime)
	end

	def member_policies(member = @member)
		member.policies
	end

	# Formats a member's identifying information attributes into a compact display string
	def member_heading(member)
			mbr_id  = member.hbx_member_id
			mbr_gen = member.gender.capitalize
			mbr_dob = member.dob.strftime("%m-%d-%Y") if member.dob..present?
			mbr_ssn = number_to_ssn(member.ssn)

			"HBX Member ID: #{mbr_id} | Gender: #{mbr_gen} | DOB: #{mbr_dob} | SSN: #{mbr_ssn}"
	end

	# Formats a relationship code into display string
	def relationship_code_to_human(str)
		(str == "self" ? "Subscriber" : str.capitalize) unless str.nil? || str.empty?
	end

	def trans_aasm_state(trans)
		if trans.aasm_state == "rejected"
    	raw("<span class='label label-danger'>#{trans.aasm_state.humanize}</span>")
    else
    	raw("<span class='label label-success'>#{trans.aasm_state.humanize}</span>")
    end
	end

  def controls_for_people(person)
    if can? :edit, @people
      contents = render(partial: 'people/controls/admin', locals: {person: person})
    else
      contents = render(partial: 'people/controls/user', locals: {person: person})
    end
  end

private

  def handle_none(value)
    if value.present?
      yield
    else
      h.content_tag :span, "None given", class: "none"
    end
  end


end
