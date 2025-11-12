const express = require('express');
const router = express.Router();
const sql = require('mssql');

// import dbConfig
const dbConfig = require('../dbConfig');



// (GET)/products/all
// Return all products
router.get('/products/all', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        const result = await request.query('SELECT * FROM [SanPham]');

        return res.json(result.recordsets[0]);
    }
    catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get all products query.' });
    }
});




// (GET)/:MaSP
// Return single product
router.get('/:MaSP', async (req, res) => {
    const MaSP = req.params.MaSP;
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request();

        request.input('MaSP', sql.VarChar, MaSP);
        const result = await request.query('SELECT * FROM [SanPham] WHERE MaSP = @MaSP');
        
        return res.json(result.recordsets[0]);
    }
    catch (error) {
        console.log(error);
        return res.status(500).send({ message: 'Error executing get product query.' });
    }
});







// (GET)/products/topbuy
// Return top limit most bought products by UserID
router.get('/products/toppurchased', async (req, res) => {
    try {
        const { UserID, limit } = req.query;
        if (!UserID || !limit) {
            return res.status(400).send({ message: 'Missing required parameters: UserID and limit.' });
        };
        const limitInt = parseInt(limit);

        const pool = await sql.connect(dbConfig);
        const request = pool.request();
        request.input('p_UserID', sql.VarChar, UserID);
        request.input('p_Limit', sql.Int, limitInt);

        const result = await request.execute('GetTopPurchasedItems');
        return res.json(result.recordsets[0]);
    }
    catch (error) {
        console.log(error);
        return res.status(500).send({ message: 'Error executing stored procedure.' });
    }
});



module.exports = router;