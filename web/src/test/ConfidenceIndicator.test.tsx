import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import ConfidenceIndicator from "@/components/portfolio/ConfidenceIndicator";

describe("ConfidenceIndicator", () => {
  it("renders HIGH confidence indicator", () => {
    render(<ConfidenceIndicator confidence="high" />);
    expect(screen.getByText("Confidence: HIGH")).toBeInTheDocument();
  });

  it("renders MEDIUM confidence indicator", () => {
    render(<ConfidenceIndicator confidence="medium" />);
    expect(screen.getByText("Confidence: MEDIUM")).toBeInTheDocument();
  });

  it("renders LOW confidence indicator", () => {
    render(<ConfidenceIndicator confidence="low" />);
    expect(screen.getByText("Confidence: LOW")).toBeInTheDocument();
  });

  it("renders NOT ASSESSED status indicator for unassessed skills", () => {
    render(<ConfidenceIndicator confidence="not_assessed" />);
    expect(screen.getByText("Status: NOT ASSESSED")).toBeInTheDocument();
  });
});
