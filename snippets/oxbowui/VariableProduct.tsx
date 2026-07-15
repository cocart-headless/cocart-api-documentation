export const VariableProduct = () => {
  const product = {
    name: 'Nike Air Force 1\u00b407 Fresh',
    price: '190',
    description: 'Hitting the field in the late \'60s, adidas Air Force quickly became soccer\'s "it" shoe.',
    images: [
      'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=600&h=600&fit=crop',
      'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600&h=600&fit=crop',
      'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=600&h=600&fit=crop',
      'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?w=600&h=600&fit=crop',
    ],
    colors: [
      { name: 'Black', color: '#52525b' },
      { name: 'Gray', color: '#d4d4d8' },
      { name: 'Red', color: '#fca5a5' },
      { name: 'Blue', color: '#93c5fd' },
    ],
    sizes: ['6', '7', '8', '9', '10', '11', '12', '13'],
  };

  const [activeImage, setActiveImage] = useState(0);
  const [activeColor, setActiveColor] = useState<string | null>(null);
  const [activeSize, setActiveSize] = useState<string | null>(null);

  const buttonBase = {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontWeight: 500,
    fontSize: '0.875rem',
    borderRadius: '0.375rem',
    height: '2.25rem',
    padding: '0 1rem',
    cursor: 'pointer',
    flex: 1,
    transition: 'background-color 0.2s',
  };

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
      {/* Image gallery */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
        <div style={{ overflow: 'hidden', aspectRatio: '1', backgroundColor: '#e4e4e7', borderRadius: '1rem' }}>
          <img
            src={product.images[activeImage]}
            alt={product.name}
            style={{ objectFit: 'cover', width: '100%', height: '100%' }}
          />
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '0.5rem' }}>
          {product.images.map((image, index) => (
            <button
              key={index}
              onClick={() => setActiveImage(index)}
              style={{
                overflow: 'hidden',
                aspectRatio: '1',
                backgroundColor: '#e4e4e7',
                borderRadius: '0.75rem',
                border: activeImage === index ? '2px solid #18181b' : '2px solid transparent',
                padding: 0,
                cursor: 'pointer',
              }}
            >
              <img
                src={image}
                alt="Thumbnail"
                style={{ objectFit: 'cover', width: '100%', height: '100%' }}
              />
            </button>
          ))}
        </div>
      </div>

      {/* Product details */}
      <div style={{ display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <h3 style={{ fontSize: '1.25rem', fontWeight: 500, margin: 0 }}>{product.name}</h3>
          <span>${product.price}</span>
        </div>

        <p style={{ fontSize: '0.875rem', color: '#71717a', marginTop: '1rem' }}>
          {product.description}
        </p>

        {/* Color selector */}
        <div style={{ marginTop: '1.5rem' }}>
          <p style={{ fontSize: '0.75rem', textTransform: 'uppercase', color: '#71717a', margin: '0 0 0.5rem' }}>
            Color{activeColor ? `: ${activeColor}` : ''}
          </p>
          <div style={{ display: 'flex', gap: '0.75rem' }}>
            {product.colors.map((c) => (
              <button
                key={c.name}
                onClick={() => setActiveColor(c.name)}
                aria-label={c.name}
                style={{
                  width: '1.75rem',
                  height: '1.75rem',
                  borderRadius: '9999px',
                  backgroundColor: c.color,
                  border: 'none',
                  cursor: 'pointer',
                  outline: activeColor === c.name ? '2px solid #18181b' : '1px solid #d4d4d8',
                  outlineOffset: '2px',
                  padding: 0,
                }}
              />
            ))}
          </div>
        </div>

        {/* Size selector */}
        <div style={{ marginTop: '1.5rem' }}>
          <p style={{ fontSize: '0.75rem', textTransform: 'uppercase', color: '#71717a', margin: '0 0 0.5rem' }}>
            Size
          </p>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '0.5rem' }}>
            {product.sizes.map((size) => (
              <button
                key={size}
                onClick={() => setActiveSize(size)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  padding: '0.5rem 0.75rem',
                  fontSize: '0.875rem',
                  fontWeight: 500,
                  backgroundColor: '#fff',
                  cursor: 'pointer',
                  borderRadius: '0.375rem',
                  border: activeSize === size ? '2px solid #18181b' : '1px solid #e4e4e7',
                  color: '#71717a',
                  transition: 'border-color 0.15s',
                }}
              >
                {size}
              </button>
            ))}
          </div>
        </div>

        {/* Action buttons */}
        <div style={{ display: 'flex', gap: '0.5rem', marginTop: '2rem' }}>
          <button style={{ ...buttonBase, color: '#fff', backgroundColor: '#18181b', border: '1px solid #18181b' }}>
            Add to Cart
          </button>
          <button style={{ ...buttonBase, color: '#52525b', backgroundColor: '#fafafa', border: '1px solid #e4e4e7' }}>
            Buy Now
          </button>
        </div>

        <p style={{ fontSize: '0.875rem', color: '#71717a', marginTop: '0.5rem' }}>
          Free shipping over $50
        </p>

        {/* Accordion sections */}
        <div style={{ marginTop: '2rem', borderTop: '1px solid #e4e4e7', borderBottom: '1px solid #e4e4e7' }}>
          {[
            { title: 'Details', content: 'This product is crafted from high-quality materials designed for durability and comfort.' },
            { title: 'Shipping', content: 'We offer free standard shipping on all orders above $50. Express shipping available at checkout.' },
            { title: 'Returns', content: 'We accept returns within 30 days of purchase. Items must be in their original condition.' },
          ].map((section, i) => (
            <details key={i} style={{ borderTop: i > 0 ? '1px solid #e4e4e7' : 'none', cursor: 'pointer' }}>
              <summary style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '1rem 0',
                fontSize: '0.875rem',
                fontWeight: 500,
                listStyle: 'none',
              }}>
                {section.title}
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ width: '1rem', height: '1rem' }}>
                  <path d="M12 5l0 14" />
                  <path d="M5 12l14 0" />
                </svg>
              </summary>
              <p style={{ fontSize: '0.875rem', color: '#71717a', paddingBottom: '1rem', margin: 0 }}>
                {section.content}
              </p>
            </details>
          ))}
        </div>
      </div>
    </div>
  );
};
