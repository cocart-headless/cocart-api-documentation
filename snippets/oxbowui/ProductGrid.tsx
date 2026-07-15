export const ProductGrid = () => {
  const sampleProducts = [
    {
      id: 1,
      name: 'Nike Air Force 1\u00b407 Fresh',
      price: '280.00',
      image: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=300&fit=crop'
    },
    {
      id: 2,
      name: 'Nike Air Force 1 LE',
      price: '140.00',
      image: 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=400&h=300&fit=crop'
    },
    {
      id: 3,
      name: 'Nike Air Max 90',
      price: '120.00',
      image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=300&fit=crop'
    }
  ];

  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '1.5rem' }}>
      {sampleProducts.map((product) => (
        <div key={product.id} style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
          <div style={{ position: 'relative', aspectRatio: '4/3' }}>
            <img
              src={product.image}
              alt={product.name}
              style={{
                position: 'absolute',
                inset: 0,
                objectFit: 'cover',
                width: '100%',
                height: '100%',
                borderRadius: '1rem',
                backgroundColor: '#fafafa',
              }}
            />
          </div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', width: '100%' }}>
            <span style={{ fontSize: '0.875rem', fontWeight: 500 }}>
              {product.name}
            </span>
            <span style={{ fontSize: '0.875rem', color: '#71717a' }}>
              ${product.price}
            </span>
          </div>
        </div>
      ))}
    </div>
  );
};
