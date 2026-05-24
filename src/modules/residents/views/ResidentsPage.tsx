import { useEffect, useState } from "react";

import { supabase } from "@/lib/supabase";

export function ResidentsPage() {
  const [residents, setResidents] =
    useState<any[]>([]);

  const [name, setName] = useState("");

  async function loadResidents() {
    const { data } = await supabase
      .from("residents")
      .select("*");

    if (data) {
      setResidents(data);
    }
  }

  async function createResident() {
    const {
      data: { user },
    } = await supabase.auth.getUser();

    const { data: profile } =
      await supabase
        .from("profiles")
        .select("*")
        .eq("id", user?.id)
        .single();

    await supabase.from("residents").insert({
      name,

      room: "101",

      status: "active",

      tenant_id: profile?.tenant_id,
    });

    setName("");

    loadResidents();
  }

  useEffect(() => {
    loadResidents();
  }, []);

  return (
    <div>
      <h1>👴 Residentes</h1>

      <div
        style={{
          display: "flex",
          gap: 10,
          marginBottom: 20,
        }}
      >
        <input
          placeholder="Nome"
          value={name}
          onChange={(e) =>
            setName(e.target.value)
          }
        />

        <button
          onClick={createResident}
        >
          Adicionar
        </button>
      </div>

      {residents.map((resident) => (
        <div key={resident.id}>
          {resident.name}
        </div>
      ))}
    </div>
  );
}