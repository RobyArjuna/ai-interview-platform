# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Portfolios::Generator do
  let(:assessment) do
    Assessment.create!(
      tenant_id: 1,
      created_by: 1,
      name: 'Senior Frontend Engineer Assessment',
      time_limit_min: 45,
      language: 'en'
    )
  end

  let!(:skill_react) do
    AssessmentSkill.create!(
      assessment: assessment,
      skill_id: 'sk-react-001',
      skill_label: 'React Development',
      l1_anchor: 'Basic React',
      l2_anchor: 'Independent React',
      l3_anchor: 'Advanced React',
      l4_anchor: 'Architecture',
      l5_anchor: 'Expert',
      expected_level: 3,
      display_order: 1
    )
  end

  let!(:skill_graphql) do
    AssessmentSkill.create!(
      assessment: assessment,
      skill_id: 'sk-graphql-002',
      skill_label: 'GraphQL API',
      l1_anchor: 'Basic GraphQL',
      l2_anchor: 'Independent GraphQL',
      l3_anchor: 'Advanced GraphQL',
      l4_anchor: 'Schema Design',
      l5_anchor: 'Expert',
      expected_level: 2,
      display_order: 2
    )
  end

  let(:session) do
    Session.create!(
      tenant_id: 1,
      assessment: assessment,
      invite_token: 'test-token-123',
      status: 'ended',
      candidate_name: 'Jane Candidate'
    )
  end

  let!(:turn_1) do
    TranscriptTurn.create!(
      session: session,
      turn_number: 1,
      speaker: 'candidate',
      text: 'Saya bekerja dengan React hooks dan context API. Email saya jane@example.com'
    )
  end

  let(:mock_gemini_client) { instance_double(Gemini::HttpClient) }

  subject(:generator) { described_class.new(session: session, gemini_client: mock_gemini_client) }

  describe '#call' do
    context 'when Gemini returns valid assessment data with unassessed skills' do
      let(:gemini_json_response) do
        <<~JSON
          ```json
          {
            "configured_skills": [
              {
                "skill_id": "sk-react-001",
                "skill_label": "React Development",
                "level": 3,
                "confidence": "high",
                "evidence": ["Saya bekerja dengan React hooks"],
                "competency_summary": "Demonstrates strong understanding of state management."
              },
              {
                "skill_id": "sk-graphql-002",
                "skill_label": "GraphQL API",
                "level": null,
                "confidence": "not_assessed",
                "evidence": [],
                "competency_summary": "Skill was not evaluated."
              }
            ]
          }
          ```
        JSON
      end

      before do
        allow(mock_gemini_client).to receive(:generate_content).and_return(gemini_json_response)
      end

      it 'creates portfolio skills without assigning artificial level 1 to unassessed skills' do
        portfolio = generator.call

        expect(portfolio.generation_status).to eq('complete')
        expect(portfolio.portfolio_skills.count).to eq(2)

        react_ps = portfolio.portfolio_skills.find_by(skill_id: 'sk-react-001')
        expect(react_ps.ai_level).to eq(3)
        expect(react_ps.ai_confidence).to eq('high')

        graphql_ps = portfolio.portfolio_skills.find_by(skill_id: 'sk-graphql-002')
        expect(graphql_ps.ai_level).to be_nil
        expect(graphql_ps.ai_confidence).to eq('not_assessed')
      end

      it 'sanitizes candidate PII in transcript before sending prompt' do
        expect(mock_gemini_client).to receive(:generate_content) do |prompt, _opts|
          expect(prompt).to include('[REDACTED EMAIL]')
          expect(prompt).not_to include('jane@example.com')
          gemini_json_response
        end

        generator.call
      end
    end
  end
end
