import { useState } from 'react';

export const ProductDetail = () => {
  const [notification, setNotification] = useState('');

  const product = {
    name: 'Nike Air Max',
    price: '$190',
    color: 'Black',
    description: 'Hitting the field in the late \'60s, adidas airmaxS quickly became soccer\'s "it" shoe.',
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&h=500&fit=crop'
  };

  const handleAddToCart = () => {
    setNotification(`${product.name} added to cart!`);
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

      <div className="items-center mt-8 grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Product Image */}
        <img
          src={product.image}
          className="w-full aspect-[16/10] object-cover object-center rounded-2xl lg:col-span-2"
          alt={product.name}
        />

        {/* Product Details */}
        <div className="flex flex-col gap-8">
          <div>
            <p className="text-4xl sm:text-4xl md:text-5xl lg:text-6xl dark:text-zinc-100">
              {product.price}
            </p>
            <h1 className="text-xl md:text-2xl lg:text-3xl mt-12 font-medium dark:text-zinc-100">
              {product.name}
            </h1>
            <p className="text-base mt-1 text-zinc-500 dark:text-zinc-300">
              {product.color}
            </p>
            <p className="text-base mt-4 text-zinc-500 dark:text-zinc-300 lg:text-balance">
              {product.description}
            </p>
          </div>

          {/* Action Buttons */}
          <div className="flex mt-8">
            <button
              onClick={handleAddToCart}
              className="relative flex items-center justify-center text-center font-medium transition-colors duration-200 ease-in-out select-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:z-10 justify-center rounded-md text-white bg-zinc-900 outline outline-zinc-900 hover:bg-zinc-950 focus-visible:outline-zinc-950 dark:bg-zinc-100 dark:text-zinc-900 dark:outline-zinc-100 dark:hover:bg-zinc-200 dark:focus-visible:outline-zinc-200 h-9 px-4 text-sm"
            >
              Add to Cart
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
