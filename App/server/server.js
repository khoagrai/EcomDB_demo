// inject server config
require('dotenv').config();

const express = require('express');
const sql = require('mssql');
const cors = require('cors');

const app = express();
const port = 5000;


// --- 1. Middleware ---
app.use(cors());
app.use(express.json());

// --- 2. Database Configuration ---
const dbConfig = {
    server: process.env.DB_SERVER,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    options: {
        encrypt: false,
        trustServerCertificate: true,
    },
};



// --- 3. Method API Routes ---

app.get('/api/users', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM [User]');
        return res.json(result.recordsets[0]);
    }
    catch (error) {
        console.log(error);
    }
});




app.get('/api/products', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM [SanPham]');
        return res.json(result.recordsets[0]);
    }
    catch (error) {
        console.log(error);
    }
});





app.get('/', (req, res) => {
    res.send('Express Server is running.');
});



// --- 4. Start Server ---
app.listen(port, () => {
    console.log(`Express API listening at http://localhost:${port}`);
});