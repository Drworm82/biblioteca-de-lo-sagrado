import "server-only";
import {sql} from "drizzle-orm";
import {getDb} from "@/lib/db";

export type WorkListItem={stableKey:string;title:string;description:string|null;status:string;tradition:string|null;witnessCount:number};
export type ReaderContent={representationType:string;textContent:string;normalizedText:string|null;sourceTitle:string|null;sourceUrl:string|null;notes:string|null};
export type ReaderVariant={unitKey:string;variantType:string;description:string|null;status:string;witnessLabel:string|null;readingText:string;normalizedText:string|null;notes:string|null;sourceTitle:string|null};
export type ReaderUnit={stableKey:string;label:string|null;unitType:string;pathKey:string|null;witnessLabel:string|null;translationTitle:string|null;contents:ReaderContent[];variants:ReaderVariant[]};
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
  getDb().execute(sql`
   SELECT DISTINCT e.stable_key AS "stableKey",tu.label,tu.unit_type AS "unitType",tu.path_key AS "pathKey",tu.ordinal AS "_ordinal",
          tw.title_or_label AS "witnessLabel",tr.title AS "translationTitle"
   FROM textual_units tu
   JOIN entities e ON e.id=tu.id
   LEFT JOIN textual_witnesses tw ON tw.id=tu.witness_id
   LEFT JOIN translations tr ON tr.id=tu.translation_id
   LEFT JOIN translation_sources ts ON ts.translation_id=tr.id
   LEFT JOIN textual_witnesses translation_witness ON translation_witness.id=ts.witness_id
   JOIN works w ON w.id=COALESCE(tw.work_id,translation_witness.work_id)
   JOIN entities we ON we.id=w.id
   WHERE we.stable_key=${stableKey}
   ORDER BY tu.ordinal NULLS LAST,tu.path_key;
  `),
  getDb().execute(sql`SELECT DISTINCT s.title,s.source_type AS "sourceType",s.author_text AS author,s.url,s.notes FROM sources s JOIN work_traditions wt ON wt.source_id=s.id JOIN entities e ON e.id=wt.work_id WHERE e.stable_key=${stableKey} ORDER BY s.title;`)
 ]);
 const work=(wr as unknown as WorkDetail[])[0]; if(!work)return null;
 const [cr,rr]=await Promise.all([
  getDb().execute(sql`
   SELECT u.stable_key AS "unitKey",tuc.representation_type AS "representationType",tuc.text_content AS "textContent",
          tuc.normalized_text AS "normalizedText",s.title AS "sourceTitle",s.url AS "sourceUrl",tuc.notes
   FROM textual_unit_contents tuc
   JOIN textual_units tu ON tu.id=tuc.textual_unit_id
   JOIN entities u ON u.id=tu.id
   LEFT JOIN textual_witnesses tw ON tw.id=tu.witness_id
   LEFT JOIN translations tr ON tr.id=tu.translation_id
   LEFT JOIN translation_sources ts ON ts.translation_id=tr.id
   LEFT JOIN textual_witnesses translation_witness ON translation_witness.id=ts.witness_id
   JOIN works w ON w.id=COALESCE(tw.work_id,translation_witness.work_id)
   JOIN entities we ON we.id=w.id
   LEFT JOIN sources s ON s.id=tuc.source_id
   WHERE we.stable_key=${stableKey}
   ORDER BY u.stable_key,tuc.representation_type;
  `),
  getDb().execute(sql`
   SELECT uv.stable_key AS "unitKey",tv.variant_type AS "variantType",tv.description,tv.status,
          tw.title_or_label AS "witnessLabel",tvr.reading_text AS "readingText",
          tvr.normalized_text AS "normalizedText",tvr.notes,s.title AS "sourceTitle"
   FROM textual_variant_readings tvr
   JOIN textual_variants tv ON tv.id=tvr.variant_id
   JOIN entities uv ON uv.id=tv.textual_unit_id
   JOIN textual_witnesses tw ON tw.id=tvr.witness_id
   LEFT JOIN textual_variant_reading_sources tvrs ON tvrs.reading_id=tvr.id
   LEFT JOIN sources s ON s.id=tvrs.source_id
   JOIN entities work_entity ON work_entity.id=tw.work_id
   WHERE work_entity.stable_key=${stableKey}
   ORDER BY uv.stable_key,tv.variant_type,tvr.reading_text,tw.title_or_label;
  `)
 ]);
 const contentRows=cr as unknown as Array<ReaderContent & {unitKey:string}>;
 const readingRows=rr as unknown as ReaderVariant[];
 const byUnit=new Map<string,ReaderContent[]>();
 for(const row of contentRows){const list=byUnit.get(row.unitKey)??[];list.push(row);byUnit.set(row.unitKey,list);}
 const variantByUnit=new Map<string,ReaderVariant[]>();
 for(const row of readingRows){const list=variantByUnit.get(row.unitKey)??[];list.push(row);variantByUnit.set(row.unitKey,list);}
 const baseUnits=un as unknown as Array<Omit<ReaderUnit,"contents"|"variants">>;
 return {...work,traditions:(tr as unknown as Array<{name:string}>).map(r=>r.name),dates:dr as unknown as WorkDetail["dates"],witnesses:wi as unknown as WorkDetail["witnesses"],units:baseUnits.map(u=>({...u,contents:byUnit.get(u.stableKey)??[],variants:variantByUnit.get(u.stableKey)??[]})),sources:sr as unknown as WorkDetail["sources"]};
}
