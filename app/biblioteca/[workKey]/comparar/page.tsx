import Link from "next/link";
import {notFound} from "next/navigation";
import {getWorkDetail, type ReaderUnit} from "@/lib/library";

export const dynamic="force-dynamic";

const representationLabels:Record<string,string>={
  original:"Original",
  critical_text:"Texto crítico",
  transliteration:"Transliteración",
  close_translation:"Traducción cercana",
  readable_translation:"Traducción legible"
};
const order=["original","critical_text","transliteration","close_translation","readable_translation"];

function ordered(unit:ReaderUnit){
  return [...unit.contents].sort((a,b)=>{
    const ai=order.indexOf(a.representationType),bi=order.indexOf(b.representationType);
    return (ai<0?99:ai)-(bi<0?99:bi);
  });
}

export default async function ComparePage({params}:{params:Promise<{workKey:string}>}){
  const {workKey}=await params;
  const work=await getWorkDetail(workKey);
  if(!work)notFound();

  return <main className="page">
    <Link className="back" href={"/biblioteca/"+workKey}>← {work.title}</Link>
    <header className="detail-header">
      <p className="eyebrow">Comparación textual</p>
      <h1>{work.title}</h1>
      <p className="lead">Aquí se ponen en paralelo las representaciones que la biblioteca tiene registradas para cada unidad. Una traducción no sustituye al original y una lectura de manuscrito no se convierte automáticamente en el texto de una edición.</p>
    </header>
    <div className="detail-grid">
      <section>
        <div className="panel">
          <h2>Unidades textuales</h2>
          {work.units.length===0?<div className="empty">No hay unidades textuales registradas.</div>:<div className="reader">
            {work.units.map(u=><article className="reader-unit" key={u.stableKey}>
              <div className="reader-heading">
                <div><span className="tag">Comparación</span><h3>{u.label??u.stableKey}</h3></div>
                <small>{u.witnessLabel??u.translationTitle??"Unidad editorial"}</small>
              </div>
              {u.contents.length===0?<div className="empty">No hay representaciones registradas para esta unidad.</div>:
                <div className="reader-content reader-parallel">{ordered(u).map(c=><div className="text-layer" key={c.representationType}>
                  <div className="text-layer-label">{representationLabels[c.representationType]??c.representationType}</div>
                  <p className={c.representationType==="original"||c.representationType==="critical_text"?"original-text":""}>{c.textContent}</p>
                  {c.sourceTitle?<small>Fuente: {c.sourceTitle}</small>:null}
                  {c.notes?<small>{c.notes}</small>:null}
                </div>)}</div>}
              {u.variants.length>0?<div className="variant-box"><h4>Lecturas variantes registradas</h4>{u.variants.map((v,i)=><div className="variant-reading" key={v.witnessLabel+"|"+v.readingText+"|"+i}><strong>{v.witnessLabel??"Testigo"}</strong><span>{v.readingText}</span>{v.sourceTitle?<small>Fuente: {v.sourceTitle}</small>:null}{v.notes?<small>{v.notes}</small>:null}</div>)}</div>:null}
            </article>)}
          </div>}
        </div>
      </section>
      <aside>
        <div className="panel">
          <h2>Qué se compara</h2>
          <dl className="metadata">
            <div><dt>Original</dt><dd>La representación conservada en el idioma del testimonio, cuando está registrada.</dd></div>
            <div><dt>Texto crítico</dt><dd>Una representación editorial basada en la evaluación de testimonios y variantes.</dd></div>
            <div><dt>Transliteración</dt><dd>Representación del texto en otro sistema de escritura.</dd></div>
            <div><dt>Traducción</dt><dd>Una representación en otra lengua; puede haber más de una.</dd></div>
            <div><dt>Variante</dt><dd>Una lectura documentada en un testimonio, separada de la selección editorial.</dd></div>
          </dl>
        </div>
        <div className="panel">
          <h2>Principio editorial</h2>
          <p className="lead">La biblioteca conserva juntas las distintas formas documentadas sin decidir de antemano que una lengua, manuscrito, edición o traducción sea la única forma válida.</p>
        </div>
      </aside>
    </div>
  </main>;
}
