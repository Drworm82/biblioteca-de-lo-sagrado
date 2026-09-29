import Link from "next/link";
import {notFound} from "next/navigation";
import {getWorkDetail} from "@/lib/library";

export const dynamic="force-dynamic";

function year(y:number|null){if(y===null)return"—";return y<=0?String(Math.abs(y)+1)+" a. C.":String(y)+" d. C."}

export default async function WorkPage({params}:{params:Promise<{workKey:string}>}){
 const {workKey}=await params;
 const work=await getWorkDetail(workKey);
 if(!work)notFound();

 return <main className="page">
  <Link className="back" href="/biblioteca">← Biblioteca</Link>
  <header className="detail-header"><p className="eyebrow">Obra</p><h1>{work.title}</h1><p className="lead">{work.description}</p></header>
  <div className="detail-grid">
   <section>
    <div className="panel"><h2>Testigos</h2>{work.witnesses.length===0?<div className="empty">No hay testigos registrados.</div>:<div className="unit-list">{work.witnesses.map(w=><div className="unit" key={w.stableKey}><h3>{w.label??w.stableKey}</h3><small>{w.type} · {w.language??"lengua no registrada"} · {w.script??"escritura no registrada"} · {w.dateNote??"fecha no registrada"}</small></div>)}</div>}</div>
    <div className="panel"><h2>Texto y unidades</h2><p className="lead">Esta primera capa muestra las unidades textuales que el modelo ya conoce. El contenido textual completo se incorporará después; no se inventa texto donde el corpus sólo contiene metadatos.</p>{work.units.length===0?<div className="empty">No hay unidades textuales registradas.</div>:<div className="unit-list">{work.units.map(u=><div className="unit" key={u.stableKey}><h3>{u.label??u.stableKey}</h3><small>{u.unitType} · {u.pathKey??"sin ruta"}{u.witnessLabel?" · "+u.witnessLabel:""}{u.translationTitle?" · "+u.translationTitle:""}</small></div>)}</div>}</div>
   </section>
   <aside>
    <div className="panel"><h2>Ficha</h2><dl className="metadata"><div><dt>Estado</dt><dd>{work.status}</dd></div><div><dt>Tradiciones</dt><dd>{work.traditions.join(", ")||"—"}</dd></div><div><dt>Testigos</dt><dd>{work.witnessCount}</dd></div><div><dt>Datación</dt><dd>{work.dates.length?work.dates.map((d,i)=><div key={i}>{year(d.earliest)}–{year(d.latest)}{d.confidence?" · "+d.confidence:""}</div>):"No registrada"}</dd></div></dl></div>
    <div className="panel"><h2>Fuentes</h2>{work.sources.length===0?<div className="empty">No hay fuentes vinculadas todavía.</div>:<div className="source-list">{work.sources.map(s=><div className="source-item" key={s.title}><h3>{s.title}</h3><small>{s.author??"Autor no registrado"} · {s.sourceType}</small>{s.url?<p><a href={s.url} target="_blank" rel="noreferrer">Fuente externa</a></p>:null}</div>)}</div>}</div>
   </aside>
  </div>
 </main>
}