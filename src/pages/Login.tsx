import { useState } from "react";
import { supabase } from "../lib/supabase";
import { useNavigate } from "react-router-dom";

export function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const navigate = useNavigate();

  async function handleLogin() {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (!error) {
      navigate("/dashboard");
    } else {
      alert(error.message);
    }
  }

  return (
    <div className="h-screen flex items-center justify-center">
      <div className="w-80 p-6 border bg-white rounded">
        <h1 className="text-xl font-bold mb-4">ILPI SaaS</h1>

        <input
          className="w-full border p-2 mb-2"
          placeholder="Email"
          onChange={(e) => setEmail(e.target.value)}
        />

        <input
          className="w-full border p-2 mb-4"
          type="password"
          placeholder="Senha"
          onChange={(e) => setPassword(e.target.value)}
        />

        <button
          onClick={handleLogin}
          className="w-full bg-blue-600 text-white p-2"
        >
          Entrar
        </button>
      </div>
    </div>
  );
}