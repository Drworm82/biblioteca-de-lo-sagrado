import "server-only";

function config(){
  const url=process.env.NEXT_PUBLIC_SUPABASE_URL||"https://ykvtnpjxgpebjiuwbmsw.supabase.co";
  const key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY||"sb_publishable_2aZltTkDF1I91aK-Ly2usA_3VWP_WC9";
  return {url,key};
}

async function query<T=any>(table:string,params:Record<string,string|undefined>={}):Promise<T[]>{
  const c=config();
  const url=new URL(c.url+"/rest/v1/"+table);
  for(const [key,value] of Object.entries(params))if(value!==undefined)url.searchParams.set(key,value);
  const r=await fetch(url,{headers:{apikey:c.key,Authorization:"Bearer "+c.key},cache:"no-store"});
  if(!r.ok)throw new Error("Supabase query failed ("+r.status+"): "+await r.text());
  return await r.json() as T[];
}

function list(ids:string[]){return ids.length?"("+ids.join(",")+")":"";}

export type WorkListItem={stableKey:string;title:string;description:string|null;status:string;tradition:string|null;witnessCount:number};
export type ReaderContent={representationType:string;textContent:string;normalizedText:string|null;sourceTitle:string|null;sourceUrl:string|null;notes:string|null};
export type ReaderVariant={unitKey:string;variantType:string;description:string|null;status:string;witnessLabel:string|null;readingText:string;normalizedText:string|null;notes:string|null;sourceTitle:string|null};
export type ReaderUnit={stableKey:string;label:string|null;unitType:string;pathKey:string|null;witnessLabel:string|null;translationTitle:string|null;contents:ReaderContent[];variants:ReaderVariant[]};
export type WorkDetail=WorkListItem&{workId:string;traditions:string[];dates:Array<{earliest:number|null;latest:number|null;precision:string|null;method:string|null;confidence:string|null;notes:string|null}>;witnesses:Array<{stableKey:string;label:string|null;type:string;language:string|null;script:string|null;dateNote:string|null}>;units:ReaderUnit[];sources:Array<{title:string;sourceType:string;author:string|null;url:string|null;notes:string|null}>};

export async function listWorks():Promise<WorkListItem[]>{
  const [works,entities,links,traditions,witnesses]=await Promise.all([
    query<any>("works",{select:"id,title,description,status",order:"title.asc"}),
    query<any>("entities",{select:"id,stable_key",entity_type:"eq.work"}),
    query<any>("work_traditions",{select:"work_id,tradition_id"}),
    query<any>("traditions",{select:"id,name"}),
    query<any>("textual_witnesses",{select:"id,work_id"})
  ]);
  const entityById=new Map(entities.map(e=>[e.id,e.stable_key]));
  const traditionById=new Map(traditions.map(t=>[t.id,t.name]));
  const linksByWork=new Map<string,string[]>();
  for(const l of links){const n=traditionById.get(l.tradition_id);if(n){const a=linksByWork.get(l.work_id)||[];a.push(n);linksByWork.set(l.work_id,a);}}
  const counts=new Map<string,number>();
  for(const w of witnesses)counts.set(w.work_id,(counts.get(w.work_id)||0)+1);
  return works.map(w=>({stableKey:entityById.get(w.id)||w.id,title:w.title,description:w.description,status:w.status,tradition:linksByWork.get(w.id)?.[0]||null,witnessCount:counts.get(w.id)||0}));
}

export type TimelineDating = {
  stableKey:string;
  title:string;
  tradition:string|null;
  earliest:number|null;
  latest:number|null;
  precision:string|null;
  method:string|null;
  confidence:string|null;
  notes:string|null;
  category:"evidence"|"archaeology"|"tradition"|"corpus"|"event";
};

export async function listTimelineWorks():Promise<TimelineDating[]>{
  const [works,entities,links,traditions,dates,confidence]=await Promise.all([
    query<any>("works",{select:"id,title",order:"title.asc"}),
    query<any>("entities",{select:"id,stable_key"}),
    query<any>("work_traditions",{select:"work_id,tradition_id"}),
    query<any>("traditions",{select:"id,name"}),
    query<any>("dating_assertions",{select:"id,entity_id,earliest,latest,precision,dating_method,confidence_id,notes",order:"earliest.asc.nullslast"}),
    query<any>("confidence_levels",{select:"id,label"})
  ]);
  const entityById=new Map(entities.map(e=>[e.id,e.stable_key]));
  const workById=new Map(works.map(w=>[w.id,w]));
  const traditionById=new Map(traditions.map(t=>[t.id,t.name]));
  const confidenceById=new Map(confidence.map(c=>[c.id,c.label]));
  const traditionsByWork=new Map<string,string[]>();
  for(const link of links){
    const name=traditionById.get(link.tradition_id);
    if(name)traditionsByWork.set(link.work_id,[...(traditionsByWork.get(link.work_id)||[]),name]);
  }
  const result:TimelineDating[]=[];
  for(const date of dates){
    const work=workById.get(date.entity_id);
    if(!work || (date.earliest==null && date.latest==null))continue;
    result.push({
      stableKey:entityById.get(work.id)||work.id,title:work.title,
      tradition:traditionsByWork.get(work.id)?.[0]||null,
      earliest:date.earliest??null,latest:date.latest??null,
      precision:date.precision??null,method:date.dating_method??null,
      confidence:confidenceById.get(date.confidence_id)||null,notes:date.notes??null,
      category:"corpus"
    });
  }
  return result.sort((a,b)=>(a.earliest??a.latest??Infinity)-(b.earliest??b.latest??Infinity));
}

export async function listTimelineItems():Promise<TimelineDating[]>{
  const [works,entities,workLinks,traditions,dates,confidence,evidence,events]=await Promise.all([
    query<any>("works",{select:"id,title",order:"title.asc"}),
    query<any>("entities",{select:"id,stable_key"}),
    query<any>("work_traditions",{select:"work_id,tradition_id"}),
    query<any>("traditions",{select:"id,name"}),
    query<any>("dating_assertions",{select:"id,entity_id,earliest,latest,precision,dating_method,confidence_id,notes",order:"earliest.asc.nullslast"}),
    query<any>("confidence_levels",{select:"id,label"}),
    query<any>("evidence",{select:"id,evidence_type,description"}),
    query<any>("historical_events",{select:"id,title,event_type,description"})
  ]);
  const entityById=new Map(entities.map(e=>[e.id,e.stable_key]));
  const workById=new Map(works.map(w=>[w.id,w]));
  const evidenceById=new Map(evidence.map(e=>[e.id,e]));
  const eventById=new Map(events.map(e=>[e.id,e]));
  const traditionById=new Map(traditions.map(t=>[t.id,t.name]));
  const confidenceById=new Map(confidence.map(c=>[c.id,c.label]));
  const traditionsByWork=new Map<string,string[]>();
  for(const link of workLinks){
    const name=traditionById.get(link.tradition_id);
    if(name)traditionsByWork.set(link.work_id,[...(traditionsByWork.get(link.work_id)||[]),name]);
  }
  const result:TimelineDating[]=[];
  for(const date of dates){
    if(date.earliest==null && date.latest==null)continue;
    const work=workById.get(date.entity_id);
    if(work){
      result.push({
        stableKey:entityById.get(work.id)||work.id,title:work.title,
        tradition:traditionsByWork.get(work.id)?.[0]||null,
        earliest:date.earliest??null,latest:date.latest??null,
        precision:date.precision??null,method:date.dating_method??null,
        confidence:confidenceById.get(date.confidence_id)||null,notes:date.notes??null,
        category:"corpus"
      });
      continue;
    }
    const ev=evidenceById.get(date.entity_id);
    if(ev){
      result.push({
        stableKey:entityById.get(ev.id)||ev.id,title:ev.description,
        tradition:null,earliest:date.earliest??null,latest:date.latest??null,
        precision:date.precision??null,method:date.dating_method??null,
        confidence:confidenceById.get(date.confidence_id)||null,notes:date.notes??null,
        category:"evidence"
      });
      continue;
    }
    const event=eventById.get(date.entity_id);
    if(event){
      result.push({
        stableKey:entityById.get(event.id)||event.id,title:event.title,
        tradition:null,earliest:date.earliest??null,latest:date.latest??null,
        precision:date.precision??null,method:date.dating_method??null,
        confidence:confidenceById.get(date.confidence_id)||null,notes:date.notes??null,
        category:"event"
      });
    }
  }
  return result.sort((a,b)=>(a.earliest??a.latest??Infinity)-(b.earliest??b.latest??Infinity));
}

export async function getWorkDetail(stableKey:string):Promise<WorkDetail|null>{
  const found=await query<any>("entities",{select:"id,stable_key",entity_type:"eq.work",stable_key:"eq."+stableKey,limit:"1"});
  if(!found[0])return null;
  const workId=found[0].id;
  const [works,tradLinks,witnesses,dates,units,traditions,languages,scripts,confidence,translationSources,editionWitnesses,allUnitEntities]=await Promise.all([
    query<any>("works",{select:"id,title,description,status",id:"eq."+workId,limit:"1"}),
    query<any>("work_traditions",{select:"tradition_id,source_id",work_id:"eq."+workId}),
    query<any>("textual_witnesses",{select:"id,title_or_label,witness_type,language_id,script_id,date_note",work_id:"eq."+workId,order:"title_or_label.asc"}),
    query<any>("dating_assertions",{select:"earliest,latest,precision,dating_method,confidence_id,notes",entity_id:"eq."+workId,order:"earliest.asc"}),
    query<any>("textual_units",{select:"id,witness_id,translation_id,unit_type,label,ordinal,path_key",order:"ordinal.asc.nullslast,path_key.asc"}),
    query<any>("traditions",{select:"id,name"}),
    query<any>("languages",{select:"id,name"}),
    query<any>("scripts",{select:"id,name"}),
    query<any>("confidence_levels",{select:"id,label"}),
    query<any>("translation_sources",{select:"translation_id,edition_id,witness_id,source_type,notes"}),
    query<any>("edition_witnesses",{select:"edition_id,witness_id"}),
    query<any>("entities",{select:"id,stable_key"})
  ]);
  const work=works[0];if(!work)return null;
  const witnessIds=witnesses.map(w=>w.id);
  const witnessUnits=units.filter(u=>witnessIds.includes(u.witness_id));
  const relevantTranslations=[...new Set(translationSources.filter(ts=>witnessIds.includes(ts.witness_id)||editionWitnesses.some(ew=>ew.edition_id===ts.edition_id&&witnessIds.includes(ew.witness_id))).map(ts=>ts.translation_id))];
  const readerUnits=[...witnessUnits,...units.filter(u=>u.translation_id&&relevantTranslations.includes(u.translation_id))];
  const unitIds=[...new Set(readerUnits.map(u=>u.id))];
  const [translations,contents,variants]=await Promise.all([
    relevantTranslations.length?query<any>("translations",{select:"id,title",id:"in."+list(relevantTranslations)}):Promise.resolve([]),
    unitIds.length?query<any>("textual_unit_contents",{select:"textual_unit_id,representation_type,text_content,normalized_text,source_id,notes",textual_unit_id:"in."+list(unitIds)}):Promise.resolve([]),
    witnessUnits.length?query<any>("textual_variants",{select:"id,textual_unit_id,variant_type,description,status",textual_unit_id:"in."+list(witnessUnits.map(u=>u.id))}):Promise.resolve([])
  ]);
  const readings=variants.length?await query<any>("textual_variant_readings",{select:"id,variant_id,witness_id,reading_text,normalized_text,notes",variant_id:"in."+list(variants.map(v=>v.id))}):[];
  const readingSources=readings.length?await query<any>("textual_variant_reading_sources",{select:"reading_id,source_id",reading_id:"in."+list(readings.map(r=>r.id))}):[];
  const sourceIds=[...new Set([...tradLinks.map(x=>x.source_id),...contents.map(x=>x.source_id),...readingSources.map(x=>x.source_id)].filter(Boolean))];
  const sources=sourceIds.length?await query<any>("sources",{select:"id,title,source_type,author_text,url,notes",id:"in."+list(sourceIds)}):[];
  const entityById=new Map(allUnitEntities.map(e=>[e.id,e.stable_key]));
  const witnessById=new Map(witnesses.map(w=>[w.id,w]));
  const translationById=new Map(translations.map(t=>[t.id,t]));
  const languageById=new Map(languages.map(x=>[x.id,x.name]));
  const scriptById=new Map(scripts.map(x=>[x.id,x.name]));
  const confidenceById=new Map(confidence.map(x=>[x.id,x.label]));
  const sourceById=new Map(sources.map(s=>[s.id,s]));
  const contentByUnit=new Map<string,any[]>();
  for(const c of contents){const a=contentByUnit.get(c.textual_unit_id)||[];a.push(c);contentByUnit.set(c.textual_unit_id,a);}
  const variantById=new Map(variants.map(v=>[v.id,v]));
  const readingSource=new Map(readingSources.map(x=>[x.reading_id,sourceById.get(x.source_id)?.title||null]));
  const variantsByUnit=new Map<string,any[]>();
  for(const r of readings){const v=variantById.get(r.variant_id);if(!v)continue;const a=variantsByUnit.get(v.textual_unit_id)||[];a.push({variant:v,reading:r,sourceTitle:readingSource.get(r.id)||null});variantsByUnit.set(v.textual_unit_id,a);}
  const unitsOut:ReaderUnit[]=readerUnits.sort((a,b)=>(a.ordinal??999999)-(b.ordinal??999999)).map(u=>{
    const w=u.witness_id?witnessById.get(u.witness_id):null;
    const t=u.translation_id?translationById.get(u.translation_id):null;
    return {stableKey:entityById.get(u.id)||u.id,label:u.label,unitType:u.unit_type,pathKey:u.path_key,witnessLabel:w?.title_or_label||null,translationTitle:t?.title||null,contents:(contentByUnit.get(u.id)||[]).map(c=>({representationType:c.representation_type,textContent:c.text_content,normalizedText:c.normalized_text,sourceTitle:c.source_id?sourceById.get(c.source_id)?.title||null:null,sourceUrl:c.source_id?sourceById.get(c.source_id)?.url||null:null,notes:c.notes})),variants:(variantsByUnit.get(u.id)||[]).map(x=>({unitKey:entityById.get(u.id)||u.id,variantType:x.variant.variant_type,description:x.variant.description,status:x.variant.status,witnessLabel:witnessById.get(x.reading.witness_id)?.title_or_label||null,readingText:x.reading.reading_text,normalizedText:x.reading.normalized_text,notes:x.reading.notes,sourceTitle:x.sourceTitle}))};
  });
  const workTraditionIds=new Set(tradLinks.map(x=>x.tradition_id));
  return {stableKey,title:work.title,description:work.description,status:work.status,tradition:traditions.find(t=>workTraditionIds.has(t.id))?.name||null,witnessCount:witnesses.length,workId,traditions:traditions.filter(t=>workTraditionIds.has(t.id)).map(t=>t.name),dates:dates.map(d=>({earliest:d.earliest,latest:d.latest,precision:d.precision,method:d.dating_method,confidence:confidenceById.get(d.confidence_id)||null,notes:d.notes})),witnesses:witnesses.map(w=>({stableKey:entityById.get(w.id)||w.id,label:w.title_or_label,type:w.witness_type,language:languageById.get(w.language_id)||null,script:scriptById.get(w.script_id)||null,dateNote:w.date_note})),units:unitsOut,sources:sources.filter(s=>tradLinks.some(x=>x.source_id===s.id)).map(s=>({title:s.title,sourceType:s.source_type,author:s.author_text,url:s.url,notes:s.notes}))};
}
