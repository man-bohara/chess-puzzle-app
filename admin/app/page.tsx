import Link from "next/link";
import { buttonVariants } from "@/components/ui/button";

export default function Home() {
  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-3xl font-semibold">Dashboard</h1>
      <p className="text-muted-foreground">
        Author chess puzzles and publish them to the mobile app.
      </p>
      <div className="flex gap-3">
        <Link href="/puzzles/new" className={buttonVariants()}>
          New puzzle
        </Link>
        <Link
          href="/puzzles"
          className={buttonVariants({ variant: "outline" })}
        >
          View all puzzles
        </Link>
      </div>
    </div>
  );
}
