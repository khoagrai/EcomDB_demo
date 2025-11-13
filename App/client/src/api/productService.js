import { apiFetch } from "./apiClient";

export function getAllProducts(page = 1, limit = 20) {
  console.log(`[Product Service]Calling getAllProducts(${page},${limit})`);
  const data = apiFetch(`/product/products/all`, {
    method: "GET",
    // params: { page: page, limit: limit },
  });
  return data;
}