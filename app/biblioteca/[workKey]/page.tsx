import Link from "next/link";
import {notFound} from "next/navigation";
import {getWorkDetail} from "@/lib/library";

export const dynamic="force-dynamic";

function year(y:number|null){if(y===null)return"—";return y<=0?String(Math.abs(y)+1)+" a. C.":String(y)+" d. C."}
const representationLabels:Record<string,string>={original:"Original",transliteration:"Transliteración",critical_text:"Texto crítico",close_translation:"Traducción cercana",readable_translation:"Traducción legible"};

export default async function WorkPage({params}:{params:Promise<{workKey:string}>}){
 const {workKey}=await params;
 const work=await getWorkDetail(workKey);
 if(!work)notFound();

 return <main className="page">
  <Link className="back" href="/biblioteca">← Biblioteca</Link>
  <header className="detail-header"><p className="eyebrow">Obra</p><h1>{work.title}</h1><p className="lead">{work.description}</p></header>
  <div className="detail-grid">
   <section>
    <div className="panel"><h2>Texto</h2><p className="lead">El lector separa el contenido textual de sus testigos, variantes y fuentes. Una representación sólo aparece cuando existe contenido registrado para esa unidad.</p>{work.units.length===0?<div className="empty">No hay unidades textuales registradas.</div>:<div className="reader">{work.units.map(u=><article className="reader-unit" key={u.stableKey}><div className="reader-heading"><div><span className="tag">{u.unitType}</span><h3>{u.label??u.stableKey}</h3></div><small>{u.witnessLabel??u.translationTitle??"Unidad editorial"}</small></div>{u.contents.length===0?<div className="empty">Contenido no registrado para esta unidad.</div>:<div className="reader-content">{u.contents.map(c=><div className="text-layer" key={c.representationType}><div className="text-layer-label">{representationLabels[c.representationType]??c.representationType}</div><p className={c.representationType==="original"||c.representationType==="critical_text"?"original-text":""}>{c.textContent}</p>{c.notes?<small>{c.notes}</small>:null}{c.sourceTitle?<small>Fuente: {c.sourceTitle}</small>:null}</div>)}</div>}{u.variants.length>0?<div className="variant-box"><h4>Comparación de variantes</h4>{Array.from(new Map(u.variants.map(v=>[v.variantType+"|"+(v.description??""),v])).values()).map(v=><div className="variant-group" key={v.variantType+"|"+(v.description??"")}><div className="text-layer-label">Variante: {v.variantType}</div>{v.description?<p>{v.description}</p>:null}<div className="variant-reading-list">{u.variants.filter(r=>r.variantType===v.variantType&&r.description===v.description).map((r,i)=><div className="variant-reading" key={r.witnessLabel+"|"+r.readingText+"|"+i}><strong>{r.witnessLabel??"Testigo"}</strong><span>{r.readingText}</span>{r.normalizedText?<small>Normalizado: {r.normalizedText}</small>:null}{r.sourceTitle?<small>Fuente: {r.sourceTitle}</small>:null}{r.notes?<small>{r.notes}</small>:null}</div>)}</div></div>)}</div>:null}</article>)}</div>}</div>
    <div className="panel"><h2>Testigos</h2>{work.witnesses.length===0?<div className="empty">No hay testigos registrados.</div>:<div className="unit-list">{work.witnesses.map(w=><div className="unit" key={w.stableKey}><h3>{w.label??w.stableKey}</h3><small>{w.type} · {w.language??"lengua no registrada"} · {w.script??"escritura no registrada"} · {w.dateNote??"fecha no registrada"}</small></div>)}</div>}</div>
   </section>
   <aside>
    <div className="panel"><h2>Ficha</h2><dl className="metadata"><div><dt>Estado</dt><dd>{work.status}</dd></div><div><dt>Tradiciones</dt><dd>{work.traditions.join(", ")||"—"}</dd></div><div><dt>Testigos</dt><dd>{work.witnessCount}</dd></div><div><dt>Datación</dt><dd>{work.dates.length?work.dates.map((d,i)=><div key={i}>{year(d.earliest)}–{year(d.latest)}{d.confidence?" · "+d.confidence:""}</div>):"No registrada"}</dd></div></dl></div>
    <div className="panel"><h2>Fuentes</h2>{work.sources.length===0?<div className="empty">No hay fuentes vinculadas todavía.</div>:<div className="source-list">{work.sources.map(s=><div className="source-item" key={s.title}><h3>{s.title}</h3><small>{s.author??"Autor no registrado"} · {s.sourceType}</small>{s.url?<p><a href={s.url} target="_blank" rel="noreferrer">Fuente externa</a></p>:null}</div>)}</div>}</div>
   </aside>
  </div>
 </main>
}
