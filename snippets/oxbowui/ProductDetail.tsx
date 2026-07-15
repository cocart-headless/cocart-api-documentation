export const ProductDetail = () => {
  const product = {
    name: 'Nike Air Max',
    price: '190',
    color: 'Black',
    description: 'Hitting the field in the late \'60s, adidas airmaxS quickly became soccer\'s "it" shoe.',
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&h=500&fit=crop'
  };

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '2rem', marginTop: '2rem', alignItems: 'start' }}>
      <img
        src={product.image}
        alt={product.name}
        style={{
          width: '100%',
          aspectRatio: '16/10',
          objectFit: 'cover',
          objectPosition: 'center',
          borderRadius: '1rem',
        }}
      />

      <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
        <div>
          <p style={{ fontSize: '3rem', fontWeight: 400, lineHeight: 1.1, margin: 0 }}>
            ${product.price}
          </p>
          <h3 style={{ fontSize: '1.5rem', fontWeight: 500, marginTop: '2rem' }}>
            {product.name}
          </h3>
          <p style={{ fontSize: '0.875rem', color: '#71717a', marginTop: '0.25rem' }}>
            {product.color}
          </p>
          <p style={{ fontSize: '0.875rem', color: '#71717a', marginTop: '1rem' }}>
            {product.description}
          </p>
        </div>

        <div style={{ marginTop: '1rem' }}>
          <button
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 500,
              fontSize: '0.875rem',
              color: '#fff',
              backgroundColor: '#18181b',
              borderRadius: '0.375rem',
              border: '1px solid #18181b',
              height: '2.25rem',
              padding: '0 1rem',
              cursor: 'pointer',
            }}
          >
            Add to Cart
          </button>
        </div>
      </div>
    </div>
  );
};
