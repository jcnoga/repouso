import { useEffect, useState } from "react";
import { getPayments } from "../services/paymentsService";

export function Financeiro() {
  const [payments, setPayments] = useState<any[]>([]);

  useEffect(() => {
    async function loadPayments() {
      const data = await getPayments();
      setPayments(data);
    }

    loadPayments();
  }, []);

  return (
    <div>
      <h1>Financeiro</h1>

      {payments.map((payment) => (
        <div key={payment.id}>
          {payment.amount}
        </div>
      ))}
    </div>
  );
}