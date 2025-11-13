import React from "react";
import "./AdminItemRow.css";
import { FaEdit, FaTrash } from "react-icons/fa";
import DefaultImage from "../../../assets/placeholder-image.png";
import { vnd } from "../../../utils/currencyUtils";

const AdminItemRow = (props) => {
  const { onEdit, onDelete, index } = props;

  return (
    <tr className="AdminItemRow">
      <td id="index">{index}</td>
      <td id="image">
        <img
          onClick={() => window.scrollTo(0, 0)}
          src={DefaultImage}
          alt={"Image for " + props.TenSP}
        />
      </td>
      <td id="name">{props.TenSP}</td>
      <td id="category">
        <span>{props.LoaiSP}</span>
      </td>
      <td id="price">{vnd(props.GiaTien)}</td>
      <td id="description">{props.MoTa}</td>
      <td id="actions">
        <button id="edit" onClick={onEdit}>
          <FaEdit />
          Chỉnh sửa
        </button>
        <button id="delete" onClick={onDelete}>
          <FaTrash />
          Xóa SP
        </button>
      </td>
    </tr>
  );
};

export default AdminItemRow;
