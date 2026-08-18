# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FitGap::Engine do
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
      invite_token: 'fitgap-token-456',
      status: 'ended'
    )
  end

  let(:portfolio) do
    Portfolio.create!(
      session: session,
      generation_status: 'complete'
    )
  end

  let!(:ps_assessed) do
    PortfolioSkill.create!(
      portfolio: portfolio,
      skill_id: 'sk-ruby-001',
      skill_label: 'Ruby on Rails',
      is_discovered: false,
      ai_level: 4,
      ai_confidence: 'high',
      evidence: ['Experienced with Rails APIs'],
      competency_summary: 'Solid Rails experience.'
    )
  end

  let!(:ps_unassessed) do
    PortfolioSkill.create!(
      portfolio: portfolio,
      skill_id: 'sk-docker-002',
      skill_label: 'Docker Containerization',
      is_discovered: false,
      ai_level: nil,
      ai_confidence: 'not_assessed',
      evidence: [],
      competency_summary: 'Skill was not probed.'
    )
  end

  let(:vacancy) do
    Vacancy.create!(
      tenant_id: 1,
      created_by: 1,
      role_title: 'Senior Backend Engineer'
    )
  end

  let!(:vs_ruby) do
    VacancySkill.create!(
      vacancy: vacancy,
      skill_id: 'sk-ruby-001',
      skill_label: 'Ruby on Rails',
      expected_level: 3
    )
  end

  let!(:vs_docker) do
    VacancySkill.create!(
      vacancy: vacancy,
      skill_id: 'sk-docker-002',
      skill_label: 'Docker Containerization',
      expected_level: 2
    )
  end

  let(:mock_gemini_client) { instance_double(Gemini::HttpClient) }

  subject(:engine) { described_class.new(portfolio: portfolio, vacancy: vacancy, gemini_client: mock_gemini_client) }

  describe '#call' do
    before do
      allow(mock_gemini_client).to receive(:generate_content).and_return({
        'culture_narrative' => 'Strong culture match.',
        'overall_narrative' => 'Recommended for next interview phase.'
      }.to_json)
    end

    it 'correctly calculates match/gap for assessed skills and flags unassessed skills without raising error' do
      report = engine.call

      expect(report).to be_persisted
      comparisons = report.skill_comparisons

      ruby_comp = comparisons.find { |c| c['skill_id'] == 'sk-ruby-001' }
      expect(ruby_comp['candidate_level']).to eq(4)
      expect(ruby_comp['expected_level']).to eq(3)
      expect(ruby_comp['result']).to eq('exceed')
      expect(ruby_comp['delta']).to eq(1)

      docker_comp = comparisons.find { |c| c['skill_id'] == 'sk-docker-002' }
      expect(docker_comp['candidate_level']).to be_nil
      expect(docker_comp['result']).to eq('not_assessed')
      expect(docker_comp['delta']).to be_nil
    end
  end
end
