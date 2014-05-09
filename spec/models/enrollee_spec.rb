require 'spec_helper'

describe Enrollee do
  describe '#member' do
    let(:enrollee) { Enrollee.new(relationship_status_code: 'self', employment_status_code: 'active', benefit_status_code: 'active') }
    let(:id_to_lookup) { '666' }
    let(:different_id) { '777' }
    let(:person) { Person.new(name_first: 'Joe', name_last: 'Dirt') }
    let(:member) { Member.new(gender: 'male') }

    context 'no members with matching hbx id' do
      before do
        enrollee.m_id = different_id
        member.hbx_member_id = id_to_lookup
        person.members << member
        person.save!
      end
      it 'returns nil' do 
        expect(enrollee.member).to eq nil
      end
    end

    context 'member exists with matching hbx id' do
      before do
        enrollee.m_id = id_to_lookup
        member.hbx_member_id = id_to_lookup
        person.members << member
        person.save!
      end
      it 'returns the member' do 
        expect(enrollee.member).to eq member
      end
    end
  end
end
