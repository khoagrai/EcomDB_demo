const express = require('express');
const router = express.Router();
const sql = require('mssql');

// import dbConfig
const dbConfig = require('../dbConfig');




// (GET)/order/orders/all
// Return list of all orders
router.get('/orders/all', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        const result = await request.query('SELECT * FROM [DonHang]');

        return res.json(result.recordsets[0]);
    }
    catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get all products query.' });
    }
});





// (GET)/order/orders/:UserID
// Get order list by user ID
router.get('/orders/:UserID', async (req, res) => {
    const UserID = req.params.UserID;
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        request.input('input_UserID', sql.VarChar, UserID); 
        const result = await request.execute('GetOrderListByUserID');

        return res.json(result.recordsets[0]); 
    } catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get orderlist by UserID.' });
    }
});




// (GET)/order/:MaDon
// Get order content by MaDon
router.get('/:MaDon', async (req, res) => {
    const MaDon = req.params.MaDon;
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        request.input('input_MaDon', sql.VarChar, MaDon); 
        const result = await request.execute('GetOrderContentByMaDon');

        return res.json(result.recordsets[0]); 
    } catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get order content by MaDon.' });
    }
});






module.exports = router;