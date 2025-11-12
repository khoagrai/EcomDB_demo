const express = require('express');
const router = express.Router();
const sql = require('mssql');

// import dbConfig
const dbConfig = require('../dbConfig');




// (GET)/payment/order/:MaDon
// Get payment for an order by MaDon
router.get('/order/:MaDon', async (req, res) => {
    const MaDon = req.params.MaDon;
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        request.input('input_MaDon', sql.VarChar, MaDon); 
        const result = await request.execute('GetThanhToanByMaDon');

        return res.json(result.recordsets[0]); 
    } catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get payment by order.' });
    }
});





module.exports = router;