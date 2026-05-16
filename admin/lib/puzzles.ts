import {
  addDoc,
  collection,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  Timestamp,
} from "firebase/firestore";

import { getFirebaseAuth, getFirebaseDb } from "./firebase";

export interface Puzzle {
  id: string;
  fen: string;
  solution: string[];
  difficulty: number;
  themes: string[];
  published: boolean;
  createdAt: Date;
  createdBy: string;
}

export interface NewPuzzle {
  fen: string;
  solution: string[];
  difficulty: number;
  themes: string[];
  published: boolean;
}

const COLLECTION = "puzzles";

export async function listAllPuzzles(): Promise<Puzzle[]> {
  const snap = await getDocs(
    query(collection(getFirebaseDb(), COLLECTION), orderBy("createdAt", "desc")),
  );
  return snap.docs.map((d) => {
    const data = d.data();
    return {
      id: d.id,
      fen: data.fen,
      solution: data.solution ?? [],
      difficulty: data.difficulty,
      themes: data.themes ?? [],
      published: data.published ?? false,
      createdAt: (data.createdAt as Timestamp)?.toDate() ?? new Date(),
      createdBy: data.createdBy ?? "",
    };
  });
}

export async function createPuzzle(input: NewPuzzle): Promise<string> {
  const uid = getFirebaseAuth().currentUser?.uid;
  if (!uid) throw new Error("Must be signed in to create a puzzle.");

  const ref = await addDoc(collection(getFirebaseDb(), COLLECTION), {
    ...input,
    createdAt: serverTimestamp(),
    createdBy: uid,
  });
  return ref.id;
}
