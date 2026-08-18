# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PortfolioSkill, type: :model do
  let(:assessment) do
    Assessment.create!(
      tenant_id: 1,
      created_by: 1,
      name: 'Fullstack Engineer Assessment',
      time_limit_min: 45
    )
  end

  let(:session) do
    Session.create!(
      tenant_id: 1,
      assessment: assessment,
      invite_token: 'token-model-spec-123',
      status: 'ended'
    )
  end

  let(:portfolio) do
    Portfolio.create!(
      session: session,
      generation_status: 'complete'
    )
  end

  describe 'validations' do
    it 'is valid with integer ai_level between 1 and 5' do
      ps = described_class.new(
        portfolio: portfolio,
        skill_label: 'React Development',
        ai_level: 4,
        ai_confidence: 'high',
        competency_summary: 'Good understanding.'
      )
      expect(ps).to be_valid
    end

    it 'is valid with nil ai_level and not_assessed confidence for unassessed skills' do
      ps = described_class.new(
        portfolio: portfolio,
        skill_label: 'GraphQL API',
        ai_level: nil,
        ai_confidence: 'not_assessed',
        competency_summary: 'Skill was not probed.'
      )
      expect(ps).to be_valid
    end

    it 'is invalid with integer ai_level out of 1..5 range' do
      ps = described_class.new(
        portfolio: portfolio,
        skill_label: 'Docker',
        ai_level: 6,
        ai_confidence: 'low',
        competency_summary: 'Summary'
      )
      expect(ps).not_to be_valid
    end
  end
end
