class PersonRelationship
  include Mongoid::Document
  include Mongoid::Timestamps

  MALE_RELATIONSHIPS_LIST   = %W(father grandfather grandson uncle nephew adopted\ child stepparent
                              foster\ child son-in-law brother-in-law father-in-law brother ward
                              stepson child sponsored\ dependent dependent\ of\ a\ minor\ dependent
                              guardian court\ appointed\ guardian collateral\ dependent life\ partner)

  FEMALE_RELATIONSHIPS_LIST = %W(mother grandmother granddaughter aunt niece adopted\ child stepparent
                              foster\ child daughter-in-law sister-in-law mother-in-law sister ward
                              stepdaughter child sponsored\ dependent dependent\ of\ a\ minor\ dependent
                              guardian court\ appointed\ guardian collateral\ dependent life\ partner)
  RELATIONSHIPS_LIST = [
    "parent",
    "grandparent",
    "aunt_or_uncle",
    "nephew_or_niece",
    "father_or_mother_in_law",
    "daughter_or_son_in_law",
    "brother_or_sister_in_law",
    "adopted_child",
    "stepparent",
    "foster_child",
    "sibling",
    "ward",
    "stepchild",
    "sponsored_dependent",
    "dependent_of_a_minor_dependent",
    "guardian",
    "court_appointed_guardian",
    "collateral_dependent",
    "life_partner",
    "spouse",
    "child",
    "grandchild",
    "trustee", # no inverse
    "annuitant", # no inverse,
    "other_relationship",
    "unrelated",
    "great_grandparent",
    "great_grandchild"
  ]

  INVERSE_MAP = {
    "child" => "parent",
    "parent" => "child",
    "grandparent" => "grandchild",
    "grandchild" => "grandparent",
    "great_grandparent" => "great_grandchild",
    "great_grandchild" => "great_grandparent",
    "stepparent" => "stepchild",
    "stepchild" => "stepparent",
    "aunt_or_uncle" => "nephew_or_niece",
    "nephew_or_niece" => "aunt_or_uncle",
    "father_or_mother_in_law" => "daughter_or_son_in_law",
    "daughter_or_son_in_law" => "father_or_mother_in_law",
    "guardian" => "ward",
    "ward" => "guardian",

    # bi directional
    "brother_or_sister_in_law" => "brother_or_sister_in_law",
    "sibling" => "sibling",
    "life_partner" => "life_partner",
    "spouse" => "spouse",
    "other_relationship" => "other_relationship",
    "cousin" => "cousin",
    "unrelated" => "unrelated",

    #one directional
    "foster_child" => "guardian",
    "court_appointed_guardian" => "ward",
    "adopted_child" => "parent"
  }

  SYMMETRICAL_RELATIONSHIPS_LIST = %W[head\ of\ household spouse ex-spouse cousin ward trustee annuitant other\ relationship other\ relative self]

  ALL_RELATIONSHIPS_LIST    =  SYMMETRICAL_RELATIONSHIPS_LIST | RELATIONSHIPS_LIST

  # Relationships are defined using RDF-style Subject -> Predicate -> Object
  # Generally speaking, it works better if you imagine it as:
  #   Subject -> "is the <relationship kind> of" -> Object
  #   A -> "is the child of" -> B
  field :relationship_kind, type: String
  belongs_to :subject_person, :class_name => "Person", :inverse_of => nil
  belongs_to :object_person, :class_name => "Person", :inverse_of => nil

	validates_presence_of :subject_person_id, :relationship_kind, :object_person_id
	validates_inclusion_of :relationship_kind, in: ALL_RELATIONSHIPS_LIST

  embedded_in :person

  def inverse
    result = nil

    inverse_kind = INVERSE_MAP[relationship_kind]
    if(inverse_kind)
      result = PersonRelationship.new({
        :subject_person => object_person,
        :object_person => subject_person,
        :relationship_kind => inverse_kind
        })
    end

    result
  end

end