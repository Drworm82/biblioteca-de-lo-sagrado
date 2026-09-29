import "server-only";
import {sql} from "drizzle-orm";
import {getDb} from "@/lib/db";

export type WorkListItem={stableKey:string;title:string;description:string|null;status:string;tradition:string|null;witnessCount:number};
export type WorkDetail=WorkListItem&{workId:string;traditions:string[];dates:Array<{earliest:number|null;latest:number|null;precision:string|null;method:string|null;confidence:string|null;notes:string|null}>;witnesses:Array<{stableKey:string;label:string|null;type:string;language:string|null;script:string|null;dateNote:string|null}>;units:Array<{stableKey:string;label:string|null;unitType:string;pathKey:string|null;witnessLabel:string|null;translationTitle:string|null}>;sources:Array<{title:string;sourceType:string;author:string|null;url:string|null;notes:string|null}>};

export async function listWorks():Promise<WorkListItem[]>{
 const rows=await getDb().execute(sql`
 SELECT e.stable_key AS "stableKey",w.title,w.description,w.status,MIN(t.name) AS tradition,COUNT(DISTINCT tw.id)::int AS "witnessCount"
 FROM works w JOIN entities e ON e.id=w.id LEFT JOIN work_traditions wt ON wt.work_id=w.id LEFT JOIN traditions t ON t.id=wt.tradition_id LEFT JOIN textual_witnesses tw ON tw.work_id=w.id
 GROUP BY e.stable_key,w.title,w.description,w.status ORDER BY w.title;
 `);
 return rows as unknown as WorkListItem[];
}

export async function getWorkDetail(stableKey:string):Promise<WorkDetail|null>{
 const [wr,tr,dr,wi,un,sr]=await Promise.all([
  getDb().execute(sql`SELECT e.id AS "workId",e.stable_key AS "stableKey",w.title,w.description,w.status,COUNT(DISTINCT tw.id)::int AS "witnessCount",MIN(t.name) AS tradition FROM works w JOIN entities e ON e.id=w.id LEFT JOIN work_traditions wt ON wt.work_id=w.id LEFT JOIN traditions t ON t.id=wt.tradition_id LEFT JOIN textual_witnesses tw ON tw.work_id=w.id WHERE e.entity_type='work' AND e.stable_key=${stableKey} GROUP BY e.id,e.stable_key,w.title,w.description,w.status;`),
  getDb().execute(sql`SELECT t.name FROM work_traditions wt JOIN traditions t ON t.id=wt.tradition_id JOIN entities e ON e.id=wt.work_id WHERE e.stable_key=${stableKey} ORDER BY t.name;`),
  getDb().execute(sql`SELECT da.earliest,da.latest,da.precision,da.dating_method AS method,cl.label AS confidence,da.notes FROM dating_assertions da JOIN entities e ON e.id=da.entity_id LEFT JOIN confidence_levels cl ON cl.id=da.confidence_id WHERE e.stable_key=${stableKey} ORDER BY da.earliest NULLS LAST;`),
  getDb().execute(sql`SELECT e.stable_key AS "stableKey",tw.title_or_label AS label,tw.witness_type AS type,l.name AS language,s.name AS script,tw.date_note AS "dateNote" FROM textual_witnesses tw JOIN entities e ON e.id=tw.id LEFT JOIN languages l ON l.id=tw.language_id LEFT JOIN scripts s ON s.id=tw.script_id JOIN entities we ON we.id=tw.work_id WHERE we.stable_key=${stableKey} ORDER BY tw.title_or_label;`),
  getDb().execute(sql`SELECT e.stable_key AS "stableKey",tu.label,tu.unit_type AS "unitType",tu.path_key AS "pathKey",tw.title_or_label AS "witnessLabel",tr.title AS "translationTitle" FROM textual_units tu JOIN entities e ON e.id=tu.id LEFT JOIN textual_witnesses tw ON tw.id=tu.witness_id LEFT JOIN translations tr ON tr.id=tu.translation_id LEFT JOIN entities we ON we.id=tw.work_id WHERE we.stable_key=${stableKey} ORDER BY tu.ordinal NULLS LAST,tu.path_key;`),
  getDb().execute(sql`SELECT DISTINCT s.title,s.source_type AS "sourceType",s.author_text AS author,s.url,s.notes FROM sources s JOIN work_traditions wt ON wt.source_id=s.id JOIN entities e ON e.id=wt.work_id WHERE e.stable_key=${stableKey} ORDER BY s.title;`)
 ]);
 const work=(wr as unknown as WorkDetail[])[0]; if(!work)return null;
 return {...work,traditions:(tr as unknown as Array<{name:string}>).map(r=>r.name),dates:dr as unknown as WorkDetail["dates"],witnesses:wi as unknown as WorkDetail["witnesses"],units:un as unknown as WorkDetail["units"],sources:sr as unknown as WorkDetail["sources"]};
}
