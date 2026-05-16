"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import { listAllPuzzles, type Puzzle } from "@/lib/puzzles";
import { buttonVariants } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

export default function PuzzlesPage() {
  const [puzzles, setPuzzles] = useState<Puzzle[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    listAllPuzzles()
      .then(setPuzzles)
      .catch((e) => setError(e instanceof Error ? e.message : String(e)));
  }, []);

  if (error) return <p className="text-destructive">{error}</p>;
  if (!puzzles) return <p>Loading…</p>;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Puzzles</h1>
        <Link href="/puzzles/new" className={buttonVariants()}>
          New puzzle
        </Link>
      </div>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>ID</TableHead>
            <TableHead>Difficulty</TableHead>
            <TableHead>Themes</TableHead>
            <TableHead>Published</TableHead>
            <TableHead>Created</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {puzzles.map((p) => (
            <TableRow key={p.id}>
              <TableCell className="font-mono text-xs">{p.id.slice(0, 8)}</TableCell>
              <TableCell>{p.difficulty}</TableCell>
              <TableCell>{p.themes.join(", ")}</TableCell>
              <TableCell>{p.published ? "Yes" : "Draft"}</TableCell>
              <TableCell>{p.createdAt.toLocaleDateString()}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
