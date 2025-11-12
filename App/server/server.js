// inject server config
require('dotenv').config();

const express = require('express');
const sql = require('mssql');
const cors = require('cors');

const app = express();
const port = 5000;

const dbConfig = require('./dbConfig')

// --- 1. Middleware ---
app.use(cors());
app.use(express.json());


// --- 3. Method API Routes ---
const userRoutes = require('./routes/userRoutes');
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes');
const orderRoutes = require('./routes/orderRoutes');
const paymentRoutes = require('./routes/paymentRoutes');





app.use('/user', userRoutes);


app.use('/product', productRoutes);


app.use('/cart', cartRoutes);


app.use('/order', orderRoutes);


app.use('/payment', paymentRoutes);







app.get('/', (req, res) => {
    res.send('Express Server is running.');
});



// --- 4. Start Server ---
app.listen(port, () => {
    console.log(`Express API listening at http://localhost:${port}`);
});