import "server-only";
import {sql} from "drizzle-orm";
import {getDb} from "@/lib/db";

export type WorkListItem={stableKey:string;title:string;description:string|null;status:string;tradition:string|null;witnessCount:number};
export type ReaderContent={representationType:string;textContent:string;normalizedText:string|null;sourceTitle:string|null;sourceUrl:string|null;notes:string|null};
export type ReaderUnit={stableKey:string;label:string|null;unitType:string;pathKey:string|null;witnessLabel:string|null;translationTitle:string|null;contents:ReaderContent[];variantReadings:Array<{witnessLabel:string|null;readingText:string;normalizedText:string|null;notes:string|null;sourceTitle:string|null}>};
export type WorkDetail=WorkListItem&{workId:string;traditions:string[];dates:Array<{earliest:number|null;latest:number|null;precision:string|null;method:string|null;confidence:string|null;notes:string|null}>;witnesses:Array<{stableKey:string;label:string|null;type:string;language:string|null;script:string|null;dateNote:string|null}>;units:ReaderUnit[];sources:Array<{title:string;sourceType:string;author:string|null;url:string|null;notes:string|null}>};

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
  getDb().execute(sql`SELECT e.stable_key AS "stableKey",tu.label,tu.unit_type AS "unitType",tu.path_key AS "pathKey",tw.title_or_label AS "witnessLabel",tr.title AS "translationTitle" FROM textual_units tu JOIN entities e ON e.id=tu.id LEFT JOIN textual_witnesses tw ON tw.id=tu.witness_id LEFT JOIN translations tr ON tr.id=tu.translation_id LEFT JOIN entities we ON we.id=COALESCE(tw.work_id,(SELECT t2.work_id FROM textual_units tu2 JOIN translations tr2 ON tr2.id=tu2.translation_id JOIN translation_sources ts2 ON ts2.translation_id=tr2.id JOIN textual_witnesses t2 ON t2.id=ts2.witness_id WHERE tu2.id=tu.id LIMIT 1)) WHERE we.stable_key=${stableKey} ORDER BY tu.ordinal NULLS LAST,tu.path_key;`),
  getDb().execute(sql`SELECT DISTINCT s.title,s.source_type AS "sourceType",s.author_text AS author,s.url,s.notes FROM sources s JOIN work_traditions wt ON wt.source_id=s.id JOIN entities e ON e.id=wt.work_id WHERE e.stable_key=${stableKey} ORDER BY s.title;`)
 ]);
 const work=(wr as unknown as WorkDetail[])[0]; if(!work)return null;
 const units=un as unknown as Array<Omit<ReaderUnit,"contents"|"variantReadings">>;
 const unitIds=units.map(u=>u.stableKey);
 let contents:ReaderContent[]=[];
 let readings:Array<{variantId:string;witnessLabel:string|null;readingText:string;normalizedText:string|null;notes:string|null;sourceTitle:string|null}>=[];
 if(unitIds.length){
  const [cr,rr]=await Promise.all([
   getDb().execute(sql`SELECT e.stable_key AS "unitKey",tuc.representation_type AS "representationType",tuc.text_content AS "textContent",tuc.normalized_text AS "normalizedText",s.title AS "sourceTitle",s.url AS "sourceUrl",tuc.notes FROM textual_unit_contents tuc JOIN entities e ON e.id=tuc.id LEFT JOIN sources s ON s.id=tuc.source_id JOIN entities u ON u.id=tuc.textual_unit_id WHERE u.stable_key IN ${sql.raw("(" + unitIds.map(k=>"'" + k.replaceAll("'","''") + "'").join(",") + ")")} ORDER BY tuc.representation_type;`),
   getDb().execute(sql`SELECT uv.stable_key AS "unitKey",tw.title_or_label AS "witnessLabel",tvr.reading_text AS "readingText",tvr.normalized_text AS "normalizedText",tvr.notes,s.title AS "sourceTitle" FROM textual_variant_readings tvr JOIN textual_variants tv ON tv.id=tvr.variant_id JOIN entities uv ON uv.id=tv.textual_unit_id JOIN textual_witnesses tw ON tw.id=tvr.witness_id LEFT JOIN textual_variant_reading_sources tvrs ON tvrs.reading_id=tvr.id LEFT JOIN sources s ON s.id=tvrs.source_id WHERE uv.stable_key IN ${sql.raw("(" + unitIds.map(k=>"'" + k.replaceAll("'","''") + "'").join(",") + ")")} ORDER BY uv.stable_key,tw.title_or_label;`)
  ]);
  contents=cr as unknown as ReaderContent[];
  readings=rr as unknown as typeof readings;
 }
 const contentRows=contents as ReaderContent[] & Array<{unitKey?:string}>;
 const byUnit=new Map<string,ReaderContent[]>();
 for(const row of contentRows){const key=(row as unknown as {unitKey:string}).unitKey;(byUnit.get(key)??byUnit.set(key,[]).get(key)!).push(row)}
 const readingByUnit=new Map<string,typeof readings>();
 for(const row of readings){(readingByUnit.get(row.unitKey)??readingByUnit.set(row.unitKey,[]).get(row.unitKey)!).push(row)}
 return {...work,traditions:(tr as unknown as Array<{name:string}>).map(r=>r.name),dates:dr as unknown as WorkDetail["dates"],witnesses:wi as unknown as WorkDetail["witnesses"],units:units.map(u=>({...u,contents:byUnit.get(u.stableKey)??[],variantReadings:(readingByUnit.get(u.stableKey)??[]).map(r=>({witnessLabel:r.witnessLabel,readingText:r.readingText,normalizedText:r.normalizedText,notes:r.notes,sourceTitle:r.sourceTitle}))})),sources:sr as unknown as WorkDetail["sources"]};
}
