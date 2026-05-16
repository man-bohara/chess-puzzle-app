"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

import { createPuzzle } from "@/lib/puzzles";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

export default function NewPuzzlePage() {
  const router = useRouter();
  const [fen, setFen] = useState("");
  const [solution, setSolution] = useState("");
  const [difficulty, setDifficulty] = useState(3);
  const [themes, setThemes] = useState("");
  const [published, setPublished] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      await createPuzzle({
        fen: fen.trim(),
        solution: solution
          .split(/\s+/)
          .map((m) => m.trim())
          .filter(Boolean),
        difficulty,
        themes: themes
          .split(",")
          .map((t) => t.trim())
          .filter(Boolean),
        published,
      });
      router.push("/puzzles");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create puzzle");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form onSubmit={onSubmit} className="mx-auto max-w-2xl space-y-4">
      <h1 className="text-2xl font-semibold">New puzzle</h1>

      <div className="space-y-2">
        <Label htmlFor="fen">FEN</Label>
        <Input
          id="fen"
          value={fen}
          onChange={(e) => setFen(e.target.value)}
          placeholder="rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
          className="font-mono"
          required
        />
      </div>

      <div className="space-y-2">
        <Label htmlFor="solution">Solution (UCI moves, space-separated)</Label>
        <Textarea
          id="solution"
          value={solution}
          onChange={(e) => setSolution(e.target.value)}
          placeholder="e2e4 e7e5 g1f3"
          className="font-mono"
          required
        />
        <p className="text-xs text-muted-foreground">
          Include the opponent&apos;s replies — the mobile app plays them automatically.
        </p>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label htmlFor="difficulty">Difficulty (1–5)</Label>
          <Input
            id="difficulty"
            type="number"
            min={1}
            max={5}
            value={difficulty}
            onChange={(e) => setDifficulty(Number(e.target.value))}
            required
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor="themes">Themes (comma-separated)</Label>
          <Input
            id="themes"
            value={themes}
            onChange={(e) => setThemes(e.target.value)}
            placeholder="fork, pin, mateIn2"
          />
        </div>
      </div>

      <label className="flex items-center gap-2">
        <input
          type="checkbox"
          checked={published}
          onChange={(e) => setPublished(e.target.checked)}
        />
        <span>Publish immediately</span>
      </label>

      {error && <p className="text-sm text-destructive">{error}</p>}

      <Button type="submit" disabled={submitting}>
        {submitting ? "Saving…" : "Create puzzle"}
      </Button>
    </form>
  );
}
