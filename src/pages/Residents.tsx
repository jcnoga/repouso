import { useEffect, useState } from "react";
import { supabase } from "../lib/supabase";

export function Residents() {
  const [residents, setResidents] = useState<any[]>([]);

  useEffect(() => {
    async function load() {
      const { data } = await supabase.from("residents").select("*");
      setResidents(data || []);
    }

    load();
  }, []);

  return (
    <div>
      <h1 className="text-xl font-bold mb-4">Residentes</h1>

      <div className="bg-white border rounded p-4">
        {residents.map((r) => (
          <div key={r.id} className="border-b py-2">
            {r.name}
          </div>
        ))}
      </div>
    </div>
  );
}