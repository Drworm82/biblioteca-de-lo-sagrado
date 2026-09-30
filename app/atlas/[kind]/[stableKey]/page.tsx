import Link from "next/link";
import {notFound} from "next/navigation";
import {getAtlasDetail} from "@/lib/library";

export const dynamic="force-dynamic";

function year(y:number|null){
  if(y===null)return"—";
  return y<=0?String(Math.abs(y)+1)+" a. C.":String(y)+" d. C.";
}
function label(v:string,kind:string){
  const maps:Record<string,Record<string,string>>={
    status:{documented:"Documentado",proposed:"Propuesto",accepted:"Aceptado",rejected:"Rechazado"},
    evidenceType:{material:"Material",archaeological:"Arqueológica",textual:"Textual",linguistic:"Lingüística",geological:"Geológica",bioarchaeological:"Bioarqueológica"},
    eventType:{historical:"Histórico",political:"Político",religious:"Religioso",cultural:"Cultural",military:"Militar"},
    relation:{context:"Contexto",influence:"Influencia",dependence:"Dependencia",parallel:"Paralelo",reinterpretation:"Reinterpretación",syncretism:"Sincretismo"},
    sourceType:{critical_edition:"Edición crítica",textual_reference:"Referencia textual",editorial_translation:"Traducción editorial"}
  };
  return maps[kind]?.[v]??v
}
function range(a:number|null,b:number|null){
  if(a===null&&b===null)return"Fecha no registrada";
  if(a===b||b===null)return year(a);
  if(a===null)return year(b);
  return year(a)+"–"+year(b);
}

export default async function AtlasDetailPage({params}:{params:Promise<{kind:string;stableKey:string}>}){
  const {kind,stableKey}=await params;
  if(kind!=="evidencia"&&kind!=="acontecimiento")notFound();
  const detail=await getAtlasDetail(kind==="evidencia"?"evidence":"event",stableKey);
  if(!detail)notFound();

  const typeLabel=detail.kind==="evidence"?label(detail.type,"evidenceType"):label(detail.type,"eventType");

  return <main className="page">
    <Link className="back" href="/">← Cronología</Link>
    <header className="detail-header">
      <p className="eyebrow">{detail.kind==="evidence"?"Evidencia":"Acontecimiento histórico"}</p>
      <h1>{detail.title}</h1>
      <p className="lead">{detail.description}</p>
    </header>
    <div className="detail-grid">
      <section>
        <div className="panel">
          <h2>Registro</h2>
          <dl className="metadata">
            <div><dt>Tipo</dt><dd>{typeLabel}</dd></div>
            {detail.observation?<div><dt>Observación</dt><dd>{detail.observation}</dd></div>:null}
            {detail.notes?<div><dt>Notas</dt><dd>{detail.notes}</dd></div>:null}
            {detail.confidence?<div><dt>Confianza</dt><dd>{detail.confidence}</dd></div>:null}
          </dl>
        </div>
        <div className="panel">
          <h2>Datación</h2>
          {detail.dates.length===0?<div className="empty">No hay una datación registrada.</div>:<div className="unit-list">{detail.dates.map((d,i)=><div className="unit" key={i}><h3>{range(d.earliest,d.latest)}</h3><small>{[d.precision,d.method,d.confidence].filter(Boolean).join(" · ")||"Afirmación de datación"}</small>{d.notes?<p>{d.notes}</p>:null}</div>)}</div>}
          <p className="lead atlas-note">Las distintas afirmaciones de datación se conservan por separado. Una entrada de la cronología no implica que exista una única fecha aceptada.</p>
        </div>
        {detail.kind==="evidence" ? <div className="panel">
          <h2>Cadena de razonamiento</h2>
          <p className="lead atlas-note">La ficha separa lo observado de las afirmaciones, interpretaciones e hipótesis construidas a partir de la evidencia.</p>
          {detail.claims.length>0?<div className="unit-list"><h3>Afirmaciones</h3>{detail.claims.map(x=><div className="unit" key={"claim-"+x.stableKey}><small>Afirmación · {label(x.status,"status")}{x.confidence?" · "+x.confidence:""}</small><h3>{x.title}</h3><p>{x.statement}</p>{x.notes?<small>{x.notes}</small>:null}</div>)}</div>:null}
          {detail.interpretations.length>0?<div className="unit-list"><h3>Interpretaciones</h3>{detail.interpretations.map(x=><div className="unit" key={"interpretation-"+x.stableKey}><small>Interpretación · {label(x.status,"status")}{x.confidence?" · "+x.confidence:""}</small><h3>{x.title}</h3><p>{x.statement}</p>{x.notes?<small>{x.notes}</small>:null}</div>)}</div>:null}
          {detail.hypotheses.length>0?<div className="unit-list"><h3>Hipótesis</h3>{detail.hypotheses.map(x=><div className="unit" key={"hypothesis-"+x.stableKey}><small>Hipótesis · {label(x.status,"status")}{x.confidence?" · "+x.confidence:""}</small><h3>{x.title}</h3><p>{x.statement}</p>{x.notes?<small>{x.notes}</small>:null}</div>)}</div>:null}
          {detail.claims.length===0&&detail.interpretations.length===0&&detail.hypotheses.length===0?<div className="empty">Todavía no hay afirmaciones, interpretaciones o hipótesis vinculadas a esta evidencia.</div>:null}
        </div>:null}
        <div className="panel">
          <h2>Relaciones registradas</h2>
          {detail.relations.length===0?<div className="empty">No hay relaciones registradas todavía.</div>:<div className="unit-list">{detail.relations.map((r,i)=><div className="unit" key={r.stableKey+"|"+r.relation+"|"+i}><small>{r.direction==="hacia"?"Relación hacia":"Relación desde"} · {label(r.relation,"relation")}</small>{r.href?<Link href={r.href}><h3>{r.label} →</h3></Link>:<h3>{r.label}</h3>}<small>{[r.entityType,r.confidence,label(r.status,"status")].filter(Boolean).join(" · ")}</small>{r.notes?<p>{r.notes}</p>:null}</div>)}</div>}
        </div>
      </section>
      <aside>
        <div className="panel">
          <h2>Fuentes</h2>
          {detail.sources.length===0?<div className="empty">No hay fuentes vinculadas todavía.</div>:<div className="source-list">{detail.sources.map(s=><div className="source-item" key={s.title}><h3>{s.title}</h3><small>{s.author??"Autor no registrado"} · {label(s.sourceType,"sourceType")}</small>{s.notes?<p>{s.notes}</p>:null}{s.url?<p><a href={s.url} target="_blank" rel="noreferrer">Fuente externa</a></p>:null}</div>)}</div>}
        </div>
        <div className="panel">
          <h2>Lectura del registro</h2>
          <p className="lead">Esta ficha distingue el registro de evidencia o acontecimiento de las interpretaciones que puedan construirse a partir de él. La presencia de una evidencia no demuestra por sí sola una interpretación histórica o religiosa.</p>
        </div>
      </aside>
    </div>
  </main>;
}
