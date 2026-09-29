import "server-only";
import {createClient} from "@supabase/supabase-js";

function getSupabase(){
  const url=process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if(!url||!key) throw new Error("Supabase is not configured.");
  return createClient(url,key,{auth:{persistSession:false,autoRefreshToken:false,detectSessionInUrl:false}});
}

async function read<T=any>(query:PromiseLike<{data:T|null;error:any}>):Promise<T>{
  const {data,error}=await query;
  if(error) throw new Error(`Supabase query failed: ${error.message}`);
  return (data??[]) as T;
}

async function readIn<T=any>(table:string,column:string,ids:string[]):Promise<T[]>{
  if(ids.length===0)return [];
  return read<T[]>(getSupabase().from(table).select("*").in(column,ids));
}

export type WorkListItem={stableKey:string;title:string;description:string|null;status:string;tradition:string|null;witnessCount:number};
export type ReaderContent={representationType:string;textContent:string;normalizedText:string|null;sourceTitle:string|null;sourceUrl:string|null;notes:string|null};
export type ReaderVariant={unitKey:string;variantType:string;description:string|null;status:string;witnessLabel:string|null;readingText:string;normalizedText:string|null;notes:string|null;sourceTitle:string|null};
export type ReaderUnit={stableKey:string;label:string|null;unitType:string;pathKey:string|null;witnessLabel:string|null;translationTitle:string|null;contents:ReaderContent[];variants:ReaderVariant[]};
export type WorkDetail=WorkListItem&{workId:string;traditions:string[];dates:Array<{earliest:number|null;latest:number|null;precision:string|null;method:string|null;confidence:string|null;notes:string|null}>;witnesses:Array<{stableKey:string;label:string|null;type:string;language:string|null;script:string|null;dateNote:string|null}>;units:ReaderUnit[];sources:Array<{title:string;sourceType:string;author:string|null;url:string|null;notes:string|null}>};

export async function listWorks():Promise<WorkListItem[]>{
  const supabase=getSupabase();
  const [works,entities,links]=await Promise.all([
    read<any[]>(supabase.from("works").select("id,title,description,status").order("title")),
    read<any[]>(supabase.from("entities").select("id,stable_key").eq("entity_type","work")),
    read<any[]>(supabase.from("work_traditions").select("work_id,tradition_id"))
  ]);
  const workIds=works.map(w=>w.id);
  const [traditions,witnesses]=await Promise.all([
    read<any[]>(supabase.from("traditions").select("id,name")),
    readIn<any>("textual_witnesses","work_id",workIds)
  ]);
  const entityById=new Map(entities.map(e=>[e.id,e.stable_key]));
  const traditionById=new Map(traditions.map(t=>[t.id,t.name]));
  const linksByWork=new Map<string,string[]>();
  for(const l of links){const a=linksByWork.get(l.work_id)??[];const n=traditionById.get(l.tradition_id);if(n)a.push(n);linksByWork.set(l.work_id,a);}
  const witnessCount=new Map<string,number>();
  for(const w of witnesses)witnessCount.set(w.work_id,(witnessCount.get(w.work_id)??0)+1);
  return works.map(w=>({stableKey:entityById.get(w.id)??w.id,title:w.title,description:w.description,status:w.status,tradition:linksByWork.get(w.id)?.[0]??null,witnessCount:witnessCount.get(w.id)??0}));
}

export async function getWorkDetail(stableKey:string):Promise<WorkDetail|null>{
  const supabase=getSupabase();
  const [entities]=await Promise.all([
    read<any[]>(supabase.from("entities").select("id,stable_key").eq("entity_type","work").eq("stable_key",stableKey).limit(1))
  ]);
  const entity=entities[0];
  if(!entity)return null;
  const workId=entity.id;
  const workRows=await read<any[]>(supabase.from("works").select("id,title,description,status").eq("id",workId).limit(1));
  const work=workRows[0];
  if(!work)return null;

  const [tradLinks,witnesses,dates,units,sourceLinks]=await Promise.all([
    read<any[]>(supabase.from("work_traditions").select("tradition_id,source_id").eq("work_id",workId)),
    read<any[]>(supabase.from("textual_witnesses").select("id,title_or_label,witness_type,language_id,script_id,date_note").eq("work_id",workId).order("title_or_label")),
    read<any[]>(supabase.from("dating_assertions").select("earliest,latest,precision,dating_method,confidence_id,notes").eq("entity_id",workId).order("earliest")),
    read<any[]>(supabase.from("textual_units").select("id,witness_id,translation_id,unit_type,label,ordinal,path_key").order("ordinal",{ascending:true,nullsFirst:false}).order("path_key")),
    read<any[]>(supabase.from("work_traditions").select("source_id").eq("work_id",workId).not("source_id","is",null))
  ]);

  const witnessIds=witnesses.map(w=>w.id);
  const witnessUnitRows=await readIn<any>("textual_units","witness_id",witnessIds);
  const translationIds=[...new Set(units.filter(u=>u.translation_id).map(u=>u.translation_id))];
  const [traditions,languages,scripts,confidence,translations,translationSources,editionWitnesses,unitEntities]=await Promise.all([
    readIn<any>("traditions","id",tradLinks.map(x=>x.tradition_id)),
    readIn<any>("languages","id",witnesses.map(w=>w.language_id).filter(Boolean)),
    readIn<any>("scripts","id",witnesses.map(w=>w.script_id).filter(Boolean)),
    readIn<any>("confidence_levels","id",dates.map(d=>d.confidence_id).filter(Boolean)),
    readIn<any>("translations","id",translationIds),
    readIn<any>("translation_sources","translation_id",translationIds),
    readIn<any>("edition_witnesses","witness_id",witnessIds),
    readIn<any>("entities","id",[...new Set([...witnessIds,...units.map(u=>u.id)])])
  ]);

  const relevantTranslationIds=new Set(
    translationSources
      .filter(ts=>witnessIds.includes(ts.witness_id) || editionWitnesses.some(ew=>ew.edition_id===ts.edition_id && witnessIds.includes(ew.witness_id)))
      .map(ts=>ts.translation_id)
  );
  const readerUnits=[...witnessUnitRows,...units.filter(u=>u.translation_id&&relevantTranslationIds.has(u.translation_id))];
  const unitIds=[...new Set(readerUnits.map(u=>u.id))];
  const [contents,variants]=await Promise.all([
    readIn<any>("textual_unit_contents","textual_unit_id",unitIds),
    readIn<any>("textual_variants","textual_unit_id",witnessUnitRows.map(u=>u.id))
  ]);
  const readings=await readIn<any>("textual_variant_readings","variant_id",variants.map(v=>v.id));
  const readingSources=await readIn<any>("textual_variant_reading_sources","reading_id",readings.map(r=>r.id));
  const sourceIds=[...new Set([
    ...sourceLinks.map(x=>x.source_id).filter(Boolean),
    ...contents.map(c=>c.source_id).filter(Boolean),
    ...readingSources.map(x=>x.source_id).filter(Boolean)
  ])];
  const sources=await readIn<any>("sources","id",sourceIds);

  const entityById=new Map(unitEntities.map(e=>[e.id,e.stable_key]));
  const sourceById=new Map(sources.map(s=>[s.id,s]));
  const languageById=new Map(languages.map(x=>[x.id,x.name]));
  const scriptById=new Map(scripts.map(x=>[x.id,x.name]));
  const confidenceById=new Map(confidence.map(x=>[x.id,x.label]));
  const witnessById=new Map(witnesses.map(w=>[w.id,w]));
  const translationById=new Map(translations.map(t=>[t.id,t]));
  const contentByUnit=new Map<string,any[]>();
  for(const c of contents){const a=contentByUnit.get(c.textual_unit_id)??[];a.push(c);contentByUnit.set(c.textual_unit_id,a);}
  const variantMap=new Map(variants.map(v=>[v.id,v]));
  const sourceByReading=new Map<string,string>();
  for(const rs of readingSources){const s=sourceById.get(rs.source_id);if(s)sourceByReading.set(rs.reading_id,s.title);}
  const variantByUnit=new Map<string,any[]>();
  for(const r of readings){
    const v=variantMap.get(r.variant_id);
    if(!v)continue;
    const a=variantByUnit.get(v.textual_unit_id)??[];
    a.push({variant:v,reading:r,sourceTitle:sourceByReading.get(r.id)??null});
    variantByUnit.set(v.textual_unit_id,a);
  }

  const unitsOut:ReaderUnit[]=readerUnits
    .sort((a,b)=>(a.ordinal??999999)-(b.ordinal??999999))
    .map(u=>{
      const witness=u.witness_id?witnessById.get(u.witness_id):null;
      const translation=u.translation_id?translationById.get(u.translation_id):null;
      return {
        stableKey:entityById.get(u.id)??u.id,
        label:u.label,
        unitType:u.unit_type,
        pathKey:u.path_key,
        witnessLabel:witness?.title_or_label??null,
        translationTitle:translation?.title??null,
        contents:(contentByUnit.get(u.id)??[]).map(c=>({
          representationType:c.representation_type,
          textContent:c.text_content,
          normalizedText:c.normalized_text,
          sourceTitle:c.source_id?sourceById.get(c.source_id)?.title??null:null,
          sourceUrl:c.source_id?sourceById.get(c.source_id)?.url??null:null,
          notes:c.notes
        })),
        variants:(variantByUnit.get(u.id)??[]).map(x=>({
          unitKey:entityById.get(u.id)??u.id,
          variantType:x.variant.variant_type,
          description:x.variant.description,
          status:x.variant.status,
          witnessLabel:witnessById.get(x.reading.witness_id)?.title_or_label??null,
          readingText:x.reading.reading_text,
          normalizedText:x.reading.normalized_text,
          notes:x.reading.notes,
          sourceTitle:x.sourceTitle
        }))
      };
    });

  return {
    stableKey,
    title:work.title,
    description:work.description,
    status:work.status,
    tradition:traditions[0]?.name??null,
    witnessCount:witnesses.length,
    workId,
    traditions:traditions.map(t=>t.name),
    dates:dates.map(d=>({earliest:d.earliest,latest:d.latest,precision:d.precision,method:d.dating_method,confidence:confidenceById.get(d.confidence_id)??null,notes:d.notes})),
    witnesses:witnesses.map(w=>({stableKey:entityById.get(w.id)??w.id,label:w.title_or_label,type:w.witness_type,language:languageById.get(w.language_id)??null,script:scriptById.get(w.script_id)??null,dateNote:w.date_note})),
    units:unitsOut,
    sources:sources.filter(s=>sourceLinks.some(x=>x.source_id===s.id)).map(s=>({title:s.title,sourceType:s.source_type,author:s.author_text,url:s.url,notes:s.notes}))
  };
}
