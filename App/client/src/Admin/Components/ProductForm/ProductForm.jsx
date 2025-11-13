import { useEffect, useState } from "react";
import "./ProductForm.css";
import DefaultImage from "../../../assets/placeholder-image.png";
import { FiX} from "react-icons/fi";
// import {
//   createProduct,
//   updateProduct,
//   deleteProduct,
// } from "../../../api/productService";

function ProductForm({ mode, currentItem = null, onCancel, onSuccess }) {
  // Properties of form
  const [formData, setFormData] = useState({
    TenSP: "",
    LoaiSP: "",
    GiaTien: "",
    MoTa: "",
  });

  // UseEffect for initial data of form (currentItem or blank)
  useEffect(() => {
    if (currentItem) {
      setFormData({
        TenSP: currentItem.TenSP || "",
        LoaiSP: currentItem.LoaiSP || "",
        GiaTien: currentItem.GiaTien || "",
        MoTa: currentItem.MoTa || "",
      });
    } else {
      setFormData({
        TenSP: "",
        LoaiSP: "",
        GiaTien: "",
        MoTa: "",
      });
    }
    console.log("currentItem: ", currentItem);
  }, [currentItem]);

  // Handle change for input fields
  const handleChange = (e) => {
    if (mode === "delete") {
      return;
    }

    const { name, value, type, files } = e.target;

    let newValue = value;

    if (type === "file") {
      newValue = files[0];
    }

    setFormData((prevData) => ({ ...prevData, [name]: newValue }));
  };

  // Handle Submit based on form mode
  const handleSubmit = async (e) => {
    e.preventDefault(); // Prevent default browser form submission

    try {
      // let response;

      if (mode === "add") {
        // 1. ADD MODE: Call the API to create a new product
        console.log("Submitting new product...");



        alert("Product created successfully!");
      } else if (mode === "edit") {
        // 2. EDIT MODE: Call the API to update the existing product
        // productId required

        // const productId = currentItem.MaSP;


        alert("Product updated successfully!");
      } else if (mode === "delete") {
        // 3. DELETE MODE: Call the API to delete the existing product
        //  productId required

        // const productId = currentItem.MaSP;
        // console.log(`Deleting product ${productId}...`);
        // deleteProduct(productId);

        alert("Product Deleted successfully!");
      }

      onSuccess();
      onCancel();

      // Optional: Redirect user, close modal, or clear form here
    } catch (error) {
      console.error("Submission failed:", error);
      alert("Error saving product. Check the console for details.");
    }
  };

  
  // Set text based on form mode
  let title = "Product Form";
  let subTitle = "Product Form";
  let submitText = "Submit";

  if (mode === "add") {
    title = "Thêm Sản Phẩm";
    subTitle = "Nhập thông tin cho sản phẩm mới:";
    submitText = "Thêm sản phẩm";
  } else if (mode === "edit") {
    title = "Chỉnh Sửa Sản Phẩm";
    subTitle = "Thông tin sản phẩm sẽ được thay bằng thông tin mới";
    submitText = "Xác nhận chỉnh sửa";
  } else if (mode === "delete") {
    title = "Xác nhận: Xóa sản phẩm";
    subTitle = "Sản phẩm này sẽ bị xóa, hãy xác nhận:";
    submitText = "Xóa sản phẩm";
  }

  const buttonClass =
    mode === "delete" ? "btn-delete" : mode === "edit" ? "btn-edit" : "btn-add";

  // Form container
  return (
    <div className="ProductForm-container">
      <header>
        <div id="title">{title}</div>
        <div id="subTitle">{subTitle}</div>
      </header>
      {/* Actual form */}
      <form className="product-form" onSubmit={handleSubmit}>
        {/* Image */}
        <div id="section-image">
          <div>Hình ảnh</div>

            <img src={currentItem?.imageInfo?.url || DefaultImage} alt = ""/>

        </div>
        {/* Data  */}
        <div id="section-data">
          <div>Tên sản phẩm:</div>
          <input
            name="TenSP"
            type="text"
            placeholder="Nhập tên sản phẩm"
            value={formData.TenSP}
            onChange={handleChange}
          />
          <div>Phân loại:</div>
          <input
            name="LoaiSP"
            type="text"
            placeholder="Nhập phân loại sản phẩm"
            value={formData.LoaiSP}
            onChange={handleChange}
          />
          <div>Giá thành/1:</div>
          <input
            name="GiaTien"
            type="number"
            placeholder="Nhập giá thành sản phẩm"
            value={formData.GiaTien}
            onChange={handleChange}
          />
          <div>Mô tả:</div>
          <textarea
            name="MoTa"
            type="text"
            placeholder="Nhập mô tả sản phẩm"
            value={formData.MoTa}
            onChange={handleChange}
          />
        </div>
        <button type="submit" id="productForm-submit" className={buttonClass}>
          {submitText}
        </button>
      </form>
      <button id="ProductForm-cancel" onClick={onCancel}>
        <FiX />
        Hủy
      </button>
    </div>
  );
}

export default ProductForm;
