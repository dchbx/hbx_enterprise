class CancelTerminate
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  CancelTerminate  = Struct.new(:affect_selected, :include_selected, :m_id, :name, :role) do
    def initialize(h)
      super(*h.values_at(:affect_selected, :include_selected, :m_id, :name, :role))
    end

    def persisted?
      false
    end
  end

  attr_accessor :policy_id
  attr_accessor :operation, :reason, :benefit_end_date
  attr_accessor :people
  attr_accessor :policy
  attr_accessor :action

  validate :term_date_valid?, :unless => :is_cancel?
  validates_presence_of :reason

  def initialize(props = {})
    @policy = Policy.find(props[:id])
    # raise props.inspect
    detail = props[:cancel_terminate]

    if(!detail.nil?)
      @operation = detail[:operation]
      @reason = detail[:reason]
      @benefit_end_date = detail[:benefit_end_date]
      ppl_hash = detail.fetch(:people_attributes) { {} }
      @people = ppl_hash.values.map { |person| CancelTerminate.new(person) }
    else
      @people = map_people_from_policy(@policy) 
    end
  end

  def is_cancel?
    @operation == "cancel"
  end

  def selected_at_least_one
    @people.any?{|p| p.include_selected == "0"}
  end

  def map_people_from_policy(enroll)
    policy.enrollees.map do |em|
      per = em.person
      CancelTerminate.new({m_id: em.m_id, name: per.name_full, role: em.rel_code, affect_selected: true, include_selected: true})
    end
  end

  # def subcriber_terminate
  #   if @people.any?{ |p| p.include_selected == "1" && p.role == "self"}
  #     @people.each { |p| p.include_selected = "1" }
  #   end
  # end

  # def add_benefit_end
  #   @policy.enrollees.each do |e|
  #     if included_person?(e.m_id)
  #       if is_cancel?
  #         e.coverage_end = e.coverage_start
  #       else
  #         e.coverage_end = term_date(e.coverage_start)
  #       end
  #       e.coverage_status = "inactive"
  #     end
  #   end
  # end

  def term_date_valid?
    #get affected enrollees
    #check if any of their dates are invalid
    if(@benefit_end_date.blank?)
      errors.add(:benefit_end_date, "can't be blank.")
      return
    end
    affected_enrollees = @people.map{ |p| @policy.enrollee_for_member_id(p[:m_id])}
    if affected_enrollees.any?{ |e| e.coverage_start > @benefit_end_date.to_date }
      errors.add(:benefit_end_date, "must be after Benefit Begin Date")
    end
  end

  # def included_person?(id)
  #   @people.any?{|p| p.include_selected == "1" && p.m_id == id }
  # end

  # def to_cv
  #   subcriber_terminate
  #   add_benefit_end
  #   include_member_ids = @people.reject { |p| p.include_selected == "0" }.map(&:m_id)
  #   member_ids = include_member_ids
  #   ser = CanonicalVocabulary::MaintenanceSerializer.new(
  #     @policy,
  #     @operation,
  #     @reason,
  #     member_ids,
  #     include_member_ids
  #   )
  #   ser.serialize
  # end

  def people_attributes=(pas)
  end

  def persisted?; false; end

  def self.reasons
    [
      ["Reason", nil],
      ["death", "death"],
      ["termination_of_benefits", "termination_of_benefits"]
    ]
  end

end
