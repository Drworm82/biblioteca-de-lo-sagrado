import Link from "next/link";

const timeline = [
  {
    date: "c. 100.000 a.C.",
    type: "Evidencia",
    title: "Los primeros indicios de lo sagrado",
    text: "Enterramientos, pigmentos, objetos y otros comportamientos del Paleolítico permiten estudiar cómo las comunidades humanas trataban la muerte y los espacios especiales. La interpretación de estas evidencias permanece abierta.",
    meta: "Prehistoria · evidencia arqueológica",
  },
  {
    date: "c. 9600–8200 a.C.",
    type: "Arqueología",
    title: "Göbekli Tepe",
    text: "Un complejo monumental del Neolítico temprano con pilares decorados y espacios construidos. Es una ventana excepcional a la organización social y ritual de comunidades anteriores a la escritura.",
    meta: "Anatolia · Neolítico",
  },
  {
    date: "c. 3000–500 a.C.",
    type: "Tradiciones y textos",
    title: "Mesopotamia",
    text: "Himnos, plegarias, mitos y textos rituales conservan una de las tradiciones escritas más antiguas. Aquí aparecen corpus que más tarde podremos comparar con otras tradiciones del Cercano Oriente.",
    meta: "Sumer · Acad · Babilonia · Asiria",
  },
  {
    date: "c. 3000–30 a.C.",
    type: "Tradiciones y textos",
    title: "Egipto",
    text: "Los Textos de las Pirámides, Textos de los Sarcófagos, himnos y otros corpus muestran una tradición escrita desarrollada durante milenios, con transformaciones internas y múltiples contextos.",
    meta: "Valle del Nilo · escritura jeroglífica y hierática",
  },
  {
    date: "c. 1500–300 a.C.",
    type: "Tradiciones y textos",
    title: "Levante y mundo ugarítico",
    text: "Los textos del Levante permiten estudiar deidades, rituales y conceptos religiosos dentro de sus propios contextos lingüísticos e históricos, antes de establecer cualquier relación con tradiciones posteriores.",
    meta: "Canaán · Ugarit · lenguas semíticas",
  },
  {
    date: "c. 1500–300 a.C.",
    type: "Tradiciones y textos",
    title: "India védica y postvédica",
    text: "Los Vedas, Brahmanas, Aranyakas y Upanishads forman capas textuales de una larga tradición. Sus fechas de composición y transmisión deben distinguirse de las fechas de los manuscritos conservados.",
    meta: "India · sánscrito védico y sánscrito",
  },
  {
    date: "c. 800–300 a.C.",
    type: "Tradiciones y textos",
    title: "Grecia",
    text: "Homero, Hesíodo y los himnos transmiten distintas formas de pensamiento religioso griego. La comparación con otras culturas requiere distinguir paralelos, contacto e influencia demostrable.",
    meta: "Grecia arcaica y clásica",
  },
  {
    date: "c. 1200–900 a.C.",
    type: "Religión israelita antigua",
    title: "Los primeros israelitas",
    text: "La religión de los primeros grupos israelitas debe estudiarse dentro del paisaje religioso del Levante. Inscripciones, asentamientos, objetos y textos posteriores permiten reconstruir un panorama que no debe proyectarse automáticamente desde el monoteísmo judío posterior.",
    meta: "Canaán · primeros reinos y comunidades israelitas",
  },
  {
    date: "c. 1000–586 a.C.",
    type: "Religión israelita antigua",
    title: "Israel y Judá",
    text: "Durante las monarquías de Israel y Judá coexistieron distintas prácticas, santuarios y concepciones sobre lo divino. La evidencia textual y arqueológica permite estudiar procesos de centralización, reforma y transformación religiosa.",
    meta: "Reinos de Israel y Judá · Jerusalén · santuarios locales",
  },
  {
    date: "586–332 a.C.",
    type: "Transformación religiosa",
    title: "Exilio, retorno y período persa",
    text: "La destrucción de Jerusalén y el exilio babilónico forman parte de una etapa decisiva de transformación. El período posterior muestra la reorganización de comunidades y tradiciones que desembocará en el diverso mundo del judaísmo del Segundo Templo.",
    meta: "Babilonia · Yehud · período persa",
  },
  {
    date: "siglos II a.C.–I d.C.",
    type: "Corpus",
    title: "Judaísmo del Segundo Templo",
    text: "Biblia hebrea, literatura sapiencial, apocalíptica, Qumrán y otros textos muestran un panorama diverso en el que se desarrollan y reinterpretan tradiciones anteriores.",
    meta: "Judea · Qumrán · Mediterráneo oriental",
  },
  {
    date: "siglo I d.C.",
    type: "Corpus",
    title: "Cristianismos antiguos",
    text: "Los textos cristianos surgen dentro de un mundo judío y grecorromano. Los manuscritos, traducciones y comunidades posteriores permiten seguir cómo se transmitieron y reinterpretaron.",
    meta: "Mediterráneo oriental · griego, arameo, copto y latín",
  },
];

export default function HomePage() {
  return (
    <main className="timeline-page">
      <header className="timeline-hero">
        <p className="eyebrow">Biblioteca de lo Sagrado</p>
        <h1>Primero el texto.<br />Después su contexto.</h1>
        <p className="lead">
          Un recorrido cronológico por textos, testimonios y evidencias de las
          tradiciones religiosas humanas. La biblioteca no establece un canon:
          reúne fuentes y deja visibles sus diferencias.
        </p>
        <Link className="timeline-entry" href="/biblioteca">
          Explorar la biblioteca <span aria-hidden="true">↓</span>
        </Link>
      </header>

      <section className="timeline" aria-label="Recorrido cronológico">
        <div className="timeline-axis" aria-hidden="true" />
        {timeline.map((item, index) => (
          <article className={`timeline-item ${index % 2 === 0 ? "timeline-left" : "timeline-right"}`} key={item.title}>
            <div className="timeline-node" aria-hidden="true" />
            <div className="timeline-date">{item.date}</div>
            <div className="timeline-card">
              <p className="timeline-type">{item.type}</p>
              <h2>{item.title}</h2>
              <p>{item.text}</p>
              <small>{item.meta}</small>
            </div>
          </article>
        ))}
      </section>

      <footer className="timeline-footer">
        <p className="eyebrow">El recorrido continúa</p>
        <h2>Un texto lleva a otro.</h2>
        <p>
          La cronología será progresivamente alimentada por las obras,
          manuscritos, lugares, fuentes y relaciones de la biblioteca.
        </p>
        <Link className="timeline-entry" href="/biblioteca">
          Entrar a la biblioteca <span aria-hidden="true">→</span>
        </Link>
      </footer>
    </main>
  );
}
