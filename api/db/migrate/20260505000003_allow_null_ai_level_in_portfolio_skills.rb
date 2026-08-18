# frozen_string_literal: true

class AllowNullAiLevelInPortfolioSkills < ActiveRecord::Migration[7.0]
  def change
    # Allow NULL on ai_level for unassessed skills
    change_column_null :portfolio_skills, :ai_level, true

    # Drop old check constraint and recreate allowing NULL
    execute <<~SQL
      ALTER TABLE ai_interview.portfolio_skills DROP CONSTRAINT IF EXISTS chk_portfolio_skills_ai_level;
      ALTER TABLE ai_interview.portfolio_skills ADD CONSTRAINT chk_portfolio_skills_ai_level CHECK (ai_level IS NULL OR (ai_level >= 1 AND ai_level <= 5));
      ALTER TYPE ai_interview.confidence_level ADD VALUE IF NOT EXISTS 'not_assessed';
    SQL
  end
end
