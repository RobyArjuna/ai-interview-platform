import { render, screen } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";
import SkillPortfolioCard from "@/components/portfolio/SkillPortfolioCard";
import type { PortfolioSkill } from "@/types";

describe("SkillPortfolioCard", () => {
  const sampleSkillAssessed: PortfolioSkill = {
    id: 1,
    skill_id: "sk-react-001",
    skill_label: "React Development",
    is_discovered: false,
    ai_level: 3,
    ai_confidence: "high",
    evidence: ["Demonstrated custom hooks usage"],
    competency_summary: "Strong candidate in React state architecture.",
  };

  const sampleSkillUnassessed: PortfolioSkill = {
    id: 2,
    skill_id: "sk-graphql-002",
    skill_label: "GraphQL API",
    is_discovered: false,
    ai_level: null,
    ai_confidence: "not_assessed",
    evidence: [],
    competency_summary: "Skill was not probed during interview.",
  };

  it("renders assessed skill card with level badge and confidence", () => {
    render(
      <SkillPortfolioCard
        skill={sampleSkillAssessed}
        onOverrideSaved={vi.fn()}
      />
    );

    expect(screen.getByText("React Development")).toBeInTheDocument();
    expect(screen.getByText("L3")).toBeInTheDocument();
    expect(screen.getByText("Confidence: HIGH")).toBeInTheDocument();
    expect(screen.getByText(/Demonstrated custom hooks usage/i)).toBeInTheDocument();
  });

  it("renders unassessed skill card with N/A badge and NOT ASSESSED status without showing Level 1", () => {
    render(
      <SkillPortfolioCard
        skill={sampleSkillUnassessed}
        onOverrideSaved={vi.fn()}
      />
    );

    expect(screen.getByText("GraphQL API")).toBeInTheDocument();
    expect(screen.getByText("N/A")).toBeInTheDocument();
    expect(screen.getByText("Status: NOT ASSESSED")).toBeInTheDocument();
    expect(screen.queryByText("L1")).not.toBeInTheDocument();
  });
});
