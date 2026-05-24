import { useEffect, useState } from "react";
import { getSubscription } from "../services/billingService";

export function useSubscription() {
  const [data, setData] = useState(null);

  useEffect(() => {
    getSubscription().then(setData);
  }, []);

  return data;
}