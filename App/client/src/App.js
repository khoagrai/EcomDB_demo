import "./App.css";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import PublicLayout from "./PublicLayout";
import Shop from "./Pages/Shop";

import AdminLayout from "./Admin/AdminLayout";
import ManageProducts from "./Admin/Pages/ManageProducts/ManageProducts";
import ManageOrders from "./Admin/Pages/ManageOrders/ManageOrders";

function App() {
  return (
    <div>
      <BrowserRouter>
        <Routes>
          {/* === PUBLIC ROUTES === */}
          <Route path="/" element={<PublicLayout/>}>
            <Route path="/" element={<Shop/>} />
          </Route>
        </Routes>
        <Routes>
          {/* === ADMIN ROUTES === */}
          <Route path="/admin" element={<AdminLayout />}>
            <Route path="products" element={<ManageProducts />} />
            <Route path="orders" element={<ManageOrders />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
