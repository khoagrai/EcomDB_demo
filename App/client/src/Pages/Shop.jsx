import "./Shop.css";
import { Link } from "react-router-dom";

function Shop() {
  return (
    <>
      <div>Hello, Youre at landing page for shop</div>
      <Link to="/admin">
      <button>
        Go to Admin
      </button>
      </Link>
    </>
  );
}

export default Shop;
