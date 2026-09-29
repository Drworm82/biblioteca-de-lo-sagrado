import Link from "next/link";
import {notFound} from "next/navigation";
import {getAtlasDetail} from "@/lib/library";

export const dynamic="force-dynamic";

function year(y:number|null){
  if(y===null)return"—";
  return y<=0?String(Math.abs(y)+1)+" a. C.":String(y)+" d. C.";
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
            <div><dt>Tipo</dt><dd>{detail.type}</dd></div>
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
        <div className="panel">
          <h2>Relaciones registradas</h2>
          {detail.related.length===0?<div className="empty">No hay relaciones registradas todavía.</div>:<div className="unit-list">{detail.related.map((r,i)=><div className="unit" key={r.stableKey+"|"+r.relation+"|"+i}><h3>{r.label}</h3><small>{r.relation}</small></div>)}</div>}
        </div>
      </section>
      <aside>
        <div className="panel">
          <h2>Fuentes</h2>
          {detail.sources.length===0?<div className="empty">No hay fuentes vinculadas todavía.</div>:<div className="source-list">{detail.sources.map(s=><div className="source-item" key={s.title}><h3>{s.title}</h3><small>{s.author??"Autor no registrado"} · {s.sourceType}</small>{s.notes?<p>{s.notes}</p>:null}{s.url?<p><a href={s.url} target="_blank" rel="noreferrer">Fuente externa</a></p>:null}</div>)}</div>}
        </div>
        <div className="panel">
          <h2>Lectura del registro</h2>
          <p className="lead">Esta ficha distingue el registro de evidencia o acontecimiento de las interpretaciones que puedan construirse a partir de él. La presencia de una evidencia no demuestra por sí sola una interpretación histórica o religiosa.</p>
        </div>
      </aside>
    </div>
  </main>;
}
