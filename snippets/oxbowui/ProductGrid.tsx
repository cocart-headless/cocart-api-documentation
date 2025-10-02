import { useState } from 'react';

export const ProductGrid = () => {
  const [notification, setNotification] = useState('');

  const sampleProducts = [
    {
      id: 1,
      name: 'Nike Air Force 1´07 Fresh',
      price: '$280.00',
      image: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=300&fit=crop'
    },
    {
      id: 2,
      name: 'Nike Air Force 1 LE',
      price: '$140.00',
      image: 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=400&h=300&fit=crop'
    },
    {
      id: 3,
      name: 'Nike Air Max 90',
      price: '$120.00',
      image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=300&fit=crop'
    }
  ];

  const handleAddToCart = (productName: string) => {
    setNotification(`${productName} added to cart!`);
    setTimeout(() => setNotification(''), 3000);
  };

  return (
    <div className="relative">
      {/* Notification */}
      {notification && (
        <div className="fixed top-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg z-50 animate-fade-in">
          {notification}
        </div>
      )}

      <div className="relative grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {sampleProducts.map((product) => (
          <div key={product.id} className="relative flex flex-col justify-between gap-2 group">
            <div className="relative aspect-[4/3]">
              <img
                src={product.image}
                alt={product.name}
                className="absolute inset-0 object-cover w-full h-full rounded-2xl bg-zinc-50"
              />

              {/* Add to Cart Button (appears on hover) */}
              <button
                onClick={() => handleAddToCart(product.name)}
                className="absolute bottom-4 left-1/2 -translate-x-1/2 opacity-0 group-hover:opacity-100 transition-opacity bg-zinc-900 text-white px-6 py-2 rounded-full text-sm font-medium hover:bg-zinc-800"
              >
                Add to Cart
              </button>
            </div>
            <div>
              <div className="flex items-center justify-between w-full">
                <h3 className="text-sm font-medium text-zinc-900 dark:text-white">
                  {product.name}
                  <a href="#demo">
                    <span className="absolute inset-0"></span>
                  </a>
                </h3>
                <h3 className="text-sm text-zinc-500 dark:text-zinc-300">
                  {product.price}
                </h3>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
