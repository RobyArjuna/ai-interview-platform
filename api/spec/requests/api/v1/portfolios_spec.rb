# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Portfolios', type: :request do
  let(:tenant_scheme) { 'test-corp' }
  let(:auth_token) do
    JsonWebToken.encode({ user_id: 1, role: 'admin', scheme: tenant_scheme })
  end
  let(:headers) do
    { 'Authorization' => "Bearer #{auth_token}" }
  end

  let(:assessment) do
    Assessment.create!(
      tenant_id: 1,
      created_by: 1,
      name: 'Fullstack Assessment',
      time_limit_min: 45
    )
  end

  let(:session) do
    Session.create!(
      tenant_id: 1,
      assessment: assessment,
      invite_token: 'req-token-999',
      status: 'ended',
      candidate_name: 'Test Candidate'
    )
  end

  let!(:portfolio) do
    Portfolio.create!(
      session: session,
      generation_status: 'complete',
      generated_at: Time.current
    )
  end

  let!(:ps1) do
    PortfolioSkill.create!(
      portfolio: portfolio,
      skill_id: 'sk-react-001',
      skill_label: 'React Development',
      is_discovered: false,
      ai_level: 4,
      ai_confidence: 'high',
      evidence: ['Hooks experience'],
      competency_summary: 'Proficient'
    )
  end

  let!(:ps2) do
    PortfolioSkill.create!(
      portfolio: portfolio,
      skill_id: 'sk-node-002',
      skill_label: 'Node.js',
      is_discovered: false,
      ai_level: nil,
      ai_confidence: 'not_assessed',
      evidence: [],
      competency_summary: 'Skill was not probed.'
    )
  end

  describe 'GET /api/v1/sessions/:id/portfolio' do
    it 'returns portfolio details including unassessed skills' do
      get "/api/v1/sessions/#{session.id}/portfolio", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['portfolio']['generation_status']).to eq('complete')
      skills = json['portfolio']['skills']
      expect(skills.length).to eq(2)

      react_skill = skills.find { |s| s['skill_label'] == 'React Development' }
      expect(react_skill['ai_level']).to eq(4)

      node_skill = skills.find { |s| s['skill_label'] == 'Node.js' }
      expect(node_skill['ai_level']).to be_nil
      expect(node_skill['ai_confidence']).to eq('not_assessed')
    end
  end
end
