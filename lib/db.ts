import "server-only";
import {drizzle} from "drizzle-orm/postgres-js";
import postgres from "postgres";

let database: ReturnType<typeof drizzle> | null = null;

export function getDb(){
  if(database)return database;
  const url=process.env.DATABASE_URL;
  if(!url)throw new Error("DATABASE_URL is not configured.");
  const client=postgres(url,{prepare:false,max:5});
  database=drizzle(client);
  return database;
}
