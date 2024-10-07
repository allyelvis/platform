#!/bin/bash

# Exit script on any error
set -e

echo "Setting up Aenzbi platform..."

# Step 1: Install Node.js 18 if not installed
echo "Checking Node.js installation..."
if ! command -v node &>/dev/null || [[ $(node -v) != v18* ]]; then
  echo "Installing Node.js 18..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

# Step 2: Create project directories
echo "Creating project directories..."
mkdir -p aenzbi/{backend,frontend,env}

# Step 3: Backend Setup
echo "Setting up backend with Node.js and Express..."
cd aenzbi/backend
npm init -y
npm install express mongoose dotenv jsonwebtoken

# Create backend folder structure
mkdir -p controllers models routes config middleware

# Create server.js
cat <<EOL > server.js
const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
dotenv.config();

const app = express();
app.use(express.json());

mongoose.connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => console.log('MongoDB connected'))
  .catch(err => console.log(err));

const invoiceRoutes = require('./routes/invoiceRoutes');
const productRoutes = require('./routes/productRoutes');

app.use('/api/invoices', invoiceRoutes);
app.use('/api/products', productRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(\`Server running on port \${PORT}\`));
EOL

# Create .env file for backend
echo "Creating .env file for backend..."
cat <<EOL > ../env/.env
MONGO_URI=mongodb://localhost:27017/aenzbi
EBMS_TOKEN=your_ebms_bearer_token_here
EOL

# Generate controllers
cat <<EOL > controllers/invoiceController.js
exports.createInvoice = (req, res) => {
    // Logic to create an invoice
    res.status(201).json({ message: 'Invoice created' });
};
EOL

cat <<EOL > controllers/productController.js
exports.getProducts = (req, res) => {
    // Logic to fetch products
    res.status(200).json([{ name: 'Sample Product', price: 10 }]);
};
EOL

# Generate routes
cat <<EOL > routes/invoiceRoutes.js
const express = require('express');
const { createInvoice } = require('../controllers/invoiceController');
const router = express.Router();

router.post('/create', createInvoice);

module.exports = router;
EOL

cat <<EOL > routes/productRoutes.js
const express = require('express');
const { getProducts } = require('../controllers/productController');
const router = express.Router();

router.get('/', getProducts);

module.exports = router;
EOL

echo "Backend setup completed."

# Step 4: Frontend Setup
echo "Setting up frontend with Next.js..."
cd ../frontend
npx create-next-app@latest . --use-npm

# Install additional frontend dependencies
npm install axios

# Create frontend pages
cat <<EOL > pages/index.js
import axios from 'axios';
import { useEffect, useState } from 'react';

export default function Home() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    axios.get('/api/products')
      .then(res => setProducts(res.data))
      .catch(err => console.error(err));
  }, []);

  return (
    <div>
      <h1>Product Listing</h1>
      <ul>
        {products.map(product => (
          <li key={product.name}>
            {product.name} - \$\{product.price}
          </li>
        ))}
      </ul>
    </div>
  );
}
EOL

cat <<EOL > pages/create-invoice.js
import axios from 'axios';
import { useState } from 'react';

export default function CreateInvoice() {
  const [invoiceData, setInvoiceData] = useState({
    customer: '',
    items: [],
    totalAmount: 0,
  });

  const handleSubmit = async () => {
    try {
      const res = await axios.post('/api/invoices/create', invoiceData);
      console.log('Invoice created:', res.data);
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div>
      <h1>Create Invoice</h1>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          value={invoiceData.customer}
          onChange={(e) => setInvoiceData({ ...invoiceData, customer: e.target.value })}
          placeholder="Customer Name"
        />
        {/* Add more fields to capture items and total amount */}
        <button type="submit">Create Invoice</button>
      </form>
    </div>
  );
}
EOL

echo "Frontend setup completed."

# Step 5: GitHub Setup
echo "Initializing Git repository and setting up GitHub..."
cd ..
git init
git config --global user.name "allyelvis Nzeyimana"
git config --global user.email "allyelvis6569@gmail.com"
git add .
git commit -m "Initial commit for Aenzbi platform"
git branch -M main

# Optionally link to a remote GitHub repository
# Replace 'your-github-repo-url.git' with your actual GitHub repository URL
# git remote add origin https://github.com/allyelvis/platform.git
# git push -u origin main

echo "Git setup completed. If you haven't linked the repository, please do so manually."

echo "Aenzbi platform setup finished! You can now start the backend and frontend servers."
