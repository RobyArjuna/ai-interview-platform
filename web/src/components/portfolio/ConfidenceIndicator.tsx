interface ConfidenceIndicatorProps {
  confidence: string; // "high" | "medium" | "low" from API
}

function getLabel(c: string): "HIGH" | "MEDIUM" | "LOW" | "NOT_ASSESSED" {
  const normalized = c?.toLowerCase();
  if (normalized === "high") return "HIGH";
  if (normalized === "medium") return "MEDIUM";
  if (normalized === "not_assessed" || normalized === "unassessed") return "NOT_ASSESSED";
  return "LOW";
}

export default function ConfidenceIndicator({ confidence }: ConfidenceIndicatorProps) {
  const label = getLabel(confidence);

  if (label === "HIGH") {
    return (
      <span className="flex items-center gap-1 text-xs text-green-600 font-medium">
        <span className="h-2 w-2 rounded-full bg-green-500" />
        Confidence: HIGH
      </span>
    );
  }
  if (label === "MEDIUM") {
    return (
      <span className="flex items-center gap-1 text-xs text-amber-600 font-medium">
        <span className="h-2 w-2 rounded-full bg-amber-400" />
        Confidence: MEDIUM
      </span>
    );
  }
  if (label === "NOT_ASSESSED") {
    return (
      <span className="flex items-center gap-1 text-xs text-neutral-500 font-medium">
        <span className="h-2 w-2 rounded-full bg-neutral-300" />
        Status: NOT ASSESSED
      </span>
    );
  }
  return (
    <span className="flex items-center gap-1 text-xs text-destructive font-medium">
      <span className="h-2 w-2 rounded-full bg-destructive" />
      Confidence: LOW
    </span>
  );
}
