import "./PublicLayout.css";

import { Outlet } from "react-router-dom";

function PublicLayout() {
  return (
    <div className="PublicLayout-container">
      <main>
        <Outlet />
      </main>
    </div>
  );
}

export default PublicLayout;
