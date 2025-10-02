import { useState } from 'react';

export const VariableProduct = () => {
  const [activeImage, setActiveImage] = useState(0);
  const [activeColor, setActiveColor] = useState<string | null>(null);
  const [activeSize, setActiveSize] = useState<string | null>(null);
  const [notification, setNotification] = useState('');
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [shippingOpen, setShippingOpen] = useState(false);
  const [returnsOpen, setReturnsOpen] = useState(false);

  const product = {
    name: 'Nike Air Force 1´07 Fresh',
    price: '$190',
    description: 'Hitting the field in the late \'60s, adidas Air Force quickly became soccer\'s "it" shoe.',
    images: [
      'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=600&h=600&fit=crop',
      'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600&h=600&fit=crop',
      'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=600&h=600&fit=crop',
      'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?w=600&h=600&fit=crop'
    ],
    colors: [
      { name: 'Black', ring: 'ring-zinc-700', bg: 'bg-zinc-400' },
      { name: 'Gray', ring: 'ring-zinc-300', bg: 'bg-zinc-200' },
      { name: 'Red', ring: 'ring-red-300', bg: 'bg-red-200' },
      { name: 'Blue', ring: 'ring-blue-300', bg: 'bg-blue-200' }
    ],
    sizes: ['6', '7', '8', '9', '10', '11', '12', '13']
  };

  const handleAddToCart = () => {
    if (!activeColor || !activeSize) {
      setNotification('Please select color and size');
      setTimeout(() => setNotification(''), 3000);
      return;
    }
    setNotification(`${product.name} (${activeColor}, Size ${activeSize}) added to cart!`);
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

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Product Image Gallery */}
        <div className="flex flex-col lg:sticky lg:top-24 lg:self-start gap-2">
          {/* Main Image */}
          <div className="overflow-hidden aspect-square bg-zinc-200 dark:bg-zinc-900 rounded-2xl">
            <img
              src={product.images[activeImage]}
              className="object-cover w-full h-full aspect-square"
              alt="Product image"
            />
          </div>

          {/* Thumbnails */}
          <div className="w-full grid grid-cols-6 gap-2">
            {product.images.map((image, index) => (
              <button
                key={index}
                onClick={() => setActiveImage(index)}
                className={`overflow-hidden w-full bg-zinc-200 rounded-xl aspect-square ${
                  activeImage === index ? 'ring-2 ring-zinc-900' : ''
                }`}
              >
                <img
                  src={image}
                  className="object-cover w-full h-full aspect-square"
                  alt="Product thumbnail"
                />
              </button>
            ))}
          </div>
        </div>

        {/* Product Details */}
        <div className="flex flex-col">
          <div className="flex items-center justify-between text-zinc-900 dark:text-white">
            <h1 className="text-xl sm:text-xl md:text-2xl font-medium">
              {product.name}
            </h1>
            <p>{product.price}</p>
          </div>

          <p className="text-base mt-4 text-zinc-500 dark:text-zinc-300">
            {product.description}
          </p>

          <div className="flex flex-col mt-4 gap-4">
            {/* Color Selector */}
            <div>
              <p className="text-xs uppercase text-zinc-500 dark:text-zinc-300">Color</p>
              <fieldset aria-label="Choose a color" className="mt-2">
                <div className="flex flex-wrap items-center gap-3">
                  {product.colors.map((color) => (
                    <label
                      key={color.name}
                      aria-label={color.name}
                      className={`relative -m-0.5 duration-300 flex cursor-pointer items-center justify-center rounded-full p-0.5 focus:outline-none ${
                        activeColor === color.name ? 'ring-2 ring-offset-2 ring-zinc-900' : ''
                      }`}
                    >
                      <input
                        type="radio"
                        name="color-choice"
                        value={color.name}
                        className="sr-only"
                        onChange={() => setActiveColor(color.name)}
                      />
                      <span
                        aria-hidden="true"
                        className={`rounded-full w-6 h-6 ring-1 ${color.ring} ${color.bg}`}
                      ></span>
                    </label>
                  ))}
                </div>
              </fieldset>
            </div>

            {/* Size Selector */}
            <div>
              <div className="flex items-center justify-between">
                <p className="text-xs uppercase text-zinc-500 dark:text-zinc-300">Shoe size</p>
              </div>
              <div className="mt-2 grid grid-cols-4 gap-2">
                {product.sizes.map((size) => (
                  <div key={size}>
                    <input
                      type="radio"
                      id={`size-${size}`}
                      value={size}
                      name="size-choice"
                      checked={activeSize === size}
                      onChange={() => setActiveSize(size)}
                      className="sr-only peer"
                    />
                    <label
                      htmlFor={`size-${size}`}
                      className="flex items-center justify-center px-3 py-2 text-sm font-medium bg-white cursor-pointer dark:bg-zinc-900 ring-1 ring-zinc-200 dark:ring-zinc-700 rounded-md duration-300 peer-checked:ring-2 peer-checked:ring-zinc-900 peer-checked:text-zinc-500 text-zinc-500 dark:text-zinc-200 peer-checked:ring-offset-2"
                    >
                      {size}
                    </label>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex flex-row mt-8 gap-2">
            <button
              onClick={handleAddToCart}
              className="relative flex items-center justify-center text-center font-medium transition-colors duration-200 ease-in-out select-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:z-10 justify-center rounded-md text-white bg-zinc-900 outline outline-zinc-900 hover:bg-zinc-950 focus-visible:outline-zinc-950 dark:bg-zinc-100 dark:text-zinc-900 dark:outline-zinc-100 dark:hover:bg-zinc-200 dark:focus-visible:outline-zinc-200 h-9 px-4 text-sm w-full"
            >
              Add to Cart
            </button>
            <button className="relative flex items-center justify-center text-center font-medium transition-colors duration-200 ease-in-out select-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:z-10 justify-center rounded-md text-zinc-600 bg-zinc-50 outline outline-zinc-100 hover:bg-zinc-200 focus-visible:outline-zinc-600 dark:text-zinc-100 dark:bg-zinc-800 dark:outline-zinc-800 dark:hover:bg-zinc-700 dark:focus-visible:outline-zinc-700 h-9 px-4 text-sm w-full">
              Buy Now
            </button>
          </div>

          {/* Free shipping notice */}
          <p className="text-sm mt-1 text-zinc-500 dark:text-zinc-300">
            Free shipping over $50
          </p>

          {/* Accordion sections */}
          <div className="mt-8 divide-y divide-zinc-200 dark:divide-zinc-700 border-y border-zinc-200 dark:border-zinc-700">
            <details open={detailsOpen} onToggle={(e: any) => setDetailsOpen(e.target.open)} className="cursor-pointer group">
              <summary className="text-sm flex items-center justify-between w-full py-4 font-medium text-left select-none text-zinc-900 dark:text-white hover:text-zinc-500 dark:hover:text-zinc-400 focus:text-zinc-500 dark:focus:text-zinc-400">
                Details
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  className={`w-4 h-4 duration-300 ease-out transform ${detailsOpen ? '-rotate-45' : ''}`}
                >
                  <path stroke="none" d="M0 0h24v24H0z" fill="none"></path>
                  <path d="M12 5l0 14"></path>
                  <path d="M5 12l14 0"></path>
                </svg>
              </summary>
              <div className="pb-4">
                <p className="text-sm text-zinc-500 dark:text-zinc-300">
                  This product is crafted from high-quality materials designed for durability and comfort.
                </p>
              </div>
            </details>

            <details open={shippingOpen} onToggle={(e: any) => setShippingOpen(e.target.open)} className="cursor-pointer group">
              <summary className="text-sm flex items-center justify-between w-full py-4 font-medium text-left select-none text-zinc-900 dark:text-white hover:text-zinc-500 dark:hover:text-zinc-400 focus:text-zinc-500 dark:focus:text-zinc-400">
                Shipping
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  className={`w-4 h-4 duration-300 ease-out transform ${shippingOpen ? '-rotate-45' : ''}`}
                >
                  <path stroke="none" d="M0 0h24v24H0z" fill="none"></path>
                  <path d="M12 5l0 14"></path>
                  <path d="M5 12l14 0"></path>
                </svg>
              </summary>
              <div className="pb-4">
                <p className="text-sm text-zinc-500 dark:text-zinc-300">
                  We offer free standard shipping on all orders above $50. Express shipping available at checkout.
                </p>
              </div>
            </details>

            <details open={returnsOpen} onToggle={(e: any) => setReturnsOpen(e.target.open)} className="cursor-pointer group">
              <summary className="text-sm flex items-center justify-between w-full py-4 font-medium text-left select-none text-zinc-900 dark:text-white hover:text-zinc-500 dark:hover:text-zinc-400 focus:text-zinc-500 dark:focus:text-zinc-400">
                Returns
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  className={`w-4 h-4 duration-300 ease-out transform ${returnsOpen ? '-rotate-45' : ''}`}
                >
                  <path stroke="none" d="M0 0h24v24H0z" fill="none"></path>
                  <path d="M12 5l0 14"></path>
                  <path d="M5 12l14 0"></path>
                </svg>
              </summary>
              <div className="pb-4">
                <p className="text-sm text-zinc-500 dark:text-zinc-300">
                  We accept returns within 30 days of purchase. Items must be in their original condition.
                </p>
              </div>
            </details>
          </div>
        </div>
      </div>
    </div>
  );
};