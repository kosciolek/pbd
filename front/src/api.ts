import ky from "ky";
import { useQuery } from "react-query";

export const api = ky.extend({
  prefixUrl: "http://localhost:3001"
});

export const useProducts = () =>
  useQuery("product", async () => await api.get("product").json());
