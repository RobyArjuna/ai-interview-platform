import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import LevelBadge from "@/components/portfolio/LevelBadge";

describe("LevelBadge", () => {
  it("renders valid level labels and descriptions", () => {
    render(<LevelBadge level={3} size="md" />);
    expect(screen.getByText("L3")).toBeInTheDocument();
    expect(screen.getByText("Proficient")).toBeInTheDocument();
  });

  it("renders N/A and Unassessed for null level", () => {
    render(<LevelBadge level={null} size="md" />);
    expect(screen.getByText("N/A")).toBeInTheDocument();
    expect(screen.getByText("Unassessed")).toBeInTheDocument();
  });

  it("renders N/A for undefined level", () => {
    render(<LevelBadge level={undefined} size="sm" />);
    expect(screen.getByText("N/A")).toBeInTheDocument();
  });
});
