import { useEffect, useState } from "react";
import { chatApi } from "../services/api";

export default function ChatPage({ user }) {
  const [peerId, setPeerId] = useState(2);
  const [text, setText] = useState("");
  const [messages, setMessages] = useState([]);

  const load = async () => {
    const { data } = await chatApi.mine(peerId);
    setMessages(data);
  };

  useEffect(() => {
    load().catch(() => setMessages([]));
  }, [peerId]);

  const send = async (e) => {
    e.preventDefault();
    if (!text.trim()) return;
    await chatApi.send({ senderId: user?.id, receiverId: Number(peerId), message: text });
    setText("");
    load();
  };

  return (
    <div className="stack">
      <div className="page-hero">
        <div>
          <h2>Secure Chat</h2>
          <p>Send quick messages between elder, caregiver, and doctor accounts.</p>
        </div>
      </div>
      <div className="card">
        <h2>Chat</h2>
        <div className="grid-form">
          <label>Your ID <input value={user?.id || ""} disabled /></label>
          <label>Receiver ID <input value={peerId} onChange={(e) => setPeerId(Number(e.target.value))} /></label>
        </div>
        <div className="chat-box">
          {messages.map((m) => (
            <p key={m.id}><strong>{m.senderId === user?.id ? "You" : `User ${m.senderId}`}</strong>: {m.message}</p>
          ))}
        </div>
        <form onSubmit={send} className="chat-form">
          <input value={text} onChange={(e) => setText(e.target.value)} placeholder="Type a message..." />
          <button type="submit">Send</button>
        </form>
      </div>
    </div>
  );
}
