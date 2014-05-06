class Email
  include Mongoid::Document

  include MergingModel

  field :email_type, type: String
  field :email_address, type: String

  validates_inclusion_of :email_type, in: ["home", "work"]
  validates_presence_of :email_address

  embedded_in :person, :inverse_of => :emails
  embedded_in :employer, :inverse_of => :emails

  def match(another_email)
    return false if another_email.nil?
    attrs_to_match = [:email_type, :email_address]
    attrs_to_match.all? { |attr| attribute_matches?(attr, another_email) }
  end

  def attribute_matches?(attribute, other)
    self[attribute] == other[attribute]
  end

  def merge_update(m_email)
    merge_with_overwrite(
      m_email,
      :email_address
    )
  end
end
